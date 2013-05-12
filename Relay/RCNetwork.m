
//
//  RCNetwork.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCNetwork.h"
#import "RCNetworkManager.h"
#import "TestFlight.h"
#import "RCChannelManager.h"
#import "RCInviteRequestAlert.h"
#import "RCPrettyAlertView.h"
#import "RCChatController.h"

#define RECV_BUF_LEN 10240

@implementation RCNetwork

@synthesize prefix, sDescription, server, nick, username, realname, spass, npass, port, isRegistered, useSSL, COL, _channels, useNick, userModes, _nicknames, shouldRequestSPass, shouldRequestNPass, namesCallback, expanded, _selected, SASL, cache, hasPendingBites;

- (RCChannel *)consoleChannel {
    @synchronized(_channels) {
		for (RCChannel *chan in _channels) {
			if ([[chan channelName] isEqualToString:@"\x01IRC"] && [chan isKindOfClass:[RCConsoleChannel class]]) {
				return chan;
			}
		}
		return nil;
	}
}

- (id)init {
	if ((self = [super init])) {
		status = RCSocketStatusClosed;
		shouldSave = NO;
		isRegistered = NO;
		canSend = YES;
		ctx = NULL;
		ssl = NULL;
		_selected = NO;
        prefix = nil;
		expanded = NO;
		_channels = [[NSMutableArray alloc] init];
		_isDisconnecting = NO;
        _nicknames = [[NSMutableArray alloc] init];
        if ([self useNick])
            [_nicknames addObject:[self useNick]];
	}
	return self;
}

