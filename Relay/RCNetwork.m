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
#import "RCServerChangeAlertView.h"
#import "RCChatController.h"
#import "NSData+Instance.h"

@implementation RCNetwork

@synthesize prefix, sDescription, server, nick, username, realname, spass, npass, port, isRegistered, useSSL, COL, _channels, useNick, userModes, _nicknames, shouldRequestSPass, shouldRequestNPass, listCallback, expanded, _selected, SASL, cache, uUID, isOper, isAway;

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
		canSend = YES;
		sockfd = -1;
		ctx = NULL;
		ssl = NULL;
		prefix = nil;
		_channels = [[NSMutableArray alloc] init];
		_nicknames = [[NSMutableArray alloc] init];
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
	[network setUUID:[info objectForKey:UUID_KEY]];
	if ([[info objectForKey:S_PASS_KEY] boolValue]) {
		//[network setSpass:([wrapper objectForKey:S_PASS_KEY] ?: @"")];
		RCKeychainItem *item = [[RCKeychainItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%@spass", [network uUID]]];
		[network setSpass:([item objectForKey:(id)kSecValueData] ?: @"")];
		if ([network spass] == nil || [[network spass] length] == 0) {
			[network setShouldRequestSPass:YES];
		}
		[item release];
	}
	if ([[info objectForKey:N_PASS_KEY] boolValue]) {
		//[network setNpass:([wrapper objectForKey:N_PASS_KEY] ?: @"")];
		RCKeychainItem *item = [[RCKeychainItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%@npass", [network uUID]]];
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
			uUID, UUID_KEY,
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
	// fix this. not everything is being removed here, like if the network is connected... lol
	[super dealloc];
}

- (BOOL)isEqual:(id)obj {
	return ([[self uUID] isEqualToString:[obj uUID]]);
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
	// rooms?
	// wat
	// dark days. the dark days. ~Maximus
	[rooms retain];
	for (NSDictionary *dict in rooms) {
		NSString *chan = [dict objectForKey:CHANNAMEKEY];
		if (!chan) continue;
		BOOL jOC = ([dict objectForKey:@"0_CHANJOC"] ? [[dict objectForKey:@"0_CHANJOC"] boolValue] : YES);
		[self addChannel:chan join:NO];
		RCChannel *_chan = [self channelWithChannelName:chan];
		[_chan setJoinOnConnect:jOC];
		RCKeychainItem *item = [[RCKeychainItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%@%@rpass", [self uUID], chan]];
		[_chan setPassword:[item objectForKey:(id)kSecValueData]];
		[item release];		
	}
	[rooms release];
}

- (void)setupRooms:(NSArray *)rooms {
	// old deprecated method. may still be used for RCAddNetworkController stuff.
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
	@synchronized(_channels) {
		for (RCChannel *chann in _channels) {
			if ([[[chann channelName] lowercaseString] isEqualToString:[chan lowercaseString]])
				return chann;
		}
		if (cr) {
			[self addChannel:chan join:NO];
		}
		return nil;
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

- (void)savePasswords {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
		if ([self spass]) {
			RCKeychainItem *keychain = [[RCKeychainItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%@spass", uUID]];
			[keychain setObject:spass forKey:(id)kSecValueData];
			[keychain release];
		}
		if ([self npass]) {
			RCKeychainItem *keychain = [[RCKeychainItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%@npass", uUID]];
			[keychain setObject:npass forKey:(id)kSecValueData];
			[keychain release];
		}
	});
	// should consider making RCPasswordStore or something. ~Maximus
}

#pragma mark - SOCKET STUFF

- (void)connect {
	if (shouldRequestNPass || shouldRequestSPass) {
		RCPasswordRequestAlertType type = 0;
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
	[disconnectTimer invalidate];
	disconnectTimer = nil;
	if (status == RCSocketStatusConnecting || status == RCSocketStatusConnected) return;
	status = RCSocketStatusConnecting;
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	writebuf = [[NSMutableString alloc] init];
	rcache = [[NSMutableData alloc] init];
	canSend = YES;
	cache = [[NSMutableString alloc] init];
	isRegistered = NO;
	dcCount = 0;
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
	sockfd = [[RCSocket sharedSocket] connectToAddr:server withSSL:useSSL andPort:port fromNetwork:self];
	[self sendMessage:@"CAP LS" canWait:NO];
	if ([spass length] > 0) {
		[self sendMessage:[@"PASS " stringByAppendingString:spass] canWait:NO];
	}
	if (!nick || [nick isEqualToString:@""]) {
		[self setNick:@"0__GUEST"];
		[self setUseNick:@"__GUEST"];
	}
	[self sendMessage:[@"USER " stringByAppendingFormat:@"%@ %@ %@ :%@", (username ? username : nick), nick, nick, (realname ? realname : nick)] canWait:NO];
	[self sendMessage:[@"NICK " stringByAppendingString:nick] canWait:NO];
	[p drain];
}

- (BOOL)hasPendingBites {
	if (!writebuf) return NO;
	return [writebuf length] > 0;
}

- (BOOL)read {
	static BOOL isReading;
	if (sockfd == -1) return NO;
	if (isReading) return YES;
	isReading = YES;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	char buf[513];
	int rc = 0;
	if (useSSL) {
		while ((rc = SSL_read(ssl, buf, 512)) > 0) {
			if (![self isTryingToConnectOrConnected]) return NO;
			[rcache appendBytes:buf length:rc];
			NSRange rr = [rcache rangeOfData:[NSData nlCharacterDataSet] options:(NSDataSearchOptions)nil range:NSMakeRange(0, [rcache length])];
			while (rr.location != NSNotFound) {
				if (rr.location == 0) break;
				NSData *str = [rcache subdataWithRange:NSMakeRange(0, rr.location+2)];
				NSString *send = [[NSString alloc] initWithData:str encoding:NSUTF8StringEncoding];
				if (send) {
					[self recievedMessage:send];
				}
				else {
					send = [[NSString alloc] initWithData:str encoding:NSISOLatin1StringEncoding];
					[self recievedMessage:send];
				}
				// :)
				[send autorelease];
				[rcache replaceBytesInRange:NSMakeRange(0, rr.location+2) withBytes:NULL length:0];
				rr = [rcache rangeOfData:[NSData nlCharacterDataSet] options:(NSDataSearchOptions)nil range:NSMakeRange(0, [rcache length])];
			}
		}
	}
	else {
		while ((rc = read(sockfd, buf, 512)) > 0) {
			if (![self isTryingToConnectOrConnected]) return NO;
			[rcache appendBytes:buf length:rc];
			NSRange rr = [rcache rangeOfData:[NSData nlCharacterDataSet] options:(NSDataSearchOptions)nil range:NSMakeRange(0, [rcache length])];
			while (rr.location != NSNotFound) {
				if (rr.location == 0) break;
				NSData *str = [rcache subdataWithRange:NSMakeRange(0, rr.location+2)];
				NSString *send = [[NSString alloc] initWithData:str encoding:NSUTF8StringEncoding];
				if (send) {
					[self recievedMessage:send];
				}
				else {
					send = [[NSString alloc] initWithData:str encoding:NSISOLatin1StringEncoding];
					[self recievedMessage:send];
				}
				// :)
				[send autorelease];
				[rcache replaceBytesInRange:NSMakeRange(0, rr.location+2) withBytes:NULL length:0];
				rr = [rcache rangeOfData:[NSData nlCharacterDataSet] options:(NSDataSearchOptions)nil range:NSMakeRange(0, [rcache length])];
			}
		}
	}
	[pool release];
	isReading = NO;
	return NO;
}

- (BOOL)write {
#if LOGALL
	MARK;
#endif
	if (sockfd == -1) return NO;
	if (isWriting) {
#if LOGALL
		NSLog(@"WRITING ALREADY. Stop.");
#endif
		return NO;
	}
	isWriting = YES;
#if LOGALL
	NSLog(@"WRITING BUFFER %d", sockfd);
#endif
	int written = 0;
	if (useSSL) {
		written = SSL_write(ssl, [writebuf UTF8String], strlen([writebuf UTF8String]));
	}
	else {
		written = write(sockfd, [writebuf UTF8String], strlen([writebuf UTF8String]));
	}
	const char *buf = [writebuf UTF8String];
#if LOGALL
	NSLog(@"Wrote %d bytes", written);
#endif
	buf = buf + written;
	[writebuf release];
	writebuf = [[NSMutableString alloc] initWithCString:buf encoding:NSUTF8StringEncoding];
	// this is derp. must be a better method. ;P
	isWriting = NO;
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
		[self disconnectCleanupWithMessage:error];
		// need to clean this up
		// postss to chat view as
		// Disconnected: Closing Link (~iPhone@108.132.140.49) [Quit: Relay 1.0]
		return;
	}
	
	if (![msg hasPrefix:@":"]) {
		if ([msg hasPrefix:@"AUTHENTICATE"]) {
			[self sendB64SASLAuth];
		}
		return;
	}
	
	RCMessage *message = [[RCMessage alloc] initWithString:msg];
	[message parse];
	
	NSString *selName = [NSString stringWithFormat:@"handle%@:", [message numeric]];
	SEL pSEL = NSSelectorFromString(selName);
	if ([self respondsToSelector:pSEL]) [self performSelector:pSEL withObject:message];
	else {
		[self handleNotHandledMessage:message];
	}
	[message release];
}

- (BOOL)isTryingToConnectOrConnected {
	return ([self isConnected] || status == RCSocketStatusConnecting);
}

- (NSString *)defaultQuitMessage {
	return @"Relay 1.0"; // TODO: return something else if user wants to
}

- (BOOL)disconnectWithMessage:(NSString *)msg {
	if (status == RCSocketStatusConnecting) {
		status = RCSocketStatusClosed;
		close(sockfd);
		[rcache release];
		rcache = nil;
		sockfd = -1;
		[writebuf release];
		writebuf = nil;
		if (useSSL)
			SSL_CTX_free(ctx);
		[[UIApplication sharedApplication] endBackgroundTask:task];
		task = UIBackgroundTaskInvalid;
		isRegistered = NO;
		for	(RCChannel *_chan in _channels) {
			[_chan disconnected:msg];
		}
	}
	else if (status == RCSocketStatusConnected) {
		// also unset away (znc)
		[self sendMessage:@"AWAY" canWait:NO];
		[self sendMessage:[@"QUIT :" stringByAppendingString:([msg isEqualToString:@"Disconnected."] ? [self defaultQuitMessage] : msg)] canWait:NO];
	}
	disconnectTimer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(forceDisconnect) userInfo:nil repeats:NO];
	return YES;
}

- (void)forceDisconnect {
	disconnectTimer = nil;
	if ([self isConnected]) {
		[self disconnectCleanupWithMessage:@"Disconnected."];
	}
}

- (void)disconnectCleanupWithMessage:(NSString *)msg {
	_isDisconnecting = NO;
	status = RCSocketStatusClosed;
	close(sockfd);
	[rcache release];
	rcache = nil;
	sockfd = -1;
	[writebuf release];
	writebuf = nil;
	isAway = NO;
	if (useSSL)
		SSL_CTX_free(ctx);
	[[UIApplication sharedApplication] endBackgroundTask:task];
	task = UIBackgroundTaskInvalid;
	isRegistered = NO;
	[[self consoleChannel] disconnected:msg];
	for	(RCChannel *_chan in _channels) {
		if (![_chan isKindOfClass:[RCConsoleChannel class]])
			[_chan disconnected:@"Disconnected."];
	}
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
	}
	[joinList release];
}

- (BOOL)isConnected {
	return (status == RCSocketStatusConnected);
}

- (void)sendB64SASLAuth {
	NSString *b64 = [[NSString stringWithFormat:@"%@\0%@0%@", useNick, useNick, npass] base64];
	[self sendMessage:[NSString stringWithFormat:@"AUTHENTICATE %@", b64] canWait:NO];
}

- (void)handleNotHandledMessage:(RCMessage *)message {
	RCChannel *chan = [self consoleChannel];
	[chan recievedMessage:message->message from:@"" type:RCMessageTypeNormal];
	NSLog(@"PLZ IMPLEMENT handle%@:%@", [message numeric], [message description]);
}

- (void)handle001:(RCMessage *)message {
	// RPL_WELCOME
	status = RCSocketStatusConnected;
	[self networkDidRegister:YES];
    
	// useNick = [[message sender] retain];
	// you are special. the sender is the server name here
	// we want the first word after the numeric. whihc we TRASH THANKS TO YOU >:l
	// ~Maximus
	RCChannel *chan = [self consoleChannel];
	[chan recievedMessage:[message parameterAtIndex:1] from:@"" type:RCMessageTypeNormal];
	reloadNetworks();
}

- (void)handle002:(RCMessage *)message {
	// RPL_YOURHOST
	RCChannel *chan = [self consoleChannel];
	[chan recievedMessage:[message parameterAtIndex:1] from:@"" type:RCMessageTypeNormal];
}

- (void)handle003:(RCMessage *)message {
	// RPL_CREATED
	RCChannel *chan = [self consoleChannel];
	[chan recievedMessage:[message parameterAtIndex:1] from:@"" type:RCMessageTypeNormal];
}

- (void)handle004:(RCMessage *)message {
	// RPL_MYINFO
	RCChannel *chan = [self consoleChannel];
	[chan recievedMessage:message->message from:@"" type:RCMessageTypeNormal];
}

- (void)handle005:(RCMessage *)message {
	// RPL_ISUPPORT
	@synchronized(self) {
		NSString *capsString = [message->message substringFromIndex:[message->message rangeOfString:@" "].location + 1];
		NSArray *arr = [capsString componentsSeparatedByString:@" "];
		NSMutableString *message = [NSMutableString stringWithString:@""];
		for (NSString *str in arr) {
			// this is logical because the describing string comes after the capabilties.
			if ([str hasPrefix:@":"]) {
				[message appendString:[capsString substringFromIndex:[capsString rangeOfString:@":" options:NSBackwardsSearch].location + 1]];
				break;
			}
			else if ([str rangeOfString:@"="].location != NSNotFound) {
				NSArray *capabArr = [str componentsSeparatedByString:@"="];
				if ([@"PREFIX" isEqualToString:[capabArr objectAtIndex:0]]) {
					NSString *info = [capabArr objectAtIndex:1];
					NSArray *split = [info componentsSeparatedByString:@")"];
					NSString *modes = [[split objectAtIndex:0] substringFromIndex:1];
					NSString *prefixes = [split objectAtIndex:1];
					NSMutableDictionary *prefixDict = [[NSMutableDictionary alloc] init];
					for (int i = 0; i < [modes length]; i++) {
						NSString *thePrefix = [prefixes substringWithRange:NSMakeRange(i, 1)];
						NSString *theMode = [modes substringWithRange:NSMakeRange(i, 1)];
						[prefixDict setObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:i], thePrefix, nil] forKey:theMode];
                    }
					self.prefix = [[prefixDict copy] autorelease];
					[prefixDict release];
				}
				[message appendString:[NSString stringWithFormat:@"\x02%@\x02=%@ ", [capabArr objectAtIndex:0], [capabArr objectAtIndex:1]]];
			}
			else {
				[message appendString:[NSString stringWithFormat:@"\x02%@\x02 ", str]];
			}
		}
#if _DEBUG
		[[self consoleChannel] recievedMessage:message from:@"" type:RCMessageTypeNormal];
#endif
	}
}

- (void)handle010:(RCMessage *)message {
	// RPL_BOUNCE
	NSString *redirServer = [message parameterAtIndex:1];
	NSString *redirPort = [message parameterAtIndex:2];
	NSString *alertString = nil;
	if ([redirPort integerValue] != 0) {
		if ([self port] == [redirPort integerValue]) {
			alertString = [NSString stringWithFormat:@"Server %@ (%@) is redirecting to %@.\nChange server?", [self _description], server, redirServer];
		}
		else {
			alertString = [NSString stringWithFormat:@"Server %@ (%@) is redirecting to %@ on port %@.\nChange server?", [self _description], server, redirServer, redirPort];
		}
		RCServerChangeAlertView *ac = [[RCServerChangeAlertView alloc] initWithTitle:nil message:alertString delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Change", nil];
		[ac setServer:redirServer];
		[ac setPort:[redirPort intValue]];
		[ac setTag:RCALERR_SERVCHNGE];
		[ac show];
		[ac release];
	}
}

- (void)handle042:(RCMessage *)message {
	
}

- (void)handle250:(RCMessage *)message {
	// RPL_STATSCONN
}

- (void)handle251:(RCMessage *)message {
	// RPL_LUSERCLIENT
}

- (void)handle252:(RCMessage *)message {
	// RPL_LUSEROP
}

- (void)handle253:(RCMessage *)message {
	// RPL_LUSERUNKNOWN
}

- (void)handle254:(RCMessage *)message {
	// RPL_LUSERCHANNELS
}

- (void)handle255:(RCMessage *)message {
	// RPL_LUSERME
}

- (void)handle265:(RCMessage *)message {
	// RPL_LOCALUSERS
}

- (void)handle266:(RCMessage *)message {
	// RPL_GLOBALUSERS
}

- (void)handle301:(RCMessage *)message {
	// RPL_AWAY
}

- (void)handle303:(RCMessage *)message {
	// RPL_ISON
}

- (void)handle305:(RCMessage *)message {
	// RPL_UNAWAY
	isAway = NO;
}

- (void)handle306:(RCMessage *)message {
	// RPL_NOWAWAY
	isAway = YES;
}

- (void)handle311:(RCMessage *)message {
	// RPL_WHOISUSER
}

- (void)handle312:(RCMessage *)message {
	// RPL_WHOISSERVER
}

- (void)handle313:(RCMessage *)message {
	// RPL_WHOISOPERATOR
}

- (void)handle318:(RCMessage *)message {
	// RPL_ENDOFWHOIS
}

- (void)handle319:(RCMessage *)message {
	// RPL_WHOISCHANNELS
}

- (void)handle321:(RCMessage *)message {
	// RPL_LISTSTART
}

- (void)handle322:(RCMessage *)message {
	// RPL_LIST
	NSLog(@"322:%@", message->message);
    
	/*
	if (!listCallback) return;
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
	[listCallback recievedChannel:chan withCount:[count intValue] andTopic:topicModes];
	[hi release];
	// :irc.saurik.com 322 mx_ #testing 1 :[+nt]
	// :hitchcock.freenode.net 322 mxms_ #testchannelpleaseignore 3 :http://i.imgur.com/LbPvWUV.jpg
	 */
}

- (void)handle323:(RCMessage *)message {
	// RPL_LISTEND
	[listCallback setUpdating:NO];
	listCallback = nil;
}

- (void)handle328:(RCMessage *)message {
	// RPL_CHANNEL_URL
	NSString *channel = [message parameterAtIndex:1];
	NSString *website = [message parameterAtIndex:2];
	[[self channelWithChannelName:channel] recievedMessage:[NSString stringWithFormat:@"Website is %@", website] from:@"" type:RCMessageTypeEvent];
}

- (void)handle331:(RCMessage *)message {
	// RPL_NOTOPIC
	NSString *channel = [message parameterAtIndex:1];
	[[self channelWithChannelName:channel ifNilCreate:YES] recievedMessage:@"No topic set." from:@"" type:RCMessageTypeTopic];
}

- (void)handle332:(RCMessage *)message {
	// RPL_TOPIC
	NSString *channel = [message parameterAtIndex:1];
	NSString *topic = [message parameterAtIndex:2];
	[[self channelWithChannelName:channel ifNilCreate:YES] recievedMessage:topic from:nil type:RCMessageTypeTopic];
}

- (void)handle333:(RCMessage *)message {
	// RPL_TOPICWHOTIME(?)
	NSString *channel = [message parameterAtIndex:1];
	NSString *setter = [message parameterAtIndex:2];
	int ts = [[message parameterAtIndex:3] intValue];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"dd MMMM yyyy, HH:mm:ss"];
	NSString *time = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:ts]];
	[dateFormatter release];
	RCParseUserMask(setter, &setter, nil, nil);
	[[self channelWithChannelName:channel] recievedMessage:[NSString stringWithFormat:@"Set by %@ on %@", setter, time] from:@"" type:RCMessageTypeNormalE2];
}

- (void)handle353:(RCMessage *)message {
	// RPL_NAMREPLY
	NSString *room = [message parameterAtIndex:2];
	NSString *users = [message parameterAtIndex:3];
	if ([users length] > 1) {
		users = [users substringFromIndex:1];
		NSArray *_someUsers = [users componentsSeparatedByString:@" "];
		RCChannel *chan = [self channelWithChannelName:room];
		[chan setShouldHoldUserListUpdates:YES];
		if (chan) {
			for (NSString *user in _someUsers) {
				[chan setUserJoinedBatch:user cnt:0];
			}
		}
	}
}
- (void)handle366:(RCMessage *)message {
	// RPL_ENDOFNAMES
	NSString *chan = [message parameterAtIndex:1];
	RCChannel *channel = [self channelWithChannelName:chan];
	[channel setShouldHoldUserListUpdates:NO];
}

- (void)handle375:(RCMessage *)message {
	// RPL_ENDOFMOTD
	NSString *string = [message parameterAtIndex:1];
	RCChannel *chan = [self consoleChannel];
	[chan recievedMessage:string from:@"MOTD " type:RCMessageTypeNormal];
}

- (void)handle372:(RCMessage *)message {
	// RPL_MOTD
	NSString *line = [message parameterAtIndex:1];
	RCChannel *chan = [self consoleChannel];
	[chan recievedMessage:line from:@"MOTD " type:RCMessageTypeNormal];
}

- (void)handle376:(RCMessage *)message {
	// :irc.saurik.com 376 _m :End of message of the day.
}

- (void)handle381:(RCMessage *)message {
	isOper = YES;
}

- (void)handle396:(RCMessage *)message {
	// RPL_HOSTHIDDEN
	NSString *host = [message parameterAtIndex:1];
	NSString *info = [message parameterAtIndex:2];
	RCChannel *chan = [self consoleChannel];
	[chan recievedMessage:[NSString stringWithFormat:@"%@ %@", host, info] from:@"" type:RCMessageTypeEvent];
}

- (void)handle401:(RCMessage *)message {
	// no such nick/channel
}

- (void)handle403:(RCMessage *)message {
	// no such channel
}

- (void)handle404:(RCMessage *)message {
	// ERR_CANNOTSENDTOCHAN
	NSString *channel = [message parameterAtIndex:1];
	NSString *reason = [message parameterAtIndex:2];
	[[self channelWithChannelName:channel ifNilCreate:YES] recievedMessage:reason from:@"" type:RCMessageTypeError];
}

- (void)handle420:(RCMessage *)message {
	// NSLog(@"DAFUQ %@", blunt);
}

- (void)handle421:(RCMessage *)message {
	// ERR_UNKNOWNCOMMAND
	NSString *command = [message parameterAtIndex:1];
	NSString *reason = [message parameterAtIndex:2];
	NSString *string = [NSString stringWithFormat:@"Error(421): %@ %@", command, reason];
	[[[[RCChatController sharedController] currentPanel] channel] recievedMessage:string from:@"" type:RCMessageTypeError];
}

- (void)handle422:(RCMessage *)message {
	// ERR_NOMOTD
	// NSLog(@"Ohai. %@", motd);
}

- (void)handle432:(RCMessage *)message {
	// ERR_ERRONEUSNICKNAME
	dispatch_async(dispatch_get_main_queue(), ^{
		RCPrettyAlertView *ac = [[RCPrettyAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Invalid Nickname (%@)", [self _description]] message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Change", nil];
		[ac setTag:RCALERR_INCNICK];
		[ac setAlertViewStyle:UIAlertViewStylePlainTextInput];
		[ac show];
		[ac release];
	});
}

- (void)handle433:(RCMessage *)message {
	// nERR_NICKNAMEINUSE
	self.useNick = [useNick stringByAppendingString:@"_"];
	[self sendMessage:[@"NICK " stringByAppendingString:useNick] canWait:NO];
}

- (void)handle437:(RCMessage *)message {
	// ERR_UNAVAILRESOURCE
#if LOGALL
	NSLog(@"ERR_UNAVAILRESOURCE: %@", message->message);
#endif
}

- (void)handle461:(RCMessage *)message {
	dispatch_async(dispatch_get_main_queue(), ^{
		RCPrettyAlertView *ac = [[RCPrettyAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Invalid Username (%@)", [self _description]] message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Change", nil];
		[ac setTag:RCALERR_INCUNAME];
		[ac setAlertViewStyle:UIAlertViewStylePlainTextInput];
		[ac show];
		[ac release];
	});
}

- (void)handle464:(RCMessage *)message {
	dispatch_async(dispatch_get_main_queue(), ^{
		RCPrettyAlertView *ac = [[RCPrettyAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Invalid Server Password (%@)", [self _description]] message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Change", nil];
		[ac setTag:RCALERR_INCSPASS];
		[ac setAlertViewStyle:UIAlertViewStyleSecureTextInput];
		[ac show];
		[ac release];
	});
}

- (void)handle473:(RCMessage *)message {
	// ERR_INVITEONLYCHAN
	NSString *channel = [message parameterAtIndex:1];
	NSString *reason = [message parameterAtIndex:2];
	// perhaps implement a KNOCK prompt here sometime
	[[[[RCChatController sharedController] currentPanel] channel] recievedMessage:[NSString stringWithFormat:@"\x02%@\x02: %@", channel, reason] from:@"" type:RCMessageTypeError];
}

- (void)handle474:(RCMessage *)message {
	// ERR_BANNEDFROMCHANNEL
	NSString *channel = [message parameterAtIndex:1];
	NSString *reason = [message parameterAtIndex:2];
	[[[[RCChatController sharedController] currentPanel] channel] recievedMessage:[NSString stringWithFormat:@"\x02%@\x02: %@", channel, reason] from:@"" type:RCMessageTypeError];
}

- (void)handle475:(RCMessage *)message {
	// ERR_BANNEDFROMCHANNEL
	NSString *channel = [message parameterAtIndex:1];
	NSString *reason = [message parameterAtIndex:2];
	[[[[RCChatController sharedController] currentPanel] channel] recievedMessage:[NSString stringWithFormat:@"\x02%@\x02: %@", channel, reason] from:@"" type:RCMessageTypeError];
}

- (void)handle482:(RCMessage *)message {
	// ERR_BANNEDFROMCHANNEL
	NSString *channel = [message parameterAtIndex:1];
	NSString *reason = [message parameterAtIndex:2];
	[[[[RCChatController sharedController] currentPanel] channel] recievedMessage:[NSString stringWithFormat:@"\x02%@\x02: %@", channel, reason] from:@"" type:RCMessageTypeError];
}

- (void)handle520:(RCMessage *)message {
	return;
    // what is this numeric even
	// yes, 520 is an even number ~Maximus
}

- (void)handle903:(RCMessage *)message {
	[self sendMessage:@"CAP END"];
}

- (void)handle904:(RCMessage *)message {
	[[self consoleChannel] recievedMessage:@"SASL Authentication failed." from:nil type:RCMessageTypeNormal];
}

- (void)handle998:(RCMessage *)message {
	// RPL_FUCKYOUUMICH
}

- (void)handleCAP:(RCMessage *)message {
	if ([[message parameterAtIndex:1] isEqualToString:@"LS"]) {
		NSArray *capabilities = [[message parameterAtIndex:2] componentsSeparatedByString:@" "];
		NSMutableArray *supported = [[NSMutableArray alloc] init];
		// We support the current (as of this writing) server-time spec.
		if ([capabilities containsObject:@"server-time"]) {
			[supported addObject:@"server-time"];
		}
		// Support ZNC namespaced server-time.
		if ([capabilities containsObject:@"znc.in/server-time-iso"]) {
			[supported addObject:@"znc.in/server-time-iso"];
		}
		// Support SASL.
		if ([capabilities containsObject:@"sasl"] && SASL) {
			[supported addObject:@"sasl"];
		}
		if ([supported count] != 0) {
			[self sendMessage:[NSString stringWithFormat:@"CAP REQ :%@", [supported componentsJoinedByString:@" "]]];
		}
		[supported release];
	}
	[self sendMessage:@"CAP END" canWait:NO];
}

- (void)handleCTCPRequest:(RCMessage *)message {
	NSLog(@"CTCP:%@", [message parameterAtIndex:2]);
	return;
	/*
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
	NSLog(@"CTCP COMMAND:[%@]", command);
#endif
	command = [command uppercaseString];
	// probbably add UPTIME. k
	if ([command isEqualToString:@"TIME"])
		extra = [NSString stringWithFormat:@"%@", [NSDate date]];
	else if ([command isEqualToString:@"VERSION"])
		extra = @"Relay 1.0";
	else if ([command isEqualToString:@"USERINFO"])
		extra = @"";
	else if ([command isEqualToString:@"CLIENTINFO"])
		extra = @"CLIENTINFO VERSION CLIENTINFO USERINFO PING TIME UPTIME";
	else if ([command isEqualToString:@"IRCCAT"]) {
		NSArray *ary = @[@"irccat best op evar", @"irccat #1", @"irccat master op 2013", @"irccat ftw", @"irccat > longcat", @"no support without irccat"];
		extra = ary[arc4random() % [ary count]];
	}
	else
		NSLog(@"WTF?!?!! %@", command);
	[self sendMessage:[@"NOTICE " stringByAppendingFormat:@"%@ :\x01%@ %@\x01", _from, command, extra]];*/
}

- (void)handleINVITE:(RCMessage *)message {
    /*
	NSScanner *_scanner = [[NSScanner alloc] initWithString:invite];
	NSString *from = @"";
	NSString *chan = @"";
	NSString *crap;
	[_scanner scanUpToString:@" " intoString:&from];
	[_scanner scanUpToString:@" " intoString:&crap];
	[_scanner scanUpToString:@" " intoString:&crap];
	[_scanner scanUpToString:@" " intoString:&chan];
	if ([from hasPrefix:@":"])
		from = [from substringFromIndex:1];
	RCParseUserMask(from, &from, nil, nil);
	chan = [chan substringFromIndex:1];
	RCInviteRequestAlert *alert = [[RCInviteRequestAlert alloc] initWithTitle:[NSString stringWithFormat:@"%@\r\n(%@)",chan, [self _description]] message:[NSString stringWithFormat:@"%@ has invited you to %@", from, chan] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Join", nil];
	dispatch_sync(dispatch_get_main_queue(), ^{
		[alert show];
		[alert release];
	});
	[_scanner release];
	*/
}

- (void)handleJOIN:(RCMessage *)message {
	/*
	// add user unless self
	return;
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
	*/
}

- (void)handleKICK:(RCMessage *)message {
/*
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
    [[self channelWithChannelName:room] recievedMessage:(NSString *)[NSArray arrayWithObjects:usr, msg, nil] from:_nick type:RCMessageTypeKick];
	if ([usr isEqualToString:useNick]) {
        [[self channelWithChannelName:room] setJoined:NO];
	}
	[_scanner release];
*/
}

- (void)handleMODE:(RCMessage *)message {
    /*
	return;
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
	// Relay[2626:f803] MSG: :ac3xx!ac3xx@rox-103C7229.ac3xx.com MODE #chat +o _m*/
}

- (void)handleNICK:(RCMessage *)message {
	return;
    /*
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
	// qwerty .. why do you do this.
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
     */
}

- (void)handleNOTICE:(RCMessage *)message {
    /*
	return;
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
	//:Hackintech!Hackintech@2FD03E27.3D6CB32E.E0E5D6BD.IP NOTICE __m__ :HI*/
}

- (void)handlePART:(RCMessage *)message {
    /*
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
     */
}

- (void)handlePING:(NSString *)pong {
	if ([pong hasPrefix:@"PING "]) {
		// NSString here.
		[self sendMessage:[@"PONG " stringByAppendingString:[pong substringFromIndex:5]] canWait:NO];
	}
	else {
		// RCMessage here.
		NSString *from = [(RCMessage *)pong sender];
		NSString *user = nil;
		RCParseUserMask(from, &user, nil, nil);
		// check this ..
		[self sendMessage:[@"NOTICE " stringByAppendingFormat:@"%@ %@", user, [(RCMessage *)pong parameterAtIndex:0]]];
	}
}

- (void)handlePRIVMSG:(RCMessage *)message {
	NSString *fullMessage = [message parameterAtIndex:1];
	RCMessageType typ = RCMessageTypeNormal;
	NSString *userMessage = nil;
	NSString *from = nil;
	if ([fullMessage hasPrefix:@"\x01"] && [fullMessage hasSuffix:@"\x01"]) {
		// don't handle this yet. don't know how to. ;P
		// typ = RCMessageTypeAction mayb.
		return;
	}
	else {
		userMessage = [message parameterAtIndex:1];
	}
	NSLog(@"dfs %@:%@", message->message, message.sender);
	RCChannel *channel = [self channelWithChannelName:[message parameterAtIndex:0] ifNilCreate:YES];
	RCParseUserMask(message.sender, &from, nil, nil);
	[channel recievedMessage:userMessage from:from type:typ];
    /*
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
				 || [msg hasPrefix:@"CLIENTINFO"]
				|| [msg hasPrefix:@"IRCCAT"]) {
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
	[_scanner release];*/
}

- (void)handleQUIT:(RCMessage *)message {
    /*
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
     */
}

- (void)handleTOPIC:(RCMessage *)message {
	NSLog(@"fdfs %@:%@:%@:%@", message->message, message.sender, [message parameterAtIndex:0], [message parameterAtIndex:1]);
    /*
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
    */
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

- (void)willPresentAlertView:(UIAlertView *)alertView {
	// controls flood, i guess.
	if (![alertView isKindOfClass:[RCInviteRequestAlert class]]) return;
	NSString *str = alertView.title;
	NSRange rrs = [str rangeOfString:@"\r\n"];
	str = [str substringToIndex:rrs.location];
	if ([self channelWithChannelName:str]) {
		[alertView dismissWithClickedButtonIndex:0 animated:NO];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if ([alertView isKindOfClass:[RCInviteRequestAlert class]]) {
		switch (buttonIndex) {
			case 0:
				break;
			case 1: {
				NSString *str = alertView.title;
				NSRange rrs = [str rangeOfString:@"\r\n"];
				str = [str substringToIndex:rrs.location];
				RCChannel *chan = [self addChannel:str join:YES];
				reloadNetworks();
				[[RCChatController sharedController] selectChannel:[chan channelName] fromNetwork:self];
				// select network here
				break;
			}
			default:
				break;
		}
	}
	switch ([alertView tag]) {
		case RCALERR_INCNICK: {
			if (buttonIndex == 0) {
				// cancel
				[self disconnect];
			}
			else {
				[self setNick:[alertView textFieldAtIndex:0].text];
				[[RCNetworkManager sharedNetworkManager] saveNetworks];
				if ([self isTryingToConnectOrConnected]) {
					[self sendMessage:[NSString stringWithFormat:@"NICK %@", nick] canWait:NO];
				}
				else {
					[self connect];
				}
			}
			break;
		}
		case RCALERR_INCUNAME: {
			if (buttonIndex == 0) {
				// cancel
				[self disconnect];
			}
			else {
				[self setUsername:[alertView textFieldAtIndex:0].text];
				[[RCNetworkManager sharedNetworkManager] saveNetworks];
				if ([self isTryingToConnectOrConnected]) {
					[self sendMessage:[NSString stringWithFormat:@"USER %@ %@ %@ :%@", (username ? username : nick), nick, nick, (realname ? realname : nick)] canWait:NO];
				}
				else {
					[self connect];
				}
			}
			break;
		}
		case RCALERR_INCSPASS: {
			if (buttonIndex == 0) {
				[self disconnect];
			}
			else {
				[self setSpass:[alertView textFieldAtIndex:0].text];
				[self savePasswords];
				if ([self isTryingToConnectOrConnected]) {
					[self sendMessage:[NSString stringWithFormat:@"PASS %@", spass] canWait:NO];
				}
				else {
					[self connect];
				}
			}
			break;
		}
		case RCALERR_SERVCHNGE: {
			if (buttonIndex == 0) {
				[self disconnect];
			}
			else {
				RCServerChangeAlertView *acl = (RCServerChangeAlertView *)alertView;
				[self setServer:[acl server]];
				[self setPort:[acl port]];
				[[RCNetworkManager sharedNetworkManager] saveNetworks];
				if ([self isConnected] == NO) {
					[self connect];
				}
				else {
					[self disconnect];
					[self connect];
				}
			}
			break;
		}
	}
}

@end
