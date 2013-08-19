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

@synthesize prefix, sDescription, server, nick, username, realname, spass, npass, port, isRegistered, useSSL, COL, _channels, useNick, userModes, _nicknames, shouldRequestSPass, shouldRequestNPass, listCallback, expanded, _selected, SASL, uUID, isOper, isAway;

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
	NSMutableArray *channels = [[[info objectForKey:CHANNELS_KEY] mutableCopy] autorelease];
	if (!channels) {
		[network addChannel:@"\x01IRC" join:NO];
	}
	[network _setupChannels:channels];
	return [network autorelease];
}

- (RCNetwork *)uniqueCopy {
	RCNetwork *newNet = [[RCNetwork alloc] init];
	[newNet setSDescription:sDescription];
	[newNet setServer:server];
	[newNet setUsername:username];
	[newNet setNick:nick];
	[newNet setRealname:realname];
	[newNet setPort:port];
	[newNet setUseSSL:useSSL];
	[newNet setSASL:SASL];
	[newNet setCOL:COL];
	[newNet setSpass:spass];
	[newNet setNpass:npass];
	for (RCChannel *chan in _channels) {
		[newNet addChannel:[chan channelName] join:NO];
	}
	CFUUIDRef uRef = CFUUIDCreate(NULL);
	CFStringRef uStringRef = CFUUIDCreateString(NULL, uRef);
	CFRelease(uRef);
	[newNet setUUID:(NSString *)uStringRef];
	CFRelease(uStringRef);
	return newNet;
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

- (void)_setupChannels:(NSArray *)rooms {
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
			if ([[chann channelName] isEqualToStringNoCase:chan])
				return chann;
		}
		if (cr) {
			RCChannel *newChan = [self addChannel:chan join:NO];
			return newChan;
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
			// maybe not add an exception for &
			else if ([_chan hasPrefix:@"#"]) chan = [[RCChannel alloc] initWithChannelName:_chan];
			else {
				chan = [[RCPMChannel alloc] initWithChannelName:_chan];
			}
			[chan setDelegate:self];
			if ([chan isKindOfClass:[RCConsoleChannel class]]) {
				[_channels insertObject:chan atIndex:0];
			}
			else {
				[_channels addObject:chan];
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

- (void)moveChannelAtIndex:(int)idx toIndex:(int)newIdx; {
	RCChannel *ctrlChan = [_channels objectAtIndex:idx];
	[ctrlChan retain];
	[_channels removeObjectAtIndex:idx];
	[_channels insertObject:ctrlChan atIndex:newIdx-1];
	[ctrlChan release];
	[[RCNetworkManager sharedNetworkManager] saveNetworks];
}

- (void)savePasswords {
	dispatch_async(dispatch_get_main_queue(), ^ {
		if (spass) {
			RCKeychainItem *keychain = [[RCKeychainItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%@spass", uUID]];
			[keychain setObject:spass forKey:(id)kSecValueData];
			[keychain release];
		}
		if (npass) {
			RCKeychainItem *keychain = [[RCKeychainItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%@npass", uUID]];
			[keychain setObject:npass forKey:(id)kSecValueData];
			[keychain release];
		}
		[[RCNetworkManager sharedNetworkManager] saveNetworks];
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
		[rs setTag:RCALERR_INCSPASS];
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
	isRegistered = NO;
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
	if (SASL) [self sendMessage:@"CAP LS" canWait:NO];
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
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	if ([msg isEqualToString:@""] || msg == nil || [msg isEqualToString:@"\r\n"]) return;
	msg = [msg stringByReplacingOccurrencesOfString:@"\r" withString:@""];
	msg = [msg stringByReplacingOccurrencesOfString:@"\n" withString:@""];
	
	if ([msg hasPrefix:@"PING"]) {
		[self handlePING:msg];
		[pool drain];
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
		[pool drain];
		return;
	}
	
	if (![msg hasPrefix:@":"]) {
		if ([msg hasPrefix:@"AUTHENTICATE"]) {
			[self sendB64SASLAuth];
		}
		[pool drain];
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
	[pool drain];
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
	if (status == RCSocketStatusClosed) return;
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
	reloadNetworks();
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
					[joinList appendFormat:@"%@,", chan];
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
	NSLog(@"PLZ IMPLEMENT handle%@:%@", [message numeric], message->message);
}

- (void)handle001:(RCMessage *)message {
	// RPL_WELCOME
	// :Welcome to the Internet Relay Network <nick>!<user>@<host>
	status = RCSocketStatusConnected;
	[self networkDidRegister:YES];
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
		dispatch_async(dispatch_get_main_queue(), ^ {
			[ac show];
			[ac release];
		});
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
	// :irc.saurik.com 311 mxms__ Maximus ~textual 184.33.54.165 * :Textual User
	NSString *name = [message parameterAtIndex:2];
	NSString *ips = [message parameterAtIndex:3];
	NSString *ident = [message parameterAtIndex:5];
	NSString *final = [NSString stringWithFormat:@"%@@%@ and real name \"%@\"", name, ips, ident];
	RCPMChannel *user = (RCPMChannel *)[self channelWithChannelName:[message parameterAtIndex:1]];
	if (user) {
		[user setIpInfo:final];
	}
	else {
		// post to current chan
	}
}

- (void)handle312:(RCMessage *)message {
	// RPL_WHOISSERVER
	// :irc.saurik.com 312 mxms__ Maximus *.irc.saurik.com :Saurik
	NSString *connInfo = [NSString stringWithFormat:@"%@ (%@)", [message parameterAtIndex:2], [message parameterAtIndex:3]];
	RCPMChannel *chan = (RCPMChannel *)[self channelWithChannelName:[message parameterAtIndex:1]];
	if (chan) {
		[chan setConnectionInfo:connInfo];
	}
}

- (void)handle313:(RCMessage *)message {
	// RPL_WHOISOPERATOR
}

- (void)handle317:(RCMessage *)message {
	// :irc.saurik.com 317 mxms__ Maximus 12 1376202021 :seconds idle, signon time
	// meh
}

- (void)handle318:(RCMessage *)message {
	RCPMChannel *channel = (RCPMChannel *)[self channelWithChannelName:[message parameterAtIndex:1]];
	[channel recievedWHOISInformation];
	// RPL_ENDOFWHOIS
}

- (void)handle319:(RCMessage *)message {
	// RPL_WHOISCHANNELS
	NSString *channels = [message parameterAtIndex:2];
	RCPMChannel *channel = (RCPMChannel *)[self channelWithChannelName:[message parameterAtIndex:1]];
	if (channel) {
		[channel setChanInfos:channels];
		// maybe separate these with commans, and put 'and' at the end to be fancy. ;P
		// Maximus is in #theos, #iphonedev, #bacon, #k, and #_k
		// hm... i like it
		// ~Maximus
	}
	// :irc.saurik.com 319 mxms__ Maximus :#theos #iphonedev #bacon @#k @#_k 
}

- (void)handle321:(RCMessage *)message {
	// RPL_LISTSTART
}

- (void)handle322:(RCMessage *)message {
	// RPL_LIST
	if (!listCallback) return;
	NSString *chan = [message parameterAtIndex:1];
	NSString *count = [message parameterAtIndex:2];
	NSString *topicModes = [message parameterAtIndex:3];
	chan = [chan stringByReplacingOccurrencesOfString:@" " withString:@""];
	count = [count stringByReplacingOccurrencesOfString:@" " withString:@""];
	if ([topicModes isEqualToString:@" "]) topicModes = nil;
	if ([topicModes hasPrefix:@" "]) topicModes = [topicModes recursivelyRemovePrefix:@" "];
	[listCallback recievedChannel:chan withCount:[count intValue] andTopic:topicModes];
	// :irc.saurik.com 322 mx_ #testing 1 :[+nt]
	// :hitchcock.freenode.net 322 mxms_ #testchannelpleaseignore 3 :http://i.imgur.com/LbPvWUV.jpg
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
	RCParseUserMask(setter, &setter, nil, nil);
	int ts = [[message parameterAtIndex:3] intValue];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MMMM dd, yyyy hh:mm:ss"];
	NSString *time = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:ts]];
	[dateFormatter release];
	[[self channelWithChannelName:channel] recievedMessage:[NSString stringWithFormat:@"Set by %c%@%c on %@", RCIRCAttributeBold, setter, RCIRCAttributeBold, time] from:@"" type:RCMessageTypeNormalE2];
}

- (void)handle353:(RCMessage *)message {
	// RPL_NAMREPLY
	NSString *room = [message parameterAtIndex:2];
	NSString *users = [message parameterAtIndex:3];
	if ([users length] > 1) {
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
	[channel setUserJoined:useNick];
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
	// ddon't like this assumption.
	// server response could be slow.
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
    [[self consoleChannel] recievedMessage:[message parameterAtIndex:2] from:nil type:RCMessageTypeNormal];
	dispatch_async(dispatch_get_main_queue(), ^{
		RCPrettyAlertView *ac = [[RCPrettyAlertView alloc] initWithTitle:@"Nickname Unavailable" message:[NSString stringWithFormat:@"Please input another nickname for %@ below.", [self _description]] delegate:self cancelButtonTitle:@"Disconnect" otherButtonTitles:@"Retry", nil];
		[ac setTag:RCALERR_INCUNAME];
		[ac setAlertViewStyle:UIAlertViewStylePlainTextInput];
		[ac show];
		[ac release];
	});
}

- (void)handle461:(RCMessage *)message {
	// this is broken
	// type /nick for example.
	// wether you hit change or cancel, it disconnects you
	// its stupid.
	if (isRegistered) {
        dispatch_async(dispatch_get_main_queue(), ^{
            RCPrettyAlertView *ac = [[RCPrettyAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Invalid Username (%@)", [self _description]] message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Change", nil];
            [ac setTag:RCALERR_INCUNAME];
            [ac setAlertViewStyle:UIAlertViewStylePlainTextInput];
            [ac show];
            [ac release];
        });
    }
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
	// (╯°□°）╯︵ ┻━┻ T H I S  I S  R I D I C U L O U S
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

- (void)handleCTCPRequest:(NSString *)req from:(NSString *)from_ {
	NSString *extra = nil;
	NSString *command = req;
	NSString *from = nil;
	RCParseUserMask(from_, &from, nil, nil);
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
		NSArray *ary = @[@"irccat best op evar", @"irccat #1", @"irccat master op 2013", @"irccat ftw", @"irccat > longcat", @"no support without irccat", @"(╯°□°）╯︵ ┻━┻ T H I S  I S  R I D I C U L O U S"];
		extra = ary[arc4random() % [ary count]];
	}
	else
		NSLog(@"WTF?!?!! %@", command);
	[self sendMessage:[@"NOTICE " stringByAppendingFormat:@"%@ :\x01%@ %@\x01", from, command, extra]];
}

- (void)handleINVITE:(RCMessage *)message {
	NSString *from = nil;
	NSString *channel = [message parameterAtIndex:1];
	RCParseUserMask(message.sender, &from, nil, nil);
	RCInviteRequestAlert *alert = [[RCInviteRequestAlert alloc] initWithTitle:[NSString stringWithFormat:@"%@\r\n(%@)", channel, [self _description]] message:[NSString stringWithFormat:@"%@ has invited you to %@", from, channel] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Join", nil];
	dispatch_sync(dispatch_get_main_queue(), ^ {
		[alert show];
		[alert release];
	});
}

- (void)handleJOIN:(RCMessage *)message {
	NSString *from = nil;
	RCParseUserMask(message.sender, &from, nil, nil);
	if ([from isEqualToString:useNick]) {
		[[self addChannel:[message parameterAtIndex:0] join:NO] setSuccessfullyJoined:YES];
	}
	else {
		[[self channelWithChannelName:[message parameterAtIndex:0]] recievedMessage:nil from:from type:RCMessageTypeJoin];
	}
}

- (void)handleKICK:(RCMessage *)message {
	NSString *from = nil;
	RCParseUserMask(message.sender, &from, nil, nil);
	NSArray *kickInfo = [NSArray arrayWithObjects:[message parameterAtIndex:1], [message parameterAtIndex:2], nil];
	RCChannel *targetChannel = [self channelWithChannelName:[message parameterAtIndex:0]];
	NSRange rangeOfTime = [message->message rangeOfString:@"\x12\x13"];
	if (rangeOfTime.location != NSNotFound) {
		NSString *time = [message->message substringFromIndex:rangeOfTime.location];
		[targetChannel recievedMessage:(NSString *)kickInfo from:from time:time type:RCMessageTypeKick];
	}
	else {
		[targetChannel recievedMessage:(NSString *)kickInfo from:from type:RCMessageTypeKick];
	}
	if ([[message parameterAtIndex:1] isEqualToString:useNick]) {
		[targetChannel setJoined:NO];
		// check boolean
		// setup auto-rejoin timer
		// k
	}
}

- (void)handleMODE:(RCMessage *)message {
	RCChannel *targetChannel = [self channelWithChannelName:[message parameterAtIndex:0]];
	NSString *from = nil;
	RCParseUserMask(message.sender, &from, nil, nil);
	NSString *testMethod = [message->message stringByReplacingOccurrencesOfString:@" " withString:@""];
	if ([message->message length] - [testMethod length] <= 1) return;
	[targetChannel recievedMessage:[NSString stringWithFormat:@"%@ %@", [message parameterAtIndex:1], [message parameterAtIndex:2]] from:from type:RCMessageTypeMode];
	if ([message->message length] - [testMethod length] > 1) {
		[targetChannel setMode:[message parameterAtIndex:1] forUser:[message parameterAtIndex:2]];
	}
	// only tested with banning people. ;P not channel modes, etc
	// Relay[2626:f803] MSG: :ac3xx!ac3xx@rox-103C7229.ac3xx.com MODE #chat +o _m
}

- (void)handleNICK:(RCMessage *)message {
	NSLog(@"fsd %@[%@]%@", message->message, [message parameterAtIndex:0], message.sender);
	NSString *person = nil;
	NSString *newNick = [message parameterAtIndex:0];
	RCParseUserMask(message.sender, &person, nil, nil);
	if ([person isEqualToString:useNick]) {
		// i changed my nick. welp
		nick = newNick;
		self.useNick = newNick;
	}
	for (RCChannel *chan in _channels) {
		if ([chan isUserInChannel:person])
			[chan changeNick:person toNick:newNick];
	}
}

- (void)handleNOTICE:(RCMessage *)message {
	if (!isRegistered) return;
	NSString *from = nil;
	RCParseUserMask(message.sender, &from, nil, nil);
	if ([[[[[RCChatController sharedController] currentPanel] channel] delegate] isEqual:self]) {
		[[[[RCChatController sharedController] currentPanel] channel] recievedMessage:[message parameterAtIndex:1] from:from type:RCMessageTypeNotice];
	}
	else {
		[[self consoleChannel] recievedMessage:[message parameterAtIndex:1] from:from type:RCMessageTypeNotice];
	}
}

- (void)handlePART:(RCMessage *)message {
    NSString *from = message.sender;
	RCParseUserMask(from, &from, nil, nil);
	RCChannel *channel = [self channelWithChannelName:[message parameterAtIndex:0]];
	if ([useNick isEqualToString:from]) {
		[channel setJoined:NO];
	}
	if (![[message parameterAtIndex:0] isEqualToString:message->message])
		[channel recievedMessage:[message parameterAtIndex:1] from:from type:RCMessageTypePart];
	else [channel recievedMessage:@"" from:from type:RCMessageTypePart];
}

- (void)handlePING:(id)pong {
	if (![pong isKindOfClass:[RCMessage class]]) {
		if ([pong hasPrefix:@"PING "]) {
			// NSString here.
			[self sendMessage:[@"PONG " stringByAppendingString:[pong substringFromIndex:5]] canWait:NO];
		}
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
	NSString *target = [message parameterAtIndex:0];
	RCParseUserMask(message.sender, &from, nil, nil);
	if ([fullMessage hasPrefix:@"\x01"] && [fullMessage hasSuffix:@"\x01"]) {
		fullMessage = [fullMessage substringWithRange:NSMakeRange(1, [fullMessage length]-2)];
		if ([fullMessage hasPrefix:@"ACTION"]) {
			userMessage = [fullMessage substringFromIndex:7];
			if (![[message parameterAtIndex:0] hasPrefix:@"#"]) {
				RCParseUserMask(message.sender, &target, nil, nil);
			}
			typ = RCMessageTypeAction;
		}
		else if ([fullMessage hasPrefix:@"PING"]) {
			[self handlePING:message];
			return;
		}
		else {
			NSRange actionTag = [fullMessage rangeOfString:@" "];
			if (actionTag.location != NSNotFound) {
				NSString *action = [fullMessage substringWithRange:NSMakeRange(0, actionTag.location)];
				[self handleCTCPRequest:action from:message.sender];
			}
			else {
				[self handleCTCPRequest:fullMessage from:message.sender];
			}
			return;
		}
	}
	else {
		if (![[message parameterAtIndex:0] hasPrefix:@"#"]) {
			RCParseUserMask(message.sender, &target, nil, nil);
		}
		userMessage = [message parameterAtIndex:1];
	}
	RCChannel *channel = [self channelWithChannelName:target ifNilCreate:YES];
	[channel recievedMessage:userMessage from:from type:typ];
}

- (void)handleQUIT:(RCMessage *)message {
	NSString *from = message.sender;
	RCParseUserMask(from, &from, nil, nil);
	for (RCChannel *chan in _channels) {
		[chan recievedMessage:message->message from:from type:RCMessageTypeQuit];
	}
}

- (void)handleTOPIC:(RCMessage *)message {
	// RPL_SOMETHINGTOPICRELATED
	NSString *from = nil;
	RCParseUserMask(message.sender, &from, nil, nil);
	[[self channelWithChannelName:[message parameterAtIndex:0]] recievedMessage:[message parameterAtIndex:1] from:from type:RCMessageTypeTopic];
	// :Maximus!~textual@108.132.139.52 TOPIC #k_ :hi
}

void RCParseUserMask(NSString *mask, NSString **_nick, NSString **user, NSString **hostmask) {
	// this is experimental. ;P
	if (_nick)
		*_nick = nil;
	if (user)
		*user = nil;
	if (hostmask)
		*hostmask = nil;
	NSRange nickRange = [mask rangeOfString:@"!"];
	NSRange userRange = [mask rangeOfString:@"@"];
	if (nickRange.location == NSNotFound || userRange.location == NSNotFound) {
		*_nick = mask;
		return;
	}
	*_nick = [mask substringWithRange:NSMakeRange(0, nickRange.location)];
	if (!user) return;
	*user = [mask substringWithRange:NSMakeRange(nickRange.location + 1, userRange.location - (nickRange.location + 1))];
	if (!hostmask) return;
	*hostmask = [mask substringWithRange:NSMakeRange(userRange.location + 1, [mask length] - (userRange.location + 1))];
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
	// controls flood, i guess.
	if (![alertView isKindOfClass:[RCInviteRequestAlert class]]) return;
	NSString *str = alertView.title;
	NSRange rrs = [str rangeOfString:@"\r\n"];
	str = [str substringToIndex:rrs.location];
	if ([[self channelWithChannelName:str] joined]) {
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
				RCChannel *chan = [self addChannel:str join:NO]; // in case it bails out first
				[chan setJoined:YES];
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