+ (RCNetwork *)networkWithInfoDictionary:(NSDictionary *)info {
	RCNetwork *network = [[RCNetwork alloc] init];
	[network setUsername:[info objectForKey:USER_KEY]];
	[network setNick:[info objectForKey:NICK_KEY]];
	[network setRealname:[info objectForKey:NAME_KEY]];
	[network setSDescription:[info objectForKey:DESCRIPTION_KEY]];
	[network setServer:[info objectForKey:SERVR_ADDR_KEY]];
	[network setPort:[[info objectForKey:PORT_KEY] intValue]];
	[network setUseSSL:[[info objectForKey:SSL_KEY] boolValue]];
	[network setCOL:[[info objectForKey:COL_KEY] boolValue]];	
	if ([[info objectForKey:S_PASS_KEY] boolValue]) {
        //[network setSpass:([wrapper objectForKey:S_PASS_KEY] ?: @"")];
		RCKeychainItem *item = [[RCKeychainItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%@spass", [network _description]]];
		[network setSpass:([item objectForKey:(id)kSecValueData] ?: @"")];
		if ([network spass] == nil || [[network spass] length] == 0) {
			[network setShouldRequestSPass:YES];
		}
		[item release];
	}
	if ([[info objectForKey:N_PASS_KEY] boolValue]) {
		//[network setNpass:([wrapper objectForKey:N_PASS_KEY] ?: @"")];
		RCKeychainItem *item = [[RCKeychainItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%@npass", [network _description]]];
		[network setNpass:([item objectForKey:(id)kSecValueData] ?: @"")];
		if ([network npass] == nil || [[network npass] length] == 0) {
			[network setShouldRequestNPass:YES];
		}
		[item release];
	}
	NSMutableArray *rooms = [[[info objectForKey:CHANNELS_KEY] mutableCopy] autorelease];
	if (!rooms) {
		[network addChannel:@"\x01IRC" join:NO];
	}
	[network _setupRooms:rooms];
	return [network autorelease];
}

- (id)infoDictionary {
	NSMutableArray *chanArray = [[NSMutableArray alloc] init];
	for (RCChannel *chan in _channels) {
		if (![chan isKindOfClass:[RCPMChannel class]]) {
			// this should probably be a setting. saving PM's.
			// RCConsoleChannel check isn't really necesasry as it will be added as a new channel-
			// if it does not exist on launch. I guess if i add it, it skips one step later on.
			NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:
							  [chan channelName], CHANNAMEKEY,
							  ([chan joinOnConnect] ? (id)kCFBooleanTrue : (id)kCFBooleanFalse), @"0_CHANJOC",
							  ([[chan password] length] > 0 ? (id)kCFBooleanTrue : (id)kCFBooleanFalse), @"0_CHANPASS", nil];
			[chanArray addObject:dict];
			[dict autorelease];
		}
	}
	[chanArray autorelease];
	return [NSDictionary dictionaryWithObjectsAndKeys:
			(username ?: @""), USER_KEY,
			(nick ?: @""), NICK_KEY,
			(realname ?: @""), NAME_KEY,
			([spass length] > 0 ? (id)kCFBooleanTrue : (id)kCFBooleanFalse), S_PASS_KEY,
			([npass length] > 0 ? (id)kCFBooleanTrue : (id)kCFBooleanFalse), N_PASS_KEY,
			(sDescription ?: @""), DESCRIPTION_KEY,
			(server ?: @""), SERVR_ADDR_KEY,
			(SASL ? (id)kCFBooleanTrue : (id)kCFBooleanFalse), SASL_KEY,
			[NSNumber numberWithInt:port], PORT_KEY,
			[NSNumber numberWithBool:useSSL], SSL_KEY,
			[NSNumber numberWithBool:COL], COL_KEY,
			chanArray, CHANNELS_KEY,
			nil];
	// why don't i just use +[NSNumber numberWithBool:(BOOL)([pass length] > 0)] ..
	// whatever.
}

- (void)dealloc {
#if LOGALL
	NSLog(@"RELEASING NETWORK %@", self);
#endif
	[_channels release];
	[server release];
	[nick release];
	[username release];
	[realname release];
	[spass release];
	[npass release];
	[sDescription release];
    [_nicknames release];
    self.useNick = nil;
    [self setPrefix:nil];
	[super dealloc];
}

- (NSString *)_description {
	if (!sDescription || [sDescription isEqualToString:@""]) {
		return server;
	}
	return sDescription;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; %@;>", NSStringFromClass([self class]), self, [self infoDictionary]];
}

- (void)_setupRooms:(NSArray *)rooms {
	[rooms retain];
	for (NSDictionary *dict in rooms) {
		NSString *chan = [dict objectForKey:CHANNAMEKEY];
		if (!chan) continue;
		BOOL jOC = ([dict objectForKey:@"0_CHANJOC"] ? [[dict objectForKey:@"0_CHANJOC"] boolValue] : YES);
		[self addChannel:chan join:NO];
		RCChannel *_chan = [self channelWithChannelName:chan];
		[_chan setJoinOnConnect:jOC];
		RCKeychainItem *item = [[RCKeychainItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%@%@rpass", [self _description], chan]];
		[_chan setPassword:[item objectForKey:(id)kSecValueData]];
		[item release];		
	}
	[rooms release];
}

- (void)setupRooms:(NSArray *)rooms {
	[rooms retain];
	for (NSString *_chan in rooms) {
		[self addChannel:_chan join:NO];
	}
	[rooms release];
}

- (void)connectOrDisconnectDependingOnCurrentStatus {
	if ([self isTryingToConnectOrConnected])
		[self disconnect];
	else [self connect];
}

- (RCChannel *)channelWithChannelName:(NSString *)chan {
	return [self channelWithChannelName:chan ifNilCreate:NO];
}

- (RCChannel *)channelWithChannelName:(NSString *)chan ifNilCreate:(BOOL)cr {
    if ([chan isKindOfClass:[RCChannel class]]) {
        return (RCChannel *)chan;
    }
    @synchronized(self) {
        @synchronized(_channels) {
            for (RCChannel *chann in _channels) {
                if ([[[chann channelName] lowercaseString] isEqualToString:[chan lowercaseString]]) return chann;
            }
            if (cr) {
                [self addChannel:chan join:NO];
            }
            return nil;
        }
    }
}

- (RCChannel *)addChannel:(NSString *)_chan join:(BOOL)join {
    @synchronized(self) {
        if ([_chan hasPrefix:@" "]) {
            _chan = [_chan stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
        for (RCChannel *aChan in _channels) {
            if ([[[aChan channelName] lowercaseString] isEqualToString:[_chan lowercaseString]]) return aChan;
        }
        if (![self channelWithChannelName:_chan ifNilCreate:NO]) {
            RCChannel *chan = nil;
            if ([_chan isEqualToString:@"\x01IRC"]) chan = [[RCConsoleChannel alloc] initWithChannelName:_chan];
            else if ([_chan hasPrefix:@"#"]) chan = [[RCChannel alloc] initWithChannelName:_chan];
            else {
                chan = [[RCPMChannel alloc] initWithChannelName:_chan];
            }
            [chan setDelegate:self];
			if ([chan isKindOfClass:[RCConsoleChannel class]]) {
				[[self _channels] insertObject:chan atIndex:0];
			}
			else if ([chan isKindOfClass:[RCChannel class]] && ![chan isKindOfClass:[RCPMChannel class]]) {
				if ([self consoleChannel]) [[self _channels] insertObject:chan atIndex:1];
				else [[self _channels] insertObject:chan atIndex:0];
			}
			else {
				[[self _channels] insertObject:chan atIndex:[[self _channels] count]];
			}
            [chan release];
            if (join) [chan setJoined:YES withArgument:nil];
            if (isRegistered) {
                [[RCNetworkManager sharedNetworkManager] saveNetworks];
                shouldSave = YES; // if we aren't registered.. it's _likely_ just setup.
				reloadNetworks();
            }
            return chan;
        }
        else {
            RCChannel *chan = [self channelWithChannelName:_chan];
            return chan;
		}
    }
}

- (void)removeChannel:(RCChannel *)chan {
	[self removeChannel:chan withMessage:@"Relay Chat."];
}

- (void)removeChannel:(RCChannel *)chan withMessage:(NSString *)quitter {
    @synchronized(self) {
        if (!chan) return;
        [chan setJoined:NO withArgument:quitter];
		reloadNetworks();
        [_channels removeObject:chan];
        [[RCNetworkManager sharedNetworkManager] saveNetworks];
    }
}

#pragma mark - SOCKET STUFF

- (void)connect {
	if (shouldRequestNPass || shouldRequestSPass) {
		RCPasswordRequestAlertType type;
		if (shouldRequestSPass) type = RCPasswordRequestAlertTypeServer;
		else if (shouldRequestNPass) type = RCPasswordRequestAlertTypeNickServ;
		RCPasswordRequestAlert *rs = [[RCPasswordRequestAlert alloc] initWithNetwork:self type:type];
		[rs show];
		[rs release];
		return;
	}
	[self performSelectorInBackground:@selector(_connect) withObject:nil];
}

- (void)_connect {	
    BOOL oTT = tryingToConnect;
    tryingToConnect = YES;
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	writebuf = [[NSMutableString alloc] init];
	rcache = [[NSMutableString alloc] init];
    canSend = YES;
	cache = [[NSMutableString alloc] init];
    isRegistered = NO;
    if (status == RCSocketStatusConnecting) goto errme;
    if (status == RCSocketStatusConnected) goto errme;
    self.useNick = nick;
    self.userModes = @"~&@%+";
    if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_4_0) {
        task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:task];
            task = UIBackgroundTaskInvalid;
        }];
    }
    RCChannel *chan = [self consoleChannel];
    if (chan) [chan recievedMessage:[NSString stringWithFormat:@"Connecting to %@ on port %d", server, port] from:@"" type:RCMessageTypeNormal];
    status = RCSocketStatusConnecting;
	sockfd = [[RCSocket sharedSocket] connectToAddr:server withSSL:useSSL andPort:port fromNetwork:self];
errme:
	tryingToConnect = oTT;
out_:
	[p drain];
}

- (BOOL)read {
	static BOOL isReading;
	if (isReading) return YES;
	isReading = YES;
	int rc = 0;
	char buf[512];
	if (useSSL) {
		while ((rc = SSL_read(ssl, buf, 512)) > 0) {
			NSString *appenddee = [[NSString alloc] initWithBytesNoCopy:buf length:rc encoding:NSUTF8StringEncoding freeWhenDone:NO];
			if (appenddee) {
				[rcache appendString:appenddee];
				[appenddee release];
				while (([rcache rangeOfString:@"\r\n"].location != NSNotFound)) {
					// should probably use NSCharacterSet, etc etc.
					int loc = [rcache rangeOfString:@"\r\n"].location+2;
					NSString *cbuf = [rcache substringToIndex:loc];
					[self recievedMessage:cbuf];
					[rcache deleteCharactersInRange:NSMakeRange(0, loc)];
				}
			}
		}
	}
	else {
		while ((rc = read(sockfd, buf, 512)) > 0) {
			NSString *appenddee = [[NSString alloc] initWithBytesNoCopy:buf length:rc encoding:NSUTF8StringEncoding freeWhenDone:NO];
			if (appenddee) {
				[rcache appendString:appenddee];
				[appenddee release];
				while (([rcache rangeOfString:@"\r\n"].location != NSNotFound)) {
					// should probably use NSCharacterSet, etc etc.
					int loc = [rcache rangeOfString:@"\r\n"].location+2;
					NSString *cbuf = [rcache substringToIndex:loc];
					[self recievedMessage:cbuf];
					[rcache deleteCharactersInRange:NSMakeRange(0, loc)];
				}
			}
		}
	}
	// i know this makes me a bad person.
	isReading = NO;
	return NO;
}

- (BOOL)write {
	int written = 0;
	if (useSSL) written = SSL_write(ssl, [writebuf UTF8String], [writebuf length]);
	else written = write(sockfd, [writebuf UTF8String], strlen([writebuf UTF8String]));
	const char *buf = [writebuf UTF8String];
	buf = buf + written;
	[writebuf release];
	writebuf = [[NSMutableString alloc] initWithCString:buf encoding:NSUTF8StringEncoding];
	if ([writebuf length] == 0) hasPendingBites = NO;
	// this is derp. must be a better method. ;P
	return YES;
}

- (BOOL)sendMessage:(NSString *)msg {
	return [self sendMessage:msg canWait:YES];
}

- (BOOL)sendMessage:(NSString *)msg canWait:(BOOL)canWait {
#if LOGALL
	NSLog(@"HAI OUTGOING ((%@))",msg);
#endif
	msg = [msg stringByAppendingString:@"\r\n"];
	hasPendingBites = YES;
	static NSMutableString *cacheLine = nil;
	if (isRegistered && !!cacheLine) {
		[writebuf appendString:cacheLine];
		[cacheLine release];
		cacheLine = nil;
	}
	if (isRegistered || !canWait) {
		[writebuf appendString:msg];
	}
	else {
		cacheLine = [[NSMutableString alloc] init];
		[cacheLine appendString:cacheLine];
	}
	return YES;
}

- (void)errorOccured:(NSError *)error {
	NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)recievedMessage:(NSString *)msg {
#if LOGALL
    NSLog(@"%@", msg);
#endif
	if ([msg isEqualToString:@""] || msg == nil || [msg isEqualToString:@"\r\n"]) return;
	msg = [msg stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	msg = [msg stringByReplacingOccurrencesOfString:@"\n" withString:@""];	
	if ([msg hasPrefix:@"PING"]) {
		[self handlePING:msg];
		return;
	}
	else if ([msg hasPrefix:@"ERROR"]) {
		//handle..
		NSLog(@"Errorz. %@:%@", msg, server);
		NSString *error = [msg substringWithRange:NSMakeRange(5, [msg length]-5)];
		if ([error hasPrefix:@" :"]) error = [error substringFromIndex:2];
        @synchronized(self) {
            RCChannel *chan = [self consoleChannel];
            [chan recievedMessage:error from:@"" type:RCMessageTypeNormal];
        }
		[self disconnectWithMessage:error];
		return;
	}
	else if ([msg hasPrefix:@"@"]) {
		// sending these messages somewhere else.
		// not handling them here.
		//msg = [msg substringFromIndex:1];
		//	NSDateFormatter *df = [[NSDateFormatter alloc] init];
		//[df setDateFormat:@"YYYY-MM-DDThh:mm:ss.sssZ"];
		//	NSDate *aDate = [df dateFromString:nil];
		NSLog(@"IRV3 I C. %@", msg);
		return;
	}
	if (![msg hasPrefix:@":"]) {
		if ([msg hasPrefix:@"AUTHENTICATE"]) {
			[self sendB64SASLAuth];
		}
		return;
	}
	NSScanner *scanner = [[NSScanner alloc] initWithString:msg];
	NSString *crap = @"";
	NSString *cmd = crap;
	NSString *rest = cmd;
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner scanUpToString:@" " intoString:&cmd];
	[scanner scanUpToString:@"\r\n" intoString:&rest];
	NSString *selName = [NSString stringWithFormat:@"handle%@:", cmd];
	SEL pSEL = NSSelectorFromString(selName);
	if ([self respondsToSelector:pSEL]) [self performSelector:pSEL withObject:msg];
	else {
		RCChannel *chan = [self consoleChannel];
		[chan recievedMessage:rest from:@"" type:RCMessageTypeNormal];
		NSLog(@"PLZ IMPLEMENT %s %@", sel_getName(pSEL), msg);
		NSLog(@"Meh. %@\r\n%@", cmd, rest);	
	}
	[scanner release];
}

- (BOOL)isTryingToConnectOrConnected {
    return ([self isConnected] || tryingToConnect);
}

- (NSString *)defaultQuitMessage {
    return @"Relay 1.0"; // TODO: return something else if user wants to
}

- (BOOL)disconnectWithMessage:(NSString *)msg {
    if (_isDisconnecting) return NO;
	_isDisconnecting = YES;
	if (status == RCSocketStatusClosed) return NO;
	if ((status == RCSocketStatusConnected) || (status == RCSocketStatusConnecting)) {
		[self sendMessage:[@"QUIT :" stringByAppendingString:([msg isEqualToString:@"Disconnected."] ? [self defaultQuitMessage] : msg)] canWait:NO];
		status = RCSocketStatusClosed;
		close(sockfd);
		[rcache release];
		sockfd = -1;
		[cache release];
		[writebuf release];
		if (useSSL)
			SSL_CTX_free(ctx);
		[[UIApplication sharedApplication] endBackgroundTask:task];
		task = UIBackgroundTaskInvalid;
		status = RCSocketStatusClosed;
		isRegistered = NO;
		for (RCChannel *_chan in _channels) {
			[_chan disconnected:msg];
		}
	}
	_isDisconnecting = NO;
	return YES;
}

- (BOOL)disconnect {
    return [self disconnectWithMessage:@"Disconnected."];
}

- (void)networkDidRegister:(BOOL)reg {
	// do jOC (join on connect) rooms
	isRegistered = YES;
	RCChannel *chan = [self consoleChannel];
	if (chan) [chan recievedMessage:@"Connected to host." from:@"" type:RCMessageTypeNormal];
	if ([npass length] > 0)	[self sendMessage:[@"PRIVMSG NickServ :IDENTIFY " stringByAppendingString:npass]];
	NSMutableString *joinList = [[NSMutableString alloc] initWithString:@"JOIN "];
	if ([_channels count] > 1) {
		for (RCChannel *chan in _channels) {
			if (![chan isKindOfClass:[RCConsoleChannel class]] && ![chan isKindOfClass:[RCPMChannel class]]) {
				if ([chan joinOnConnect]) {
					[joinList appendFormat:@"%@,", [chan channelName]];
				}
			}
		}
		if ([joinList hasSuffix:@","]) {
			[joinList deleteCharactersInRange:NSMakeRange([joinList length]-1, 1)];
		}
		[self sendMessage:joinList];
		[joinList release];
	}
}

- (BOOL)isConnected {
	return (status == RCSocketStatusConnected);
}

- (void)sendB64SASLAuth {
	NSString *b64 = [[NSString stringWithFormat:@"%@\0%@0%@", useNick, useNick, npass] base64];
	[self sendMessage:[NSString stringWithFormat:@"AUTHENTICATE %@", b64] canWait:NO];
}

- (void)handle001:(NSString *)welcome {
	status = RCSocketStatusConnected;
	[self networkDidRegister:YES];
	NSScanner *scanner = [[NSScanner alloc] initWithString:welcome];
	NSString *crap;
	NSString *meee = nil;
	@try {
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@" " intoString:&meee];
		[scanner setScanLocation:[scanner scanLocation]+1];
		[scanner scanUpToString:@"" intoString:&crap];
	}
	@catch (NSException *exception) {
		MARK;
	}
	useNick = [meee retain];
	//:Welcome to the IRCNode Internet Relay Chat Network Maximus|ZNC
#if LOGALL
	NSLog(@"WAT IS HAPPENING %@ %@", useNick, welcome);
#endif
	if ([crap hasPrefix:@":"]) crap = [crap substringFromIndex:1];
	RCChannel *chan = [self consoleChannel];
	if (chan) [chan recievedMessage:crap from:@"" type:RCMessageTypeNormal];
	[scanner release];
	reloadNetworks();
}

- (void)handle002:(NSString *)infos {
	NSScanner *scanner = [[NSScanner alloc] initWithString:infos];
	NSString *crap;
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner setScanLocation:[scanner scanLocation]+1];
	[scanner scanUpToString:@"\r\n" intoString:&crap];
	if ([crap hasPrefix:@":"]) crap = [crap substringFromIndex:1];
	RCChannel *chan = [self consoleChannel];
	if (chan) [chan recievedMessage:crap from:@"" type:RCMessageTypeNormal];
	[scanner release];
	// Relay[2626:f803] MSG: :fr.ac3xx.com 002 _m :Your host is fr.ac3xx.com, running version Unreal3.2.9
}

- (void)handle003:(NSString *)servInfos {
	NSScanner *scanner = [[NSScanner alloc] initWithString:servInfos];
	NSString *crap;
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner setScanLocation:[scanner scanLocation]+1];
	[scanner scanUpToString:@"\r\n" intoString:&crap];
    
	if ([crap hasPrefix:@":"]) crap = [crap substringFromIndex:1];
	RCChannel *chan = [self consoleChannel];
	if (chan) [chan recievedMessage:crap from:@"" type:RCMessageTypeNormal];
	[scanner release];
	// Relay[2626:f803] MSG: :fr.ac3xx.com 003 _m :This server was created Fri Dec 23 2011 at 01:21:01 CET
}

