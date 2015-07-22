//
//  RCNetwork.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCNetwork.h"
#import "NSData+Instance.h"
#import <objc/runtime.h>
#include <netdb.h>

SSL_CTX *RCInitContext(void) {
	SSL_METHOD *meth;
	SSL_CTX *_ctx;
	OpenSSL_add_all_algorithms();
	SSL_load_error_strings();
	meth = (SSL_METHOD *)SSLv23_client_method();
	_ctx = SSL_CTX_new(meth);
	if (_ctx == NULL) {
		NSLog(@"Error allocating SSL context.");
		//	ERR_print_errors(stderr);
	}
	return _ctx;
}

@implementation RCNetwork
@synthesize prefix, sDescription, server, nick, username, realname, spass, npass, port, isRegistered, useSSL, _channels, useNick, _nicknames, shouldRequestSPass, shouldRequestNPass, listCallback, expanded, uUID, isOper, isAway, connectCommands, tagged, delegate, channelDelegate;

- (id)init {
	if ((self = [super init])) {
		status = RCSocketStatusClosed;
		sockfd = -1;
		ctx = NULL;
		ssl = NULL;
		prefix = nil;
		self.useNick = @"(Not Sent)";
		_channels = [[NSMutableArray alloc] init];
		_nicknames = [[NSMutableArray alloc] init];
		tmpChannels = [[NSMutableArray alloc] init];
		self.connectCommands = [[[NSArray alloc] init] autorelease];
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
	[network setUUID:[info objectForKey:UUID_KEY]];
	[network setExpanded:[[info objectForKey:EXPANDED_KEY] boolValue]];
//	if ([[info objectForKey:S_PASS_KEY] boolValue]) {
//		RCKeychainItem *item = [RCKeychainItem sharedKeychain];
//		[network setSpass:[item objectForKey:[NSString stringWithFormat:@"%@spass", [network uUID]]]];
//		if ([network spass] == nil || [[network spass] length] == 0) {
//			[network setShouldRequestSPass:YES];
//		}
//	}
//	if ([[info objectForKey:N_PASS_KEY] boolValue]) {
//		RCKeychainItem *item = [RCKeychainItem sharedKeychain];
//		[network setNpass:[item objectForKey:[NSString stringWithFormat:@"%@npass", [network uUID]]]];
//		if ([network npass] == nil || [[network npass] length] == 0) {
//			[network setShouldRequestNPass:YES];
//		}
//	}
	NSMutableArray *channels = [[[info objectForKey:CHANNELS_KEY] mutableCopy] autorelease];
	if (!channels) {
		[network addChannel:CONSOLECHANNEL join:NO];
	}
	else {
        NSOrderedSet *set = [NSOrderedSet orderedSetWithArray:channels];
        channels = [[[set array] mutableCopy] autorelease];
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
	[newNet setSpass:spass];
	[newNet setNpass:npass];
	for (RCChannel *chan in _channels) {
		RCChannel *nChan = [newNet addChannel:[chan channelName] join:NO];
		[nChan setPassword:[chan password]];
	}
	CFUUIDRef uRef = CFUUIDCreate(NULL);
	CFStringRef uStringRef = CFUUIDCreateString(NULL, uRef);
	CFRelease(uRef);
	[newNet setUUID:(NSString *)uStringRef];
	CFRelease(uStringRef);
	return [newNet autorelease];
}

- (void)performCopyoverWithNetwork:(RCNetwork *)net {
	BOOL connected = NO;
	if ([net isConnected])
		connected = TRUE;
	if (connected)
		[self disconnectWithMessage:@"Merging Changes."];
	for (RCChannel *chan in [net _channels]) {
		for (RCChannel *chan2 in _channels) {
			if ([chan isEqual:chan2]) {
				[chan setPanel:[chan2 panel]];
			}
		}
	}
	
	if (connected)
		[net connect];
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
			uUID, UUID_KEY,
			(expanded ? (id)kCFBooleanTrue : (id)kCFBooleanFalse), EXPANDED_KEY,
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
	[_nicknames release];
	[uUID release];
	[writebuf release];
	[rcache release];
	[server release];
	[nick release];
	[username release];
	[realname release];
	[spass release];
	[npass release];
	[sDescription release];
	[tmpChannels release];
	self.useNick = nil;
	[self setPrefix:nil];
	[self setConnectCommands:nil];
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
		RCChannel *_chan = [self addChannel:chan join:NO];
		[_chan setJoinOnConnect:jOC];
		[_chan retrievePassword];
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
			if ([[chan channelName] isEqualToString:CONSOLECHANNEL] && [chan isKindOfClass:[RCConsoleChannel class]]) {
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
		return (RCChannel *)chan; // ???
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

- (RCChannel *)pmChannelWithChannelName:(NSString *)chan {
	RCChannel *_chan = [self channelWithChannelName:chan];
	if (_chan) return _chan;
	for (RCPMChannel *achan in tmpChannels) {
		if ([[achan channelName] isEqualToString:chan]) {
			return achan;
		}
	}
	return nil;
}

- (RCChannel *)addChannel:(NSString *)_chan join:(BOOL)join {
	@synchronized(self) {
		if ([_chan hasPrefix:@" "]) {
			_chan = [_chan stringByReplacingOccurrencesOfString:@" " withString:@""];
		}
		if (![self channelWithChannelName:_chan ifNilCreate:NO]) {
			RCChannel *chan = nil;
			if ([_chan isEqualToString:CONSOLECHANNEL]) chan = [[RCConsoleChannel alloc] initWithChannelName:_chan];
			else if ([_chan hasPrefix:@"#"] || [_chan hasPrefix:@"&"]) chan = [[RCChannel alloc] initWithChannelName:_chan];
			else chan = [[RCPMChannel alloc] initWithChannelName:_chan];
			[chan setDelegate:self];
			[chan retrievePassword];
			if ([chan isKindOfClass:[RCConsoleChannel class]]) {
				[_channels insertObject:chan atIndex:0];
			}
			else {
				[_channels addObject:chan];
			}
			if (join) [chan setJoined:YES withArgument:nil];
			if (isRegistered) {
//				[[RCNetworkManager sharedNetworkManager] saveNetworks];
//				reloadNetworks();
			}
			return [chan autorelease];
		}
		else {
			RCChannel *chan = [self channelWithChannelName:_chan];
			return chan;
		}
	}
}

- (RCChannel *)addTemporaryChannelListingIfItDoesntAlreadyExist:(NSString *)_chan {
	@synchronized(self) {
		RCPMChannel *chan = [self pmChannelWithChannelName:_chan];
		if (!chan) {
			chan = [[RCPMChannel alloc] initWithChannelName:_chan];
			[chan setDelegate:self];
			[tmpChannels addObject:chan];
			[chan release];
		}
		// if channel not found, create it and place it.
		return chan;
	}
	return nil;
}

- (void)removeChannel:(RCChannel *)chan {
	[self removeChannel:chan withMessage:@"Relay Chat."];
}

- (void)removeChannel:(RCChannel *)chan withMessage:(NSString *)quitter {
	@synchronized(self) {
		if (!chan) return;
		[chan setJoined:NO withArgument:quitter];
		[_channels removeObject:chan];
//		[[RCNetworkManager sharedNetworkManager] saveNetworks];
//		reloadNetworks();
	}
}

- (void)moveChannelAtIndex:(int)idx toIndex:(int)newIdx; {
	RCChannel *ctrlChan = [_channels objectAtIndex:idx];
	[ctrlChan retain];
	[_channels removeObjectAtIndex:idx];
	[_channels insertObject:ctrlChan atIndex:newIdx-1];
	[ctrlChan release];
//	[[RCNetworkManager sharedNetworkManager] saveNetworks];
}

- (void)savePasswords {
	if (!uUID) return;
	if (spass) {
//		RCKeychainItem *keychain = [RCKeychainItem sharedKeychain];
//		[keychain setObject:spass forKey:[NSString stringWithFormat:@"%@spass", uUID]];
	}
	if (npass) {
//		RCKeychainItem *keychain = [RCKeychainItem sharedKeychain];
//		[keychain setObject:npass forKey:[NSString stringWithFormat:@"%@npass", uUID]];
	}
	// should consider making RCPasswordStore or something. ~Maximus
}

#pragma mark - SOCKET STUFF

- (void)connect {
	[disconnectTimer invalidate];
	disconnectTimer = nil;
	if (status == RCSocketStatusConnected || status == RCSocketStatusConnecting) return;
	status = RCSocketStatusConnecting;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	writebuf = [[NSMutableString alloc] init];
	rcache = [[NSMutableData alloc] init];
	isRegistered = NO;
	self.useNick = nick;
	
	sockfd = [self _connectSocket];
	if (sockfd < 0) {
		return;
	}
	
	[self.delegate networkConnected:self];

	dispatch_source_t readSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, sockfd, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
	dispatch_source_set_event_handler(readSource, ^ {
		[self read];
	});
	
	dispatch_source_t writeSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_WRITE, sockfd, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
	
	dispatch_source_set_event_handler(writeSource, ^ {
		if (self.hasPendingBites)
			[self write];
	});
	
	dispatch_resume(readSource);
	dispatch_resume(writeSource);
	
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
	[pool drain];
}

- (int)_connectSocket {
	struct hostent *host;
	struct sockaddr_in addr;
	if ((host = gethostbyname([server UTF8String])) == NULL) {
		[self.delegate network:self connectionFailed:RCConnectionFailureObtainingHost];
		// ERROR OBTAINING HOST
		return -1;
	}
	int _sfd = socket(AF_INET, SOCK_STREAM, 0);
	if (_sfd < 0) {
		[self.delegate network:self connectionFailed:RCConnectionFailureEstablishingSocket];
		// ERROR ESTABLISHING SOCKET(?)
		return -1;
	}
	int set = 1;
	setsockopt(_sfd, SOL_SOCKET, SO_NOSIGPIPE, (void *)&set, sizeof(int));
	bzero(&addr, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);
	addr.sin_addr.s_addr = *(in_addr_t *)(host->h_addr);
	if (connect(_sfd, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
		[self.delegate network:self connectionFailed:RCConnectionFailureConnecting];
		// ERROR CONNECTING
		return -1;
	}
	if (useSSL) {
		SSL_library_init();
		SSL_CTX *rCTX = RCInitContext();
		ctx = rCTX;
		ssl = SSL_new(ctx);
		SSL_set_fd(ssl, _sfd);
		if (SSL_connect(ssl) == -1) {
			// ERROR CONNECTING (VIA SSL?)
			[self.delegate network:self connectionFailed:RCConnectionFailureConnectingViaSSL];
			return -1;
		}
	}

	return _sfd;
}

- (RCMessage *)temporaryMessageFromString:(NSString *)str {
	RCMessage *msg = [[RCMessage alloc] init];
	msg->message = [str retain];
	return [msg autorelease];
}

- (BOOL)hasPendingBites {
	if (!writebuf) return NO;
	return [writebuf length] > 0;
}

- (BOOL)read {
	NSLog(@"gds reading..");
	static BOOL isReading;
	if (sockfd == -1) return NO;
	if (isReading) return YES;
	isReading = YES;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	char buf[4097];
	ssize_t rc = 0;
	if (useSSL)
		rc = SSL_read(ssl, buf, 1024);
	else
		rc = read(sockfd, buf, 1024);
	if (rc <= 0) {
		[pool drain];
		return NO;
	}
	
	if (![self isTryingToConnectOrConnected]) return NO;
	[rcache appendBytes:buf length:rc];
	NSRange rr = [rcache rangeOfData:[NSData nlCharacterDataSet] options:0 range:NSMakeRange(0, [rcache length])];
	while (rr.location != NSNotFound) {
		if (rr.location == 0) break;
		NSData *data = [rcache subdataWithRange:NSMakeRange(0, rr.location + 2)];
		NSString *recd = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		if (recd) {
			[self recievedMessage:recd];
		}
		else {
			recd = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
			if (!recd) {
				// perhaps mac os roman, seems to work for all.
			}
			[self recievedMessage:recd];
		}
		[recd autorelease];
		[rcache replaceBytesInRange:NSMakeRange(0, rr.location + 2) withBytes:NULL length:0];
		rr = [rcache rangeOfData:[NSData nlCharacterDataSet] options:0 range:NSMakeRange(0, [rcache length])];
	}
	
	[pool release];
	isReading = NO;
	return NO;
}

- (BOOL)write {
	if (sockfd == -1) {
		MARK;
		return NO;
	}
	if (isWriting) {
		MARK;
		return NO;
	}
	isWriting = YES;
	int written = 0;
	if (useSSL) {
		written = SSL_write(ssl, [writebuf UTF8String], strlen([writebuf UTF8String]));
	}
	else {
		written = write(sockfd, [writebuf UTF8String], strlen([writebuf UTF8String]));
	}
	const char *buf = [writebuf UTF8String];
	buf = buf + written;
	[writebuf release];
	writebuf = [[NSMutableString alloc] initWithCString:buf encoding:NSUTF8StringEncoding];
	// this math works. But there must be a more sensible way.
	isWriting = NO;
	return YES;
}

- (BOOL)sendMessage:(NSString *)msg {
	return [self sendMessage:msg canWait:YES];
}

- (BOOL)sendMessage:(NSString *)msg canWait:(BOOL)canWait {
#if LOGALL
	NSLog(@"Sending: [%@]", msg);
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
	NSLog(@"Error: [%@]", [error localizedDescription]);
}

- (void)recievedMessage:(NSString *)msg {
#if LOGALL
	NSLog(@"Recieved: [%@]", msg);
#endif
	if ([msg isEqualToString:@""] || msg == nil || [msg isEqualToString:@"\r\n"]) return;
	msg = [msg stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
	
	if ([msg hasPrefix:@"PING"]) {
		[self handlePING:msg];
		return;
	}
	else if ([msg hasPrefix:@"ERROR"]) {
		NSLog(@"Errorz. %@:%@", msg, server);
		NSString *error = [msg substringWithRange:NSMakeRange(5, [msg length]-5)];
		if ([error hasPrefix:@" :"]) error = [error substringFromIndex:2];
		[self disconnectCleanupWithMessage:error];
		// this posts to chat view as
		// Disconnected: Closing Link (~iPhone@108.132.140.49) [Quit: Relay 1.0]
		return;
	}
	
	if (![msg hasPrefix:@":"] && ![msg hasPrefix:@"@"]) {
		if ([msg hasPrefix:@"AUTHENTICATE"]) {
			[self handleAUTHENTICATE:msg];
		}
		return;
	}
	
	RCMessage *message = [[RCMessage alloc] initWithString:msg];
	[message parse];
	
	NSString *selName = [NSString stringWithFormat:@"handle%@:", [message numeric]];
	SEL pSEL = NSSelectorFromString(selName);
	if ([self respondsToSelector:pSEL]) ((void (*)(id, SEL, id))objc_msgSend)(self, pSEL, message);
	else {
		[self handleNotHandledMessage:message];
	}
	[message release];
}

- (BOOL)isTryingToConnectOrConnected {
	return ([self isConnected] || status == RCSocketStatusConnecting);
}

- (NSString *)defaultQuitMessage {
//	NSString *str = [[RCNetworkManager sharedNetworkManager] valueForSetting:DEF_QUITMSG];
//	if (str) return str;
	// I don't think this is thread safe, or the proper place to do this.
	return @"Ciao!";
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
		[self disconnectCleanupWithMessage:[self defaultQuitMessage]];
	}
}

- (void)disconnectCleanupWithMessage:(NSString *)msg {
	if (status == RCSocketStatusClosed) return;
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
	isRegistered = NO;
	[[self consoleChannel] disconnected:msg];
	for	(RCChannel *_chan in _channels) {
		if (![_chan isKindOfClass:[RCConsoleChannel class]])
			[_chan disconnected:@"Disconnected."];
	}
//	reloadNetworks();
}

- (BOOL)disconnect {
	return [self disconnectWithMessage:[self defaultQuitMessage]];
}

- (void)networkDidRegister:(BOOL)reg {
	isRegistered = YES;
	RCChannel *chan = [self consoleChannel];
	if (chan) [chan recievedMessage:@"Connected to host." from:@"" time:nil type:RCMessageTypeNormal];
	if (saslWasSuccessful)
		if ([npass length] > 0)
			[self sendMessage:[@"PRIVMSG NickServ :IDENTIFY " stringByAppendingString:npass]];
	
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
	NSString *b64 = [[NSString stringWithFormat:@"%@%C%@%C%@", useNick, (unsigned short)0x00, useNick, (unsigned short)0x00, npass] base64];
	[self sendMessage:[NSString stringWithFormat:@"AUTHENTICATE %@", b64] canWait:NO];
}

- (void)handleNotHandledMessage:(RCMessage *)message {
	RCChannel *chan = [self consoleChannel];
	[chan recievedMessage:message->message from:@"" time:nil type:RCMessageTypeNormal];
	NSLog(@"PLZ IMPLEMENT handle%@:%@", [message numeric], message->message);
}

- (void)handle001:(RCMessage *)message {
	// RPL_WELCOME
	// :Welcome to the Internet Relay Network <nick>!<user>@<host>
	status = RCSocketStatusConnected;
	[self networkDidRegister:YES];
	RCChannel *chan = [self consoleChannel];
	[chan recievedMessage:message from:@"" time:nil type:RCMessageTypeNormal];
//	reloadNetworks();
}

- (void)handle002:(RCMessage *)message {
	// RPL_YOURHOST
	RCChannel *chan = [self consoleChannel];
	[chan recievedMessage:message from:@"" time:nil type:RCMessageTypeNormal];
}

- (void)handle003:(RCMessage *)message {
	// RPL_CREATED
	RCChannel *chan = [self consoleChannel];
	[chan recievedMessage:message from:@"" time:nil type:RCMessageTypeNormal];
}

- (void)handle004:(RCMessage *)message {
	// RPL_MYINFO
	RCChannel *chan = [self consoleChannel];
	[chan recievedMessage:message from:@"" time:nil type:RCMessageTypeNormal];
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
		// BALLS
		[[self consoleChannel] recievedMessage:message from:@"" time:nil type:RCMessageTypeNormal];
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
//		RCServerChangeAlertView *ac = [[RCServerChangeAlertView alloc] initWithTitle:nil message:alertString delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Change", nil];
//		[ac setServer:redirServer];
//		[ac setPort:[redirPort intValue]];
//		[ac setTag:RCALERR_SERVCHNGE];
//		dispatch_async(dispatch_get_main_queue(), ^ {
//			[ac show];
//			[ac release];
//		});
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

/*
 I setup a flag in settings for inline-ing the WHOIS information
 so that it doesn't go to the user list pane thing and make it impossible to refer back to them
 this must consider the fact that if you whois someone in a PM, it must go to the user list 
 thing anyways. It's only sensible.
 Anyways, If you're in a general channel, and you whois someone, and this flag is set to true
 it should display it with special formatting like textual does.
 ~Maximus
 */

- (void)handle311:(RCMessage *)message {
	// RPL_WHOISUSER
	// :irc.saurik.com 311 __mxms flux ~flux 192.252.217.30 * :flux
	NSString *name = [message parameterAtIndex:1];
	NSString *rn = [message parameterAtIndex:2];
	NSString *ips = [message parameterAtIndex:3];
	NSString *ident = [message parameterAtIndex:5];
	NSString *final = [NSString stringWithFormat:@"%@ has userhost %@@%@ and real name \"%@\"", name, rn, ips, ident];
//    if ([[[RCNetworkManager sharedNetworkManager] valueForSetting:INLINEWHOIS_KEY] boolValue]) {
//        // Inline Whois
//        [[[RCChatController sharedController] currentChannel] recievedMessage:final from:@"-" time:nil type:RCMessageTypeEvent];
//    } else {
//        // Normal Whois
//        RCPMChannel *user = (RCPMChannel *)[self pmChannelWithChannelName:[message parameterAtIndex:1]];
//        [user setIpInfo:final];
//    }
}

- (void)handle312:(RCMessage *)message {
	// RPL_WHOISSERVER
	// :irc.saurik.com 312 mxms__ Maximus *.irc.saurik.com :Saurik
//	NSString *connInfo = [NSString stringWithFormat:@"%@ is connected on %@ (%@)", [message parameterAtIndex:1], [message parameterAtIndex:2], [message parameterAtIndex:3]];
//    if ([[[RCNetworkManager sharedNetworkManager] valueForSetting:INLINEWHOIS_KEY] boolValue]) {
//        // Inline Whois
////        - (void)recievedMessage:(NSString *)message from:(NSString *)from time:(NSString *)time type:(RCMessageType)type
//        [[[RCChatController sharedController] currentChannel] recievedMessage:connInfo from:@"" time:nil type:RCMessageTypeEvent];
//    } else {
//        // Normal Whois
//        RCPMChannel *chan = (RCPMChannel *)[self pmChannelWithChannelName:[message parameterAtIndex:1]];
//        [chan setConnectionInfo:connInfo];
//    }
}

- (void)handle313:(RCMessage *)message {
	// RPL_WHOISOPERATOR
}

- (void)handle317:(RCMessage *)message {
	// :irc.saurik.com 317 mxms__ Maximus 12 1376202021 :seconds idle, signon time
	// i don't want to parse this. ever.
	// Format should be
	// [01:38:29] Ouroboros signed on at December 25, 2013 at 8:09:05 PM EST and has been idle for 23 Seconds
}

- (void)handle318:(RCMessage *)message {
	RCPMChannel *channel = (RCPMChannel *)[self pmChannelWithChannelName:[message parameterAtIndex:1]];
	[channel recievedWHOISInformation];
	// RPL_ENDOFWHOIS
}

- (void)handle319:(RCMessage *)message {
	// RPL_WHOISCHANNELS
	NSString *channels = [message parameterAtIndex:2];
//	if (channel) {
		NSArray *chans = [channels componentsSeparatedByString:@" "];
		NSMutableString *str = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@ is currently in ", [message parameterAtIndex:1]]];
		if ([chans count] > 1) {
			for (int i = 0; i < [chans count]; i++) {
				NSString *cc = [chans objectAtIndex:i];
				if ([cc isEqualToString:@" "] || [cc isEqualToString:@""]) continue;
				[str appendFormat:@"%@%@", RCNickWithoutRank(cc, self), ((i == ([chans count] - 3)) ? @", and " : @", ")];
			}
		}
		else {
			[str appendString:[chans objectAtIndex:0]];
		}
		if ([str hasSuffix:@", "])
			[str deleteCharactersInRange:NSMakeRange(str.length - 2, 2)];
    
//    if ([[[RCNetworkManager sharedNetworkManager] valueForSetting:INLINEWHOIS_KEY] boolValue]) {
//        // Inline Whois
//        [[[RCChatController sharedController] currentChannel] recievedMessage:str from:@"" time:nil type:RCMessageTypeEvent];
//    } else {
//        // Normal Whois
//        RCPMChannel *channel = (RCPMChannel *)[self pmChannelWithChannelName:[message parameterAtIndex:1]];
//		[channel setChanInfos:str];
//		// maybe separate these with commans, and put 'and' at the end to be fancy. ;P
//		// Maximus is in #theos, #iphonedev, #bacon, #k, and #_k
//		// hm... i like it
//		// ~Maximus
//	}
//    [str release];
	// :irc.saurik.com 319 mxms__ Maximus :#theos #iphonedev #bacon @#k @#_k
}

- (void)handle321:(RCMessage *)message {
	[listCallback setUpdating:YES];
	// RPL_LISTSTART
}

- (void)handle322:(RCMessage *)message {
	// RPL_LIST
	if (!listCallback) return;
	NSString *chan = [message parameterAtIndex:1];
	//:irc.saurik.com 322 iPhone *
	if ([chan isEqualToString:@"*"]) return;
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
	[[self channelWithChannelName:channel] recievedMessage:[NSString stringWithFormat:@"Website is %@", website] from:@"" time:nil type:RCMessageTypeEvent];
}

- (void)handle331:(RCMessage *)message {
	// RPL_NOTOPIC
	NSString *channel = [message parameterAtIndex:1];
	[[self channelWithChannelName:channel ifNilCreate:YES] recievedMessage:@"No topic set." from:@"" time:nil type:RCMessageTypeTopic];
}

- (void)handle332:(RCMessage *)message {
	// RPL_TOPIC
	NSString *channel = [message parameterAtIndex:1];
	NSString *topic = [message parameterAtIndex:2];
	[[self channelWithChannelName:channel ifNilCreate:YES] recievedMessage:topic from:nil time:nil type:RCMessageTypeTopic];
}

- (void)handle333:(RCMessage *)message {
	// RPL_TOPICWHOTIME(?)
	NSString *channel = [message parameterAtIndex:1];
	NSString *setter = [message parameterAtIndex:2];
	RCParseUserMask(setter, &setter, nil, nil);
	int ts = [[message parameterAtIndex:3] intValue];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MMMM dd, yyyy hh:mm:ss a"];
	NSString *time = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:ts]];
	[dateFormatter release];
	[[self channelWithChannelName:channel] recievedMessage:[NSString stringWithFormat:@"Set by %c%@%c on %@", RCIRCAttributeBold, setter, RCIRCAttributeBold, time] from:@"" time:nil type:RCMessageTypeNormalE2];
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
}

- (void)handle372:(RCMessage *)message {
	// RPL_MOTD
//	NSString *val = [[RCNetworkManager sharedNetworkManager] valueForSetting:SHOW_MOTD_KEY];
//	if (val) {
//		if ([val boolValue]) {
//			NSString *line = [message parameterAtIndex:1];
//			RCChannel *chan = [self consoleChannel];
//			[chan recievedMessage:line from:@"" time:nil type:RCMessageTypeNormal];
//		}
//	}
}

- (void)handle375:(RCMessage *)message {
	// RPL_ENDOFMOTD
//	NSString *val = [[RCNetworkManager sharedNetworkManager] valueForSetting:SHOW_MOTD_KEY];
//	if (val) {
//		if ([val boolValue]) {
//			NSString *string = [message parameterAtIndex:1];
//			RCChannel *chan = [self consoleChannel];
//			[chan recievedMessage:string from:@"" time:nil type:RCMessageTypeNormal];
//		}
//	}
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
	[chan recievedMessage:[NSString stringWithFormat:@"%@ %@", host, info] from:@"" time:nil type:RCMessageTypeEvent];
}

- (void)handle401:(RCMessage *)message {
	// no such nick/channel
    // Please don't hate me Maximus
    RCPMChannel *user = (RCPMChannel *)[self pmChannelWithChannelName:[message parameterAtIndex:1]];
    NSString *final = [NSString stringWithFormat:@"User %@ is not online.", [message parameterAtIndex:1]];
	[user setIpInfo:final];
    [user setConnectionInfo:@""];
    [user setChanInfos:@""];
}

- (void)handle403:(RCMessage *)message {
	// no such channel
}

- (void)handle404:(RCMessage *)message {
	// ERR_CANNOTSENDTOCHAN
	NSString *channel = [message parameterAtIndex:1];
	NSString *reason = [message parameterAtIndex:2];
	[[self channelWithChannelName:channel ifNilCreate:YES] recievedMessage:reason from:@"" time:nil type:RCMessageTypeError];
}

- (void)handle421:(RCMessage *)message {
	// ERR_UNKNOWNCOMMAND
	NSString *command = [message parameterAtIndex:1];
	NSString *reason = [message parameterAtIndex:2];
	NSString *string = [NSString stringWithFormat:@"Error(421): %@ %@", command, reason];
	if ([command isEqualToString:@"CAP"]) {
		// uh
	}
//	[[[RCChatController sharedController] currentChannel] recievedMessage:string from:@"" time:nil type:RCMessageTypeError];
}

- (void)handle422:(RCMessage *)message {
	// ERR_NOMOTD
}

- (void)handle432:(RCMessage *)message {
	// ERR_ERRONEUSNICKNAME
//	dispatch_async(dispatch_get_main_queue(), ^{
//		RCPrettyAlertView *ac = [[RCPrettyAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Invalid Nickname (%@)", [self _description]] message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Change", nil];
//		[ac setTag:RCALERR_INCNICK];
//		[ac setAlertViewStyle:UIAlertViewStylePlainTextInput];
//		[ac show];
//		[ac release];
//	});
}

- (void)handle433:(RCMessage *)message {
	// nERR_NICKNAMEINUSE
	self.useNick = [useNick stringByAppendingString:@"_"];
	[self sendMessage:[@"NICK " stringByAppendingString:useNick] canWait:NO];
}

- (void)handle437:(RCMessage *)message {
	[[self consoleChannel] recievedMessage:[message parameterAtIndex:2] from:nil time:nil type:RCMessageTypeNormal];
	dispatch_async(dispatch_get_main_queue(), ^{
//		RCPrettyAlertView *ac = [[RCPrettyAlertView alloc] initWithTitle:@"Nickname Unavailable" message:[NSString stringWithFormat:@"Please input another nickname for %@ below.", [self _description]] delegate:self cancelButtonTitle:@"Disconnect" otherButtonTitles:@"Retry", nil];
//		[ac setTag:RCALERR_INCUNAME];
//		[ac setAlertViewStyle:UIAlertViewStylePlainTextInput];
//		[ac show];
//		[ac release];
	});
}

- (void)handle461:(RCMessage *)message {
	// this is broken
	// type /nick for example.
	// wether you hit change or cancel, it disconnects you
	// its stupid.
	if (isRegistered) {
		dispatch_async(dispatch_get_main_queue(), ^{
//			RCPrettyAlertView *ac = [[RCPrettyAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Invalid Username (%@)", [self _description]] message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Change", nil];
//			[ac setTag:RCALERR_INCUNAME];
//			[ac setAlertViewStyle:UIAlertViewStylePlainTextInput];
//			[ac show];
//			[ac release];
		});
	}
}

- (void)handle464:(RCMessage *)message {
	dispatch_async(dispatch_get_main_queue(), ^{
//		RCPrettyAlertView *ac = [[RCPrettyAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Invalid Server Password (%@)", [self _description]] message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Change", nil];
//		[ac setTag:RCALERR_INCSPASS];
//		[ac setAlertViewStyle:UIAlertViewStyleSecureTextInput];
//		[ac show];
//		[ac release];
	});
}

- (void)handle473:(RCMessage *)message {
	// ERR_INVITEONLYCHAN
	NSString *channel = [message parameterAtIndex:1];
	NSString *reason = [message parameterAtIndex:2];
	// perhaps implement a KNOCK prompt here sometime
//	[[[RCChatController sharedController] currentChannel] recievedMessage:[NSString stringWithFormat:@"\x02%@\x02: %@", channel, reason] from:@"" time:nil type:RCMessageTypeError];
}

- (void)handle474:(RCMessage *)message {
	// ERR_BANNEDFROMCHANNEL
	NSString *channel = [message parameterAtIndex:1];
	NSString *reason = [message parameterAtIndex:2];
//	[[[RCChatController sharedController] currentChannel] recievedMessage:[NSString stringWithFormat:@"\x02%@\x02: %@", channel, reason] from:@"" time:nil type:RCMessageTypeError];
}

- (void)handle475:(RCMessage *)message {
	// ERR_BANNEDFROMCHANNEL
	NSString *channel = [message parameterAtIndex:1];
	NSString *reason = [message parameterAtIndex:2];
//	[[[RCChatController sharedController] currentChannel] recievedMessage:[NSString stringWithFormat:@"\x02%@\x02: %@", channel, reason] from:@"" time:nil type:RCMessageTypeError];
}

- (void)handle482:(RCMessage *)message {
	// ERR_BANNEDFROMCHANNEL
	NSString *channel = [message parameterAtIndex:1];
	NSString *reason = [message parameterAtIndex:2];
//	[[[RCChatController sharedController] currentChannel] recievedMessage:[NSString stringWithFormat:@"\x02%@\x02: %@", channel, reason] from:@"" time:nil type:RCMessageTypeError];
}

- (void)handle900:(RCMessage *)message {
	saslWasSuccessful = YES;
	[[self consoleChannel] recievedMessage:@"SASL Authenticate was successful" from:nil time:nil type:RCMessageTypeNormal];
}

- (void)handle903:(RCMessage *)message {
	[self sendMessage:@"CAP END" canWait:NO];
}

- (void)handle904:(RCMessage *)message {
	[self sendMessage:@"CAP END" canWait:NO];
	[[self consoleChannel] recievedMessage:@"SASL Authentication failed." from:nil time:nil type:RCMessageTypeNormal];
}

- (void)handle906:(RCMessage *)message {
	// :asimov.freenode.net 906 Mxms :SASL authentication aborted
}

- (void)handle998:(RCMessage *)message {
	// good work University of Michigan. Making the IRC protocol more difficult than it needs to be
	// (╯°□°）╯︵ ┻━┻ T H I S  I S  R I D I C U L O U S
}

- (void)handleAUTHENTICATE:(NSString *)auth {
	NSScanner *scanner = [[NSScanner alloc] initWithString:auth];
	NSString *tag = nil;
	NSString *message = nil;
	[scanner scanUpToString:@" " intoString:&tag];
	[scanner scanUpToString:@"" intoString:&message];
	if ([message isEqualToString:@"+"]) {
		[self sendB64SASLAuth];
	}
	[scanner release];
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
		if ([capabilities containsObject:@"sasl"] && ([npass length] > 0)) {
			[supported addObject:@"sasl"];
		}
		if ([supported count] != 0) { 
			[self sendMessage:[NSString stringWithFormat:@"CAP REQ :%@", [supported componentsJoinedByString:@" "]] canWait:NO];
		}
		else {
			[self sendMessage:@"CAP END" canWait:NO];
		}
		[supported release];
	}
	else if ([[message parameterAtIndex:1] isEqualToString:@"ACK"]) {
		// iterate through params here. meh.
		NSArray *avails = [[message parameterAtIndex:2] componentsSeparatedByString:@" "];
		BOOL sends = false;
		for (NSString *avail in avails) {
			if ([avail hasPrefixNoCase:@"sasl"]) {
				[self sendMessage:@"AUTHENTICATE PLAIN" canWait:NO];
				sends = true;
			}
		}
		if (!sends) {
			[self sendMessage:@"CAP END" canWait:NO];
		}
	}
	else {
		[self sendMessage:@"CAP END" canWait:NO];
	}
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
		extra = ary[(arc4random_uniform([ary count]))];
	}
	else
		NSLog(@"WTF?!?!! %@", command);
	[self sendMessage:[@"NOTICE " stringByAppendingFormat:@"%@ :\x01%@ %@\x01", from, command, extra]];
}

- (void)handleINVITE:(RCMessage *)message {
	NSString *from = nil;
	NSString *channel = [message parameterAtIndex:1];
	RCParseUserMask(message.sender, &from, nil, nil);
//	RCInviteRequestAlert *alert = [[RCInviteRequestAlert alloc] initWithTitle:[NSString stringWithFormat:@"%@\r\n(%@)", channel, [self _description]] message:[NSString stringWithFormat:@"%@ has invited you to %@", from, channel] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Join", nil];
//	dispatch_sync(dispatch_get_main_queue(), ^ {
//		[alert show];
//		[alert release];
//	});
}

- (void)handleJOIN:(RCMessage *)message {
	NSString *from = nil;
	RCParseUserMask(message.sender, &from, nil, nil);
	if ([from isEqualToString:useNick]) {
		[[self addChannel:[message parameterAtIndex:0] join:NO] setSuccessfullyJoined:YES];
		[[self channelWithChannelName:[message parameterAtIndex:0]] setUserJoinedBatch:from cnt:0];
	}
	else
		[[self channelWithChannelName:[message parameterAtIndex:0]] setUserJoined:from];
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
		[targetChannel recievedMessage:(NSString *)kickInfo from:from time:nil type:RCMessageTypeKick];
	}
	if ([[message parameterAtIndex:1] isEqualToString:useNick]) {
		[targetChannel setJoined:NO];
		// check boolean
		// setup auto-rejoin timer
	}
}

- (void)handleMODE:(RCMessage *)message {
	RCChannel *targetChannel = [self channelWithChannelName:[message parameterAtIndex:0]];
	NSString *from = nil;
	RCParseUserMask(message.sender, &from, nil, nil);
	NSString *testMethod = [message->message stringByReplacingOccurrencesOfString:@" " withString:@""];
	if ([message->message length] - [testMethod length] <= 1) return;
	[targetChannel recievedMessage:[NSString stringWithFormat:@"%@ %@", [message parameterAtIndex:1], [message parameterAtIndex:2]] from:from time:nil type:RCMessageTypeMode];
	if ([message->message length] - [testMethod length] > 1) {
		[targetChannel setMode:[message parameterAtIndex:1] forUser:[message parameterAtIndex:2]];
	}
	// only tested with banning people. ;P not channel modes, etc
	// Relay[2626:f803] MSG: :ac3xx!ac3xx@rox-103C7229.ac3xx.com MODE #chat +o _m
}

- (void)handleNICK:(RCMessage *)message {
	NSString *person = nil;
	NSString *newNick = [message parameterAtIndex:0];
	RCParseUserMask(message.sender, &person, nil, nil);
	if ([person isEqualToString:useNick]) {
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
//	if ([[[[RCChatController sharedController] currentChannel] delegate] isEqual:self]) {
//		[[[RCChatController sharedController] currentChannel] recievedMessage:[message parameterAtIndex:1] from:from time:nil type:RCMessageTypeNotice];
//	}
//	else {
//		[[self consoleChannel] recievedMessage:[message parameterAtIndex:1] from:from time:nil type:RCMessageTypeNotice];
//	}
}

- (void)handlePART:(RCMessage *)message {
	NSString *from = message.sender;
	RCParseUserMask(from, &from, nil, nil);
	RCChannel *channel = [self channelWithChannelName:[message parameterAtIndex:0]];
	if ([useNick isEqualToString:from]) {
		[channel setSuccessfullyJoined:NO];
	}
	if (![[message parameterAtIndex:0] isEqualToString:message->message])
		[channel recievedMessage:[message parameterAtIndex:1] from:from time:nil type:RCMessageTypePart];
	else [channel recievedMessage:@"" from:from time:nil type:RCMessageTypePart];
}

- (void)handlePING:(id)pong {
	// RCMessage when read from buffer.
	// NSString when passed from CTCP call
	if (![pong isKindOfClass:[RCMessage class]]) {
		if ([pong hasPrefix:@"PING "]) {
			[self sendMessage:[@"PONG " stringByAppendingString:[pong substringFromIndex:5]] canWait:NO];
		}
	}
	else {
		NSString *from = [(RCMessage *)pong sender];
		NSString *user = nil;
		RCParseUserMask(from, &user, nil, nil);
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
				target = from;
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
	[channel recievedMessage:userMessage from:from time:nil type:typ];
}

- (void)handleQUIT:(RCMessage *)message {
	NSString *from = message.sender;
	RCParseUserMask(from, &from, nil, nil);
	for (RCChannel *chan in _channels) {
		[chan recievedMessage:message->message from:from time:nil type:RCMessageTypeQuit];
	}
}

- (void)handleTOPIC:(RCMessage *)message {
	// RPL_SOMETHINGTOPICRELATED
	NSString *from = nil;
	RCParseUserMask(message.sender, &from, nil, nil);
	[[self channelWithChannelName:[message parameterAtIndex:0]] recievedMessage:[message parameterAtIndex:1] from:from time:nil type:RCMessageTypeTopic];
	// :Maximus!~textual@108.132.139.52 TOPIC #k_ :hi
}

void RCParseUserMask(NSString *mask, NSString **_nick, NSString **user, NSString **hostmask) {
	// this is experimental. ;P
	// well, not really anymore. ;P ~Maximus
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
//	if (![alertView isKindOfClass:[RCInviteRequestAlert class]]) return;
	NSString *str = alertView.title;
	NSRange rrs = [str rangeOfString:@"\r\n"];
	str = [str substringToIndex:rrs.location];
	if ([[self channelWithChannelName:str] joined]) {
		[alertView dismissWithClickedButtonIndex:0 animated:NO];
	}
}

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//	if ([alertView isKindOfClass:[RCInviteRequestAlert class]]) {
//		switch (buttonIndex) {
//			case 0:
//				break;
//			case 1: {
//				NSString *str = alertView.title;
//				NSRange rrs = [str rangeOfString:@"\r\n"];
//				str = [str substringToIndex:rrs.location];
//				RCChannel *chan = [self addChannel:str join:NO]; // in case it bails out first
//				[chan setJoined:YES];
//				reloadNetworks();
//				[[RCChatController sharedController] selectChannel:[chan channelName] fromNetwork:self];
//				// select network here
//				break;
//			}
//			default:
//				break;
//		}
//	}
//	switch ([alertView tag]) {
//		case RCALERR_INCNICK: {
//			if (buttonIndex == 0) {
//				// cancel
//				[self disconnect];
//			}
//			else {
//				[self setNick:[alertView textFieldAtIndex:0].text];
//				[[RCNetworkManager sharedNetworkManager] saveNetworks];
//				if ([self isTryingToConnectOrConnected]) {
//					[self sendMessage:[NSString stringWithFormat:@"NICK %@", nick] canWait:NO];
//				}
//				else {
//					[self connect];
//				}
//			}
//			break;
//		}
//		case RCALERR_INCUNAME: {
//			if (buttonIndex == 0) {
//				// cancel
//				[self disconnect];
//			}
//			else {
//				[self setUsername:[alertView textFieldAtIndex:0].text];
//				[[RCNetworkManager sharedNetworkManager] saveNetworks];
//				if ([self isTryingToConnectOrConnected]) {
//					[self sendMessage:[NSString stringWithFormat:@"USER %@ %@ %@ :%@", (username ? username : nick), nick, nick, (realname ? realname : nick)] canWait:NO];
//				}
//				else {
//					[self connect];
//				}
//			}
//			break;
//		}
//		case RCALERR_INCSPASS: {
//			if (buttonIndex == 0) {
//				[self disconnect];
//			}
//			else {
//				shouldRequestSPass = NO;
//				[self setSpass:[alertView textFieldAtIndex:0].text];
//				[self savePasswords];
//				if ([self isTryingToConnectOrConnected]) {
//					[self sendMessage:[NSString stringWithFormat:@"PASS %@", spass] canWait:NO];
//				}
//				else {
//					[self connect];
//				}
//			}
//			break;
//		}
//		case RCALERR_SERVCHNGE: {
//			if (buttonIndex == 0) {
//				[self disconnect];
//			}
//			else {
//				RCServerChangeAlertView *acl = (RCServerChangeAlertView *)alertView;
//				[self setServer:[acl server]];
//				[self setPort:[acl port]];
//				[[RCNetworkManager sharedNetworkManager] saveNetworks];
//				if ([self isConnected] == NO) {
//					[self connect];
//				}
//				else {
//					[self disconnect];
//					[self connect];
//				}
//			}
//			break;
//		}
//	}
//}
//
@end