- (void)handle004:(NSString *)othrInfo {
	NSScanner *scanner = [[NSScanner alloc] initWithString:othrInfo];
	NSString *crap;
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner setScanLocation:[scanner scanLocation]+1];
	[scanner scanUpToString:@"\r\n" intoString:&crap];
	if ([crap hasPrefix:@":"]) crap = [crap substringFromIndex:1];
	RCChannel *chan = [self consoleChannel];
	if (chan) [chan recievedMessage:crap from:@"" type:RCMessageTypeNormal];
	[scanner release];
	// Relay[2626:f803] MSG: :fr.ac3xx.com 004 _m fr.ac3xx.com Unreal3.2.9 iowghraAsORTVSxNCWqBzvdHtGp 
}

- (void)handle005:(NSString *)useInfo {
	@synchronized(self) {
		NSArray *args = [useInfo componentsSeparatedByString:@" "];
		args = [args subarrayWithRange:NSMakeRange(3, [args count]-3)];
		for (NSString* arg in args) {
			if ([arg hasSuffixNoCase:@":are supported by this server"]) {
				break;
			}
#if LOGALL
			NSLog(@"> %@", arg);
#endif
			NSArray *values = [arg componentsSeparatedByString:@"="];
			@try {
                if ([values count]) {
                    if ([[values objectAtIndex:0] isEqualToString:@"PREFIX"]) {
                        if ([values count] - 1) {
#if LOGALL
                            NSLog(@"prefix is %@", [values objectAtIndex:1]);
#endif
                            NSString *lprefix = [values objectAtIndex:1];
                            if ([lprefix hasPrefix:@"("]) {
                                lprefix = [lprefix substringFromIndex:1];
                                int prefixes = [lprefix rangeOfString:@")"].location;
                                NSString* values = [lprefix substringFromIndex:prefixes+1];
                                NSString* modes  = [lprefix substringToIndex:prefixes];
                                NSMutableDictionary* lprefix = [NSMutableDictionary new];
								for (int i = 0; i < [values length]; i++) {
									unichar chr = [values characterAtIndex:i];
									NSString *string = [[[NSString alloc] initWithCharacters:&chr length:1] autorelease];
									unichar chra = [modes characterAtIndex:i];
									NSString *stringa = [[[NSString alloc] initWithCharacters:&chra length:1] autorelease];
									[lprefix setObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:i], string, nil] forKey:stringa];
                                    // Do stuff...
                                }
								self.prefix = [[lprefix copy] autorelease];
								[lprefix release];
#if LOGALL
								NSLog(@"prefix: %@", prefix);
#endif
							}
						}
					}
				}
			}
			@catch (NSException *exception) {
				NSLog(@"exc %@", exception);
			}
		}
	}
    /*
	NSScanner *scanr = [[NSScanner alloc] initWithString:useInfo];
	NSString *crap;
	NSString *args;
	[scanr scanUpToString:@" " intoString:&crap];
	[scanr scanUpToString:@" " intoString:&crap];
	[scanr scanUpToString:@" " intoString:&crap];
	[scanr scanUpToString:@" " intoString:&args];
	NSArray *argsArray = [args componentsSeparatedByString:@" "];
	NSLog(@"Meh. %@", argsArray);
	for (NSString *arg in argsArray) {
		if ([arg hasPrefix:@"TOPICLEN"]) {
		}
		else if ([arg hasPrefix:@"STATUSMSG"]) {
			maxStatusLength = [[arg substringFromIndex:[@"STATUSMSG" length]] intValue];
		}
		else if ([arg hasPrefix:@"CHANTYPES"]) {
			
		}
		else if ([arg hasPrefix:@"PREFIX"]) {
            @try {
                arg = [arg substringFromIndex:6];
                NSLog(@">>>>> OMFG <<<<< >>>>> %@", arg);
                if ([arg hasPrefix:@"="]) {
                    arg = [arg substringFromIndex:1];
                    if ([arg hasPrefix:@"("]) {
                        NSString* modes = [arg substringWithRange:NSMakeRange(1, [arg rangeOfString:@")"].location)];
                        NSString* prefixes = [arg substringWithRange:NSMakeRange(1, [arg rangeOfString:@")"].location)];
                        NSLog(@"[%@] | [%@]", modes, prefixes);
                        
                    }
                }
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }

			NSScanner *scanr = [[NSScanner alloc] initWithString:arg];
			NSString *crap;
			NSString *mds;
			[scanr scanUpToString:@")" intoString:&crap];
			[scanr scanUpToString:@"" intoString:&mds];
			[scanr release];
			self.userModes = mds;
		}
		else {
			NSLog(@"NO SUPPORT FOR %@ YET. :/", arg);
		}	
	}
	[scanr release];*/
	// Relay[2794:f803] MSG: :fr.ac3xx.com 005 _m WALLCHOPS WATCH=128 WATCHOPTS=A SILENCE=15 MODES=12 CHANTYPES=# PREFIX=(qaohv)~&@%+ CHANMODES=beI,kfL,lj,psmntirRcOAQKVCuzNSMTGZ NETWORK=ROXnet CASEMAPPING=ascii EXTBAN=~,qjncrR ELIST=MNUCT STATUSMSG=~&@%+ :are supported by this server
}

- (void)handle042:(NSString *)msg {
	
}

- (void)handle252:(NSString *)opsOnline {
	NSScanner *scanner = [[NSScanner alloc] initWithString:opsOnline];
	NSString *crap;
	@try {
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner setScanLocation:[scanner scanLocation]+1];
		[scanner scanUpToString:@"" intoString:&crap];
	}
	@catch (NSException *exception) {
		MARK;
	}
	if ([crap hasPrefix:@":"]) crap = [crap substringFromIndex:1];
	RCChannel *chan = [self consoleChannel];
	if (chan) [chan recievedMessage:crap from:@"" type:RCMessageTypeNormal];
	[scanner release];
	// :irc.saurik.com 252 _m 2 :operator(s) online
}

- (void)handle250:(NSString *)countr {
	// :hubbard.freenode.net 250 Guest01 :Highest connection count: 3549 (3548 clients) (177981 connections received)	
}

- (void)handle251:(NSString *)infos {
	NSScanner *scanner = [[NSScanner alloc] initWithString:infos];
	NSString *crap;
	@try {
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner setScanLocation:[scanner scanLocation]+1];
		[scanner scanUpToString:@"" intoString:&crap];
	}
	@catch (NSException *exception) {
		MARK;
	}
	if ([crap hasPrefix:@":"]) crap = [crap substringFromIndex:1];
	RCChannel *chan = [self consoleChannel];
	if (chan) [chan recievedMessage:crap from:@"" type:RCMessageTypeNormal];
	[scanner release];
	// Relay[3067:f803] MSG: :fr.ac3xx.com 251 _m :There are 1 users and 4 invisible on 1 servers
}

- (void)handle253:(NSString *)unknown {
	//:hubbard.freenode.net 253 Guest01 3 :unknown connection(s)	
}

- (void)handle254:(NSString *)rooms {
	// number of channels active
}

- (void)handle255:(NSString *)clients {
	// number of clients. 
}

- (void)handle265:(NSString *)local {
	// Relay[2794:f803] MSG: :fr.ac3xx.com 265 _m :Current Local Users: 5  Max: 7
}

- (void)handle266:(NSString *)global {
	// Relay[2794:f803] MSG: :fr.ac3xx.com 266 _m :Current Global Users: 5  Max: 6
}

- (void)handle303:(NSString *)wee {
	// not really sure what to do here. kind of stupid actually. hm :/
}

- (void)handle305:(NSString *)athreeo_five {
	NSLog(@"Implying this is a znc.");
	NSLog(@"YAY I'M NO LONGER AWAY.");
	//	if ([[[[[RCNavigator sharedNavigator] currentPanel] channel] delegate] isEqual:self]) {
	//	[[[RCNavigator sharedNavigator] currentPanel] postMessage:@"You are no longer being marked as away" withType:RCMessageTypeEvent	highlight:NO];
	//}
}

- (void)handle301:(NSString *)nickIsAway {
	NSLog(@"HI %@", nickIsAway);
}

- (void)handle306:(NSString *)znc {
	NSLog(@"Implying this is a znc.");
	NSScanner *scanner = [[NSScanner alloc] initWithString:znc];
	NSString *crap;
	NSString *cmd;
	NSString *me;
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner scanUpToString:@" " intoString:&cmd];
	[scanner scanUpToString:@" " intoString:&me];
	@synchronized(useNick) {
		self.useNick = me;
	}
	[scanner release];
	// :fr.ac3xx.com 305 MaxZNC :You are no longer marked as being away
}

- (void)handle311:(NSString *)hiwhois {
	NSScanner *scanr = [[NSScanner alloc] initWithString:hiwhois];
	NSString *crap = nil;
	NSString *nick_ = nil;
	NSString *infos = nil;
	[scanr scanUpToString:@" " intoString:&crap];
	[scanr scanUpToString:@" " intoString:&crap];
	[scanr scanUpToString:@" " intoString:&crap];
	[scanr scanUpToString:@" " intoString:&nick_];
	[scanr scanUpToString:@"" intoString:&infos];
	[scanr release];
	NSString *username_ = nil;
	scanr = [[NSScanner alloc] initWithString:infos];
	[scanr scanUpToString:@":" intoString:&username_];
	[scanr scanUpToString:@"" intoString:&crap]; // crap = realname
	username_ = [username_ stringByReplacingOccurrencesOfString:@"*" withString:@""];
	username_ = [username_ recursivelyRemoveSuffix:@" "];
	username_ = [username_ stringByReplacingOccurrencesOfString:@" " withString:@"@"];
	if ([crap hasPrefix:@":"])
		crap = [crap substringFromIndex:1];
	RCPMChannel *chan = (RCPMChannel *)[self channelWithChannelName:[nick_ stringByReplacingOccurrencesOfString:@" " withString:@""]];
	if (!chan) {
		RCChannel *_chan = [[[RCChatController sharedController] currentPanel] channel];
		if (![[_chan delegate] isEqual:self])
			_chan = [self consoleChannel];
		[_chan recievedMessage:[NSString stringWithFormat:@"has user host %@ and real name \"%@\"", username_, crap] from:nick_ type:RCMessageTypeEvent];
		[scanr release];
		return;
	}
	if ([chan isKindOfClass:[RCPMChannel class]]) {
		[chan setIpInfo:infos];
	}
	[scanr release];
}

- (void)handle312:(NSString *)threetwelve {
	NSScanner *scanr = [[NSScanner alloc] initWithString:threetwelve];
	NSString *crap = nil;
	NSString *nick_ = nil;
	NSString *infos = nil;
	[scanr scanUpToString:@" " intoString:&crap];
	[scanr scanUpToString:@" " intoString:&crap];
	[scanr scanUpToString:@" " intoString:&crap];
	[scanr scanUpToString:@" " intoString:&nick_];
	[scanr scanUpToString:@"" intoString:&infos];
	///infos = [infos substringWithRange:NSMakeRange(0, ([infos rangeOfString:@":"].location))];
	infos = [infos stringByReplacingOccurrencesOfString:@":" withString:@"("];
	infos = [infos stringByAppendingString:@")"];
	RCPMChannel *chan = (RCPMChannel *)[self channelWithChannelName:[nick_ stringByReplacingOccurrencesOfString:@" " withString:@""]];
	if (!chan) {
		RCChannel *_chan = [[[RCChatController sharedController] currentPanel] channel];
		if (![[_chan delegate] isEqual:self])
			_chan = [self consoleChannel];
		[_chan recievedMessage:[NSString stringWithFormat:@"is connected to %@", infos] from:nick_ type:RCMessageTypeEvent];
		[scanr release];
		return;
	}
	if ([chan isKindOfClass:[RCPMChannel class]]) {
		[chan setConnectAddr:infos];
	}
	[scanr release];
}

- (void)handle313:(NSString *)badassIRCOP {
	MARK;
}

- (void)handle318:(NSString *)threeeighteen {
	NSScanner *scanr = [[NSScanner alloc] initWithString:threeeighteen];
	NSString *crap = nil;
	NSString *nick_ = nil;
	NSString *infos = nil;
	[scanr scanUpToString:@" " intoString:&crap];
	[scanr scanUpToString:@" " intoString:&crap];
	[scanr scanUpToString:@" " intoString:&crap];
	[scanr scanUpToString:@" " intoString:&nick_];
	[scanr scanUpToString:@"" intoString:&infos];
	RCPMChannel *chan = (RCPMChannel *)[self channelWithChannelName:[nick_ stringByReplacingOccurrencesOfString:@" " withString:@""]];
	if ([chan isKindOfClass:[RCPMChannel class]]) {
		if ([[[[RCChatController sharedController] currentPanel] channel] isEqual:chan]) {
			[[RCChatController sharedController] performSelectorOnMainThread:@selector(pushUserListWithDefaultDuration) withObject:nil waitUntilDone:NO];
		}
	}
	[scanr release];
}

- (void)handle319:(NSString *)threenineteen {
	// :irc.saurik.com 319 Snowman theiostream :#substrate #iOSOpenDev # @#spotlightplus #TweakIdeas #teambacon @#op #geordi #relay @#math @#ll #oligos
	NSScanner *scanr = [[NSScanner alloc] initWithString:threenineteen];
	NSString *crap = nil;
	NSString *nick_ = nil;
	NSString *infos = nil;
	[scanr scanUpToString:@" " intoString:&crap];
	[scanr scanUpToString:@" " intoString:&crap];
	[scanr scanUpToString:@" " intoString:&crap];
	[scanr scanUpToString:@" " intoString:&nick_];
	[scanr scanUpToString:@"" intoString:&infos];
	if ([infos hasPrefix:@":"])
		infos = [infos substringFromIndex:1];
	RCPMChannel *chan = (RCPMChannel *)[self channelWithChannelName:[nick_ stringByReplacingOccurrencesOfString:@" " withString:@""]];
	if (!chan) {
		RCChannel *_chan = [[[RCChatController sharedController] currentPanel] channel];
		if (![[_chan delegate] isEqual:self])
			_chan = [self consoleChannel];
		[_chan recievedMessage:[NSString stringWithFormat:@"is in %@", infos] from:nick_ type:RCMessageTypeEvent];
		[scanr release];
		return;
	}
	if ([chan isKindOfClass:[RCPMChannel class]]) {
		if ([infos hasPrefix:@":"])
			infos = [infos substringFromIndex:1];
		[chan setChanInfos:infos];
	}
	[scanr release];
}

- (void)handle322:(NSString *)threetwotwo {
	if (!namesCallback) return;
	NSScanner *hi = [[NSScanner alloc] initWithString:threetwotwo];
	NSString *crap = NULL;
	NSString *chan = NULL;
	NSString *count = NULL;
	NSString *topicModes = NULL;
	[hi scanUpToString:useNick intoString:&crap];
	[hi scanUpToString:@" " intoString:&crap];
	[hi scanUpToString:@" " intoString:&chan];
	[hi scanUpToString:@" " intoString:&count];
	[hi scanUpToString:@"\r\n" intoString:&topicModes];
	chan = [chan stringByReplacingOccurrencesOfString:@" " withString:@""];
	count = [count stringByReplacingOccurrencesOfString:@" " withString:@""];
	if ([topicModes length] > 1)
		topicModes = [topicModes substringFromIndex:1];
	if ([topicModes isEqualToString:@" "]) topicModes = nil;
	if ([topicModes hasPrefix:@" "]) topicModes = [topicModes recursivelyRemovePrefix:@" "];
	//[namesCallback recievedChannel:chan withCount:[count intValue] andTopic:topicModes];
	NSLog(@"eeee %@:%@:%@",chan,count,topicModes);
	[hi release];
	// :irc.saurik.com 322 mx_ #testing 1 :[+nt]
}

- (void)handle323:(NSString *)endofchannellistning {
	[namesCallback removeStupidWarningView];
}

- (void)handle331:(NSString *)noTopic {
    [self handle332:noTopic];
	// Relay[18195:707] MSG: :irc.saurik.com 331 _m #kk :No topic is set.
}

- (void)handle332:(NSString *)topic {
	NSScanner *_scanner = [[NSScanner alloc] initWithString:topic];
	NSString *crap = @"_";
	NSString *to = crap;
	NSString *room = to;
	NSString *_topic = room;
	[_scanner scanUpToString:@" " intoString:&crap];
	[_scanner scanUpToString:@" " intoString:&crap];
	[_scanner scanUpToString:@" " intoString:&to];
	[_scanner scanUpToString:@" " intoString:&room];
	[_scanner scanUpToString:@"" intoString:&_topic];
    if ([_topic hasPrefix:@":"]) {
        _topic = [_topic substringFromIndex:1];
    }
	[[self channelWithChannelName:room ifNilCreate:YES] recievedMessage:_topic from:nil type:RCMessageTypeTopic];
	// :irc.saurik.com 332 _m #bacon :Bacon | where2start? kitchen | Canadian Bacon? get out. | WE SPEAK: BACON, ENGLISH, PORTUGUESE, DEUTSCH. | http://blog.craftzine.com/bacon-starry-night.jpg THIS IS YOU ¬†
	[_scanner release];
}

- (void)handle333:(NSString *)numbers {
	NSString *crap;
	NSString *chan_ = nil;
	NSString *from = nil;
	NSString *time = nil;
	NSScanner *scanr = [[NSScanner alloc] initWithString:numbers];
	[scanr scanUpToString:@" " intoString:&crap];
	[scanr scanUpToString:@" " intoString:&crap];
	[scanr scanUpToString:@" " intoString:&crap];
	[scanr scanUpToString:@" " intoString:&chan_];
	[scanr scanUpToString:@" " intoString:&from];
	[scanr scanUpToString:@" " intoString:&time];
	time_t unixTime = [time intValue]; // seems to work just fine.
	char buffer[128];
	struct tm *info;
	info = localtime(&unixTime);
	strftime(buffer, 128, "%+", info);
	NSString *normalTime = [NSString stringWithCString:buffer encoding:NSUTF8StringEncoding];
	RCParseUserMask(from, &from, nil, nil);
	RCChannel *chan = [self channelWithChannelName:chan_];
	[chan recievedMessage:[NSString stringWithFormat:@"Set by %@ on %@", from, normalTime] from:nil type:RCMessageTypeNormalE];
	// :irc.saurik.com 333 _m #bacon Bacon!~S_S@adsl-184-33-54-96.mia.bellsouth.net 1329680840
}

- (void)handle353:(NSString *)_users {
	NSScanner *scanner = [[NSScanner alloc] initWithString:_users];
	NSString *crap;
	NSString *me;
	NSString *room;
	NSString *users;
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner scanUpToString:@" " intoString:&me];
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner scanUpToString:@" " intoString:&room];
	[scanner scanUpToString:@"" intoString:&users];
	if ([users length] > 1) {
		users = [users substringFromIndex:1];
		NSArray *_someUsers = [users componentsSeparatedByString:@" "];
		RCChannel *chan = [self channelWithChannelName:room];
		if (chan) {
			for (NSString *user in _someUsers) {
				[chan setUserJoined:user];
			}
		}
	}
	[scanner release];
    //	add users to room listing..
}
- (void)handle366:(NSString *)end {
	// end of /NAMES list
}

- (void)handle375:(NSString *)motd {
	if (![[RCNetworkManager sharedNetworkManager] _printMotd]) return;
	NSScanner *scanner = [[NSScanner alloc] initWithString:motd];
	NSString *crap;
	@try {
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@"" intoString:&crap];
        if ([crap hasPrefix:@":"]) crap = [crap substringFromIndex:1];
        RCChannel *chan = [self consoleChannel];
        if (chan) [chan recievedMessage:crap from:@" MOTD" type:RCMessageTypeNormal];
	}
	@catch (NSException *exception) {
		MARK;
	}
	[scanner release];
	// :irc.saurik.com 375 _m :irc.saurik.com message of the day
}

- (void)handle372:(NSString *)noMotd {
	if (![[RCNetworkManager sharedNetworkManager] _printMotd]) return;
	NSScanner *scanner = [[NSScanner alloc] initWithString:noMotd];
	NSString *crap;
	@try {
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner setScanLocation:[scanner scanLocation]+1];
		[scanner scanUpToString:@"" intoString:&crap];
	}
	@catch (NSException *exception) {
		MARK;
	}
	if ([crap hasPrefix:@":"]) crap = [crap substringFromIndex:1];
	RCChannel *chan = [self consoleChannel];
	if (chan) [chan recievedMessage:crap from:@" MOTD" type:RCMessageTypeNormal];
	[scanner release];
	// :irc.saurik.com 372 _m :- Please edit /etc/inspircd/motd
}

- (void)handle376:(NSString *)endOfMotd {
	// :irc.saurik.com 376 _m :End of message of the day.
}

- (void)handle401:(NSString *)blasphemey {
	// no such nick/channel
}

- (void)handle403:(NSString *)blasphemey {
	// no such channel
}

- (void)handle404:(NSString *)args {
    if ([args hasPrefix:@":"]) {
        args = [args substringFromIndex:[args rangeOfString:@" "].location+1];
    }
    NSScanner *scanner = [NSScanner scannerWithString:args];
    NSString* raw = @"";
    NSString* mnick = @"";
    NSString* chan = @"";
    NSString* mesg = @"";
    [scanner scanUpToString:@" " intoString:&raw];
    if (![raw isEqualToString:@"404"]) {
        return;
    }
    [scanner scanUpToString:@" " intoString:&mnick];
    [scanner scanUpToString:@" " intoString:&chan];
    [scanner scanUpToString:@"" intoString:&mesg];
    if ([mesg hasPrefix:@":"]) {
        mesg = [mesg substringFromIndex:1];
    }
    RCChannel *kchan = [self channelWithChannelName:chan];
	if (kchan) [kchan recievedMessage:mesg from:@"" type:RCMessageTypeError];
}

- (void)handle420:(NSString *)blunt {
	NSLog(@"DAFUQ %@", blunt);
}

- (void)handle421:(NSString *)unknown {
	// means we sent a message that is so illogical, fuck you
	NSString *crap = NULL;
	NSString *msg = nil;
	NSScanner *scan = [[NSScanner alloc] initWithString:unknown];
	[scan scanUpToString:@"421" intoString:&crap];
	[scan scanUpToString:@" " intoString:&crap];
	[scan scanUpToString:@" " intoString:&crap];
	[scan scanUpToString:@":" intoString:&msg];
	// considering this logical only in the case that there is an issue with network connectivity and the user
	// is able to switch channels before getting a response from the network.
	RCChannel *currentChannel_ = [[[RCChatController sharedController] currentPanel] channel];
	RCChannel *target = [self consoleChannel];
	// the check below fails. make better comparison method max.
	if ([[currentChannel_ delegate] isEqual:self]) {
		target = currentChannel_;
	}
	[currentChannel_ recievedMessage:[NSString stringWithFormat:@"Error(421): %@ Unknown Command", [msg uppercaseString]] from:nil type:RCMessageTypeError];
	[scan release];
}

- (void)handle422:(NSString *)motd {
	NSLog(@"Ohai. %@", motd);
}

- (void)handle433:(NSString *)use {
	// nick is in use.
    self.useNick = [useNick stringByAppendingString:@"_"];
	[self sendMessage:[@"NICK " stringByAppendingString:useNick] canWait:NO];
}

- (void)handle437:(NSString *)args {
    if ([args hasPrefix:@":"]) {
        args = [args substringFromIndex:[args rangeOfString:@" "].location+1];
    }
    NSScanner *scanner = [NSScanner scannerWithString:args];
    NSString* raw = @"";
    NSString* mnick = @"";
    NSString* chan = @"";
    NSString* mesg = @"";
    [scanner scanUpToString:@" " intoString:&raw];
    if (![raw isEqualToString:@"437"]) {
        return;
    }
    [scanner scanUpToString:@" " intoString:&mnick];
    [scanner scanUpToString:@" " intoString:&chan];
    [scanner scanUpToString:@"" intoString:&mesg];
    if ([mesg hasPrefix:@":"]) {
        mesg = [mesg substringFromIndex:1];
    }
    RCChannel *kchan = [self channelWithChannelName:chan];
	if (kchan) [kchan recievedMessage:mesg from:@"" type:RCMessageTypeError];
    [[self consoleChannel] recievedMessage:mesg from:chan type:RCMessageTypeNormal];
    NSLog(@"kay %@ %@ %@", raw, chan, mesg);
}

- (void)handle473:(NSString *)args {
	if ([args hasPrefix:@":"]) {
		args = [args substringFromIndex:[args rangeOfString:@" "].location+1];
	}
	NSScanner *scanner = [NSScanner scannerWithString:args];
	NSString* raw = @"";
	NSString* mnick = @"";
	NSString* chan = @"";
	NSString* mesg = @"";
	[scanner scanUpToString:@" " intoString:&raw];
	if (![raw isEqualToString:@"473"]) {
		return;
	} // really not necessary.
	[scanner scanUpToString:@" " intoString:&mnick];
	[scanner scanUpToString:@" " intoString:&chan];
	[scanner scanUpToString:@"" intoString:&mesg];
	if ([mesg hasPrefix:@":"]) {
		mesg = [mesg substringFromIndex:1];
	}
	RCChannel *kchan = [self channelWithChannelName:chan];
	if (kchan) [kchan recievedMessage:mesg from:@"" type:RCMessageTypeError];
	else [[self consoleChannel] recievedMessage:[args substringFromIndex:[[args substringFromIndex:[args rangeOfString:@" "].location+1] rangeOfString:@" "].location+1] from:@"" type:RCMessageTypeNormal];
    NSLog(@"kay %@ %@ %@", raw, chan, mesg);
}

- (void)handle474:(NSString *)args {
    if ([args hasPrefix:@":"]) {
        args = [args substringFromIndex:[args rangeOfString:@" "].location+1];
    }
    NSScanner *scanner = [NSScanner scannerWithString:args];
    NSString* raw = @"";
    NSString* mnick = @"";
    NSString* chan = @"";
    NSString* mesg = @"";
    [scanner scanUpToString:@" " intoString:&raw];
    if (![raw isEqualToString:@"474"]) {
        return;
    }
    [scanner scanUpToString:@" " intoString:&mnick];
    [scanner scanUpToString:@" " intoString:&chan];
    [scanner scanUpToString:@"" intoString:&mesg];
    if ([mesg hasPrefix:@":"]) {
        mesg = [mesg substringFromIndex:1];
    }
    RCChannel *kchan = [self channelWithChannelName:chan];
	if (kchan) [kchan recievedMessage:mesg from:@"" type:RCMessageTypeError];
    else [[self consoleChannel] recievedMessage:[args substringFromIndex:[[args substringFromIndex:[args rangeOfString:@" "].location+1] rangeOfString:@" "].location+1] from:@"" type:RCMessageTypeNormal];
}

- (void)handle475:(NSString *)args {
    if ([args hasPrefix:@":"]) {
        args = [args substringFromIndex:[args rangeOfString:@" "].location+1];
    }
    NSScanner *scanner = [NSScanner scannerWithString:args];
    NSString* raw = @"";
    NSString* mnick = @"";
    NSString* chan = @"";
    NSString* mesg = @"";
    [scanner scanUpToString:@" " intoString:&raw];
    if (![raw isEqualToString:@"475"]) {
        return;
    }
    [scanner scanUpToString:@" " intoString:&mnick];
    [scanner scanUpToString:@" " intoString:&chan];
    [scanner scanUpToString:@"" intoString:&mesg];
    if ([mesg hasPrefix:@":"]) {
        mesg = [mesg substringFromIndex:1];
    }
    RCChannel *kchan = [self channelWithChannelName:chan];
	if (kchan) [kchan recievedMessage:mesg from:@"" type:RCMessageTypeError];
    else [[self consoleChannel] recievedMessage:[args substringFromIndex:[[args substringFromIndex:[args rangeOfString:@" "].location+1] rangeOfString:@" "].location+1] from:@"" type:RCMessageTypeNormal];
    NSLog(@"kay %@ %@ %@", raw, chan, mesg);
}

- (void)handle903:(NSString *)saslsuc {
	[self sendMessage:@"CAP END"];
}

- (void)handle904:(NSString *)saslsucks {
	[[self consoleChannel] recievedMessage:@"SASL Authentication failed." from:nil type:RCMessageTypeNormal];
}

- (void)handle998:(NSString *)fuckyouumich {
	if (!fuckyouumich) return; //there's never a time where fuck umich is not true. FUCK YOU UMICH.
	NSLog(@"FUCK. YOU. UMICH:%@",fuckyouumich);
	@synchronized(self) {

		NSString *asciiz;
		NSString *crap;
		NSScanner *scanr = [[NSScanner alloc] initWithString:fuckyouumich];
		[scanr scanUpToString:@" " intoString:&crap];
		[scanr scanUpToString:@":" intoString:&crap];
		[scanr setScanLocation:[scanr scanLocation]+1];
		[scanr scanUpToString:@"" intoString:&asciiz];
		if (asciiz) {
			RCChannel *chan = [self consoleChannel];
			[chan recievedMessage:asciiz from:@"" type:RCMessageTypeNormalE];
		}
		[scanr release];
	}
}

- (void)handleNOTICE:(NSString *)notice {
	NSScanner *_scans = [[NSScanner alloc] initWithString:notice];
	NSString *from = @"_";
	NSString *cmd = from;
	NSString *to = cmd;
	NSString *msg = to;
	[_scans scanUpToString:@" " intoString:&from];
	[_scans scanUpToString:@" " intoString:&cmd];
	[_scans scanUpToString:@" " intoString:&to];
	if ([to isEqualToStringNoCase:@"Auth"]) {
		[_scans release];
		return;
	}
	RCParseUserMask(from, &from, nil, nil);
	[_scans scanUpToString:@"" intoString:&msg];
	if ([nick isEqualToString:useNick]) {
		msg = [msg substringFromIndex:1];
	}
	from = [from substringFromIndex:1];
	if ([[RCChatController sharedController] currentPanel]) {
		if ([[[[[RCChatController sharedController] currentPanel] channel] delegate] isEqual:self]) {
			[[[[RCChatController sharedController] currentPanel] channel] recievedMessage:msg from:from type:RCMessageTypeNotice];
		}
		else {
			goto end;
		}
	}
	else {
	end:{
		RCChannel *chan = [self consoleChannel];
		[chan recievedMessage:msg from:from type:RCMessageTypeNotice];
	}
	}
	
	[_scans release];
	//:Hackintech!Hackintech@2FD03E27.3D6CB32E.E0E5D6BD.IP NOTICE __m__ :HI
}

- (void)handlePRIVMSG:(NSString *)privmsg {
	NSScanner *_scanner = [[NSScanner alloc] initWithString:privmsg];
	NSString *from = @"";
	NSString *cmd = from; // will be unused.
	NSString *room = from;
	NSString *msg = from;
	[_scanner scanUpToString:@" " intoString:&from];
	[_scanner scanUpToString:@" " intoString:&cmd];
	[_scanner scanUpToString:@" " intoString:&room];
	[_scanner scanUpToString:@"" intoString:&msg];
	msg = [msg substringFromIndex:1];
	from = [from substringFromIndex:1];
	RCParseUserMask(from, &from, nil, nil);
	if ([msg hasPrefix:@"\x01"] && [msg hasSuffix:@"\x01"]) {
		msg = [msg substringFromIndex:1];
        msg = [msg substringToIndex:[msg length]-1];
		if ([msg hasPrefix:@"PING"]) {
			[self handlePING:privmsg];
		}
		else if ([msg hasPrefix:@"TIME"] 
				 || [msg hasPrefix:@"VERSION"] 
				 || [msg hasPrefix:@"USERINFO"] 
				 || [msg hasPrefix:@"CLIENTINFO"]) {
			[self handleCTCPRequest:privmsg];
		}
		else if ([msg hasPrefix:@"ACTION"]) {
			if ([msg length] > 7) {
				msg = [msg substringWithRange:NSMakeRange(7, msg.length-7)];
				[((RCChannel *)[self channelWithChannelName:room]) recievedMessage:msg from:from type:RCMessageTypeAction];
			}
			[_scanner release];
			return;
		}
	}
	else {
		if ([room isEqualToString:useNick]) {
			// privmsg or some other mechanical contraptiona.. :(
			room = from;
		}
		if (![self channelWithChannelName:room]) {
			// magicall.. 0.0
			// has to be a private message.
			// Reasoning: 
			// if we are registered to events from a channel,
			// we must have sent JOIN #channel;
			// which we have caught, and added the RCChannel already.
			[self addChannel:room join:YES];
		}
		// fuck this shit.
		[((RCChannel *)[self channelWithChannelName:room]) recievedMessage:msg from:from type:RCMessageTypeNormal];
		// tell the channel a message was recieved. P:
	}
	[_scanner release];
}
- (void)handleINVITE:(NSString *)invite {
    [self performSelectorOnMainThread:@selector(showInviteAlert:) withObject:invite waitUntilDone:YES];
}

- (void)showInviteAlert:(NSString*)invite{
    NSScanner *_scanner = [[NSScanner alloc] initWithString:invite];
	NSString *from = @"";
    NSString *chan = @"";
    [_scanner scanUpToString:@" " intoString:&from];
    [_scanner scanUpToString:@" " intoString:&from];
    [_scanner scanUpToString:@" " intoString:&from];
    [_scanner scanUpToString:@" " intoString:&chan];
    chan = [chan substringFromIndex:1];
	RCInviteRequestAlert *alert = [[RCInviteRequestAlert alloc] initWithTitle:[NSString stringWithFormat:@"%@",chan] message:[NSString stringWithFormat:@"%@ has invited you to %@", from, chan] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Join", nil];
	[alert show];
	[alert release];
}

- (void)handleKICK:(NSString *)aKick {
    NSLog(@"%@", aKick);
	NSScanner *_scanner = [[NSScanner alloc] initWithString:aKick];
	NSString *user = @"_";
	NSString *cmd = user;
	NSString *room = cmd;
	NSString *_nick = room;
	NSString *usr = @"";
	NSString *msg = _nick;
	[_scanner scanUpToString:@" " intoString:&user];
	[_scanner scanUpToString:@" " intoString:&cmd];
	[_scanner scanUpToString:@" " intoString:&room];
	[_scanner scanUpToString:@" " intoString:&usr];
	[_scanner scanUpToString:@"" intoString:&msg];
	user = [user substringFromIndex:1];
	if ([msg hasPrefix:@":"]) {
		msg = [msg substringFromIndex:1];
	}
	if ([msg isEqualToString:@"_"]) {
		msg = @"";
	}
	msg = [msg stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
	RCParseUserMask(user, &_nick, nil, nil);
    [[self channelWithChannelName:room] recievedMessage:(NSString*)[NSArray arrayWithObjects:usr,msg,nil] from:_nick type:RCMessageTypeKick];
	if ([usr isEqualToString:useNick]) {
        [[self channelWithChannelName:room] setJoined:NO];
	}
	[_scanner release];
}

- (void)handleNICK:(NSString *)nickChange {
	NSScanner *scanner = [[NSScanner alloc] initWithString:nickChange];
	NSString *usermask = @"";
	NSString *oldnick = @"";
	NSString *command = @"";
	NSString *newnick = @"";
	if ([nickChange hasPrefix:@":"]) {
		[scanner scanUpToString:@" " intoString:&usermask];
		RCParseUserMask(usermask, &oldnick, nil, nil);
	}
	else {
		oldnick = useNick;
	}
	[scanner scanUpToString:@" " intoString:&command];
	[scanner scanUpToString:@"" intoString:&newnick];
	[scanner release];
	if ([newnick hasPrefix:@":"]) {
#if LOGALL
		NSLog(@"a hi i am 12 and wat is thi- [%@]", [newnick substringFromIndex:1]);
#endif
		newnick = [newnick substringFromIndex:1];
	}
	if ([oldnick hasPrefix:@":"]) {
#if LOGALL
		NSLog(@"a hi i am 12 and wat is thi- [%@]", [oldnick substringFromIndex:1]);
#endif
		oldnick = [oldnick substringFromIndex:1];
	}
	if ([oldnick isEqualToString:useNick]) {
		self.useNick = newnick;
	}
	NSMutableArray *chanarr = [[NSMutableArray new] autorelease];
	@synchronized(_channels) {
		for (NSString *channel in _channels) {
			if ([[self channelWithChannelName:channel] isUserInChannel:oldnick]) {
				[chanarr addObject:[self channelWithChannelName:channel]];
			}
		}
	}
	for (RCChannel *chan in chanarr) {
		[chan changeNick:(([oldnick isEqualToString:@""] || oldnick == nil) ? @"(self)" : oldnick) toNick:newnick];
	}
}

- (void)handleCTCPRequest:(NSString *)_request {
	NSScanner *_sc = [[[NSScanner alloc] initWithString:_request] autorelease];
	NSString *_from = @"_";
	NSString *cmd = _from;
	NSString *to = cmd;
	NSString *request = to;
	NSString *extra = request;
	[_sc setScanLocation:1];
	[_sc scanUpToString:@" " intoString:&_from];
	[_sc scanUpToString:@" " intoString:&cmd];
	[_sc scanUpToString:@" " intoString:&to];
	[_sc scanUpToString:@" " intoString:&request];
	RCParseUserMask(_from, &_from, nil, nil);
    if ([request hasPrefix:@":"]) {
		request = [request substringFromIndex:1];
    }
    if (![request hasPrefix:@"\x01"]) {
		return;
    }
    if (![request hasSuffix:@"\x01"]) {
        return;
    }
    request = [request substringFromIndex:1];
    request = [request substringToIndex:[request length]-1];
    int vdx = [request rangeOfString:@" "].location;
    if (vdx == NSNotFound) {
        vdx = [request length];
    }
    NSString *command = [request substringToIndex:vdx];
#if LOGALL
	NSLog(@"Meh. %@", command);
#endif
	if ([command isEqualToString:@"TIME"])
		extra = [NSString stringWithFormat:@"%@", [NSDate date]];
	else if ([command isEqualToString:@"VERSION"]) 
		extra = @"Relay 1.0";
	else if ([command isEqualToString:@"USERINFO"]) 
		extra = @"";
	else if ([command isEqualToString:@"CLIENTINFO"]) 
		extra = @"CLIENTINFO VERSION CLIENTINFO USERINFO PING TIME UPTIME";
	else 
		NSLog(@"WTF?!?!! %@", command);
	[self sendMessage:[@"NOTICE " stringByAppendingFormat:@"%@ :\x01%@ %@\x01", _from, command, extra]];
}

- (void)handlePART:(NSString *)parted {
	NSScanner *_scanner = [[NSScanner alloc] initWithString:parted];
	NSString *user = @"_";
	NSString *cmd = user;
	NSString *room = cmd;
	NSString *_nick = room;
	NSString *msg = _nick;
	[_scanner scanUpToString:@" " intoString:&user];
	[_scanner scanUpToString:@" " intoString:&cmd];
	[_scanner scanUpToString:@" " intoString:&room];
	[_scanner scanUpToString:@"" intoString:&msg];
	user = [user substringFromIndex:1];
	if ([msg hasPrefix:@":"]) {
		msg = [msg substringFromIndex:1];
	}
	if ([msg isEqualToString:@"_"]) {
		msg = @"";
	}
	msg = [msg stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
	RCParseUserMask(user, &_nick, nil, nil);
	if ([_nick isEqualToString:useNick]) {
		NSLog(@"I went byebye. Notify the police");
        [[self channelWithChannelName:room] setJoined:NO];
        [[self channelWithChannelName:room] recievedMessage:msg from:_nick type:RCMessageTypePart];
		[_scanner release];
		return;
	}
	else {
		[[self channelWithChannelName:room] recievedMessage:msg from:_nick type:RCMessageTypePart];
	}
	[_scanner release];
}

- (void)handleJOIN:(NSString *)join {
	// add user unless self
	NSScanner *_scanner = [[NSScanner alloc] initWithString:join];
	NSString *user = @"_";
	NSString *cmd = user;
	NSString *room = cmd;
	NSString *_nick = room;
	[_scanner scanUpToString:@" " intoString:&user];
	[_scanner scanUpToString:@" " intoString:&cmd];
	[_scanner scanUpToString:@" " intoString:&room];
	user = [user substringFromIndex:1];
	if ([room hasPrefix:@" "]) room = [room substringFromIndex:1];
	if ([room hasPrefix:@":"]) room = [room substringFromIndex:1];
	room = [room stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
	RCParseUserMask(user, &_nick, nil, nil);
	if ([_nick isEqualToString:useNick]) {
		[[self addChannel:room join:NO] setSuccessfullyJoined:YES];
	}
	else {
		[[self channelWithChannelName:room] recievedMessage:nil from:_nick type:RCMessageTypeJoin];
	}
	[_scanner release];
}

- (void)handleQUIT:(NSString *)quitter {
	NSScanner *scannr = [[NSScanner alloc] initWithString:quitter];
	NSString *fullHost;
	NSString *user;
	NSString *cmd;
	NSString *msg;
	[scannr scanUpToString:@" " intoString:&fullHost];
	[scannr scanUpToString:@" " intoString:&cmd];
	[scannr scanUpToString:@"\r\n" intoString:&msg];
	fullHost = [fullHost substringFromIndex:1];
	if ([msg hasPrefix:@":"]) {
		msg = [msg substringFromIndex:1];
	}
	RCParseUserMask(fullHost, &user, nil, nil);
	for (RCChannel *chan in _channels) {
		[chan recievedMessage:msg from:user type:RCMessageTypeQuit];
	}
	[scannr release];
}

- (void)handleMODE:(NSString *)_modes {
	_modes = [_modes substringFromIndex:1];
	NSScanner *scanr = [[NSScanner alloc] initWithString:_modes];
	NSString *settr;
	NSString *cmd;
	NSString *room;
	NSString *modes;
	NSString *user = nil;
	[scanr scanUpToString:@" " intoString:&settr];
	[scanr scanUpToString:@" " intoString:&cmd];
	[scanr scanUpToString:@" " intoString:&room];
	[scanr scanUpToString:@" " intoString:&modes];
	[scanr scanUpToString:@"\r\n" intoString:&user];
	RCParseUserMask(settr, &settr, nil, nil);
	RCChannel *chan = [self channelWithChannelName:room];
	if (chan) {
		if ([room isEqualToString:useNick]) {
			[scanr release];
			return;
		}
		if (!user) {
			[chan recievedMessage:[NSString stringWithFormat:@"%@", modes] from:settr type:RCMessageTypeMode];
			[scanr release];
			return;
		}
		[chan recievedMessage:[NSString stringWithFormat:@"%@ %@", modes, user] from:settr type:RCMessageTypeMode];
		[chan setMode:modes forUser:user];
		
	}
	[scanr release];
	// Relay[2626:f803] MSG: :ac3xx!ac3xx@rox-103C7229.ac3xx.com MODE #chat +o _m
}

- (void)handlePING:(NSString *)pong {
	if ([pong hasPrefix:@"PING "]) {
		[self sendMessage:[@"PONG " stringByAppendingString:[pong substringFromIndex:5]] canWait:NO];
	}
	else {
		NSScanner *scannr = [[NSScanner alloc] initWithString:pong];
		NSString *from = @"_";
		NSString *cmd = from;
		NSString *to = from;
		NSString *msg = to;
		NSString *user = msg;
		[scannr setScanLocation:1];
		[scannr scanUpToString:@" " intoString:&from];
		[scannr scanUpToString:@" " intoString:&cmd];
		[scannr scanUpToString:@" " intoString:&to];
		[scannr scanUpToString:@" :" intoString:&msg];
        NSLog(@"<%@>", msg);
		RCParseUserMask(from, &user, nil, nil);
		[self sendMessage:[@"NOTICE " stringByAppendingFormat:@"%@ %@", user, msg]];
		[scannr release];
	}
}

- (void)handlehost:(NSString *)hostInfo {
	RCChannel *chan = [self consoleChannel];
	if (chan) {
		[chan recievedMessage:[hostInfo substringFromIndex:1] from:@"" type:RCMessageTypeNormal];
	}
	// :Your host is irc.saurik.com, running version InspIRCd-1.1.18+Gudbrandsdalsost
	// .. ... . .. .. only at irc.saurik.comm
}

- (void)handleTOPIC:(NSString *)topic {
	NSScanner *_scan = [[NSScanner alloc] initWithString:topic];
	NSString *from = @"_";
	NSString *cmd = from;
	NSString *room = cmd;
	NSString *newTopic = room;
	[_scan scanUpToString:@" " intoString:&from];
	[_scan scanUpToString:@" " intoString:&cmd];
	[_scan scanUpToString:@" " intoString:&room];
	[_scan scanUpToString:@"\r\n" intoString:&newTopic];
	newTopic = [newTopic substringFromIndex:1];
	from = [from substringFromIndex:1];
	RCParseUserMask(from, &from, nil, nil);
	[[self channelWithChannelName:room] recievedMessage:newTopic from:from type:RCMessageTypeTopic];
	[_scan release];
}

- (void)handleCAP:(NSString *)cap {
	[self sendMessage:@"AUTHENTICATE PLAIN" canWait:NO];
}

void RCParseUserMask(NSString *mask, NSString **_nick, NSString **user, NSString **hostmask) {
	if (_nick)
		*_nick = nil;
	if (user)
		*user = nil;
	if (hostmask)
		*hostmask = nil;
	NSScanner *scanr = [NSScanner scannerWithString:mask];
	[scanr scanUpToString:@"!" intoString:_nick];
	if ([scanr isAtEnd]) return;
	[scanr setScanLocation:((int)[scanr scanLocation])+1];
	if (!user) return;
	[scanr scanUpToString:@"@" intoString:user];
	[scanr setScanLocation:((int)[scanr scanLocation])+1];
	if ([scanr isAtEnd]) return;
	if (!hostmask) return;
	[scanr scanUpToString:@"" intoString:hostmask];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([alertView isKindOfClass:[RCInviteRequestAlert class]]) {
		switch (buttonIndex) {
			case 0:
				break;
			case 1: {
				RCChannel *chan = [self addChannel:alertView.title join:YES];
				reloadNetworks();
				[[RCChatController sharedController] selectChannel:[chan channelName] fromNetwork:self];
				// select network here
				break;
			}
			default:
				break;
		}
	}
}

@end

@implementation CALayer (Haxx)
- (id)_nq:(id)arg1 {
	return nil;
}
@end