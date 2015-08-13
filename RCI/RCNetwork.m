//
//  RCNetwork.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCNetwork.h"
#import "NSData+RCNewLineSet.h"
#import <objc/runtime.h>
#include <netdb.h>
#include <openssl/ssl.h>
#include <openssl/err.h>

static NSString *const RCConsoleChannelName = @"\x01IRC";

inline BOOL RCIRCStringIsValid(NSString *string) {
	return (string) && (![string isEqualToString:@""]) && (![string isEqualToString:@"\r\n"]);
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

SSL_CTX *RCInitContext(void);
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

@interface RCNetwork () {
	NSString *_stringDescription;
	NSString *_serverAddress;
	NSString *_nickname;
	NSString *_username;
	NSString *_realname;
	NSString *_serverPassword;
	NSString *_nickServPassword;
	NSString *_uUID;
	uint16_t _port;
	BOOL _registered;
	BOOL _useSSL;

	BOOL _networkOperator;
	BOOL _away;
	id <RCNetworkDelegate> delegate;
	id <RCChannelDelegate> channelDelegate;
	
	NSMutableArray *_channels;
	NSMutableArray *alternateNicknames;
	NSMutableString *writebuf;
	NSTimer *disconnectTimer;
	
	NSDictionary *operatorModes;
	
	BOOL _saslWasSuccessful;
}

@end

@implementation RCNetwork {
	NSMutableData *readCache;
	dispatch_source_t readSource;
	int sockfd;
	SSL_CTX *ctx;
	SSL *ssl;
	RCSocketStatus status;
	BOOL reading;
	BOOL writing;
}

@synthesize stringDescription=_stringDescription, serverAddress=_serverAddress, nickname=_nicknames, username=_username, realname=_realname, serverPassword=_serverPassword, nickServPassword=_nickServPassword, uUID=_uUID, port=_port, registered=_registered, useSSL=_useSSL, delegate=_delegate, channels=_channels, channelDelegate=_channelDelegate, alternateNicknames=_alternateNicknames, operatorModes=operatorModes;

#pragma mark Object Management

- (instancetype)init {
	if ((self = [super init])) {
		status = RCSocketStatusClosed;
		sockfd = -1;
		ctx = NULL;
		ssl = NULL;
		self.nickname = @"(Not Sent)";
		_channels = [[NSMutableArray alloc] init];
		_alternateNicknames = [[NSMutableArray alloc] init];
		
		CFUUIDRef uRef = CFUUIDCreate(NULL);
		CFStringRef uStringRef = CFUUIDCreateString(NULL, uRef);
		CFRelease(uRef);
		[self setUUID:(NSString *)uStringRef];
		CFRelease(uStringRef);
	}
	return self;
}

- (void)dealloc {
	// should make sure we're disconnected here also
#if LOGALL
	NSLog(@"RELEASING NETWORK %@", self);
#endif
	self.uUID = nil;
	self.serverAddress = nil;
	self.serverAddress = nil;
	self.username = nil;
	self.nickname = nil;
	self.realname = nil;
	self.serverPassword = nil;
	self.nickServPassword = nil;
	self.stringDescription = nil;
	[_channels release];
	[_nicknames release];
	[writebuf release];
	[self setOperatorModes:nil];
	[super dealloc];
}

- (BOOL)isEqual:(id)obj {
	return ([[self uUID] isEqualToString:[obj uUID]]);
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; %@;>", NSStringFromClass([self class]), self, [self uUID]];
}

#pragma mark Channel Management

- (RCChannel *)consoleChannel {
	static RCChannel *consoleChannel = nil;
	if (consoleChannel) return consoleChannel;
	RCChannel *channel = [self channelWithChannelName:RCConsoleChannelName];
	if ([channel isKindOfClass:[RCConsoleChannel class]]) {
		consoleChannel = channel;
		return channel;
	}
	return nil;
}

- (RCChannel *)channelWithChannelName:(NSString *)chan {
	return [self channelWithChannelName:chan ifNilCreate:NO];
}

- (RCChannel *)channelWithChannelName:(NSString *)chan ifNilCreate:(BOOL)create {
	__block RCChannel *target = nil;
	[self enumerateOverChannelsWithBlock:^(RCChannel *channel, BOOL *stop) {
		if ([[channel channelName] isEqualToStringNoCase:chan]) {
			target = channel;
			*stop = YES;
		}
	}];
	
	if (!target && create) {
		target = [self addChannel:chan join:NO];
	}
	
	return target;
}

- (RCChannel *)pmChannelWithChannelName:(NSString *)chan {
	return [self channelWithChannelName:chan];
}

- (RCChannel *)addChannel:(NSString *)_chan join:(BOOL)join {
	@synchronized(self) {
		RCChannel *ret = [self channelWithChannelName:_chan ifNilCreate:NO];
		
		if (!ret) {
			RCChannel *chan = nil;
			
			if ([_chan isEqualToString:RCConsoleChannelName])
				chan = [[RCConsoleChannel alloc] initWithChannelName:_chan];
			
			else if ([_chan hasPrefix:@"#"] || [_chan hasPrefix:@"&"])
				chan = [[RCChannel alloc] initWithChannelName:_chan];
			
			else
				chan = [[RCPMChannel alloc] initWithChannelName:_chan];
			
			[chan setNetwork:self];
			NSUInteger index = 0;
			
			if (![chan isKindOfClass:[RCConsoleChannel class]]) {
				index = [_channels count];
			}
			
			@synchronized(_channels) {
				[_channels insertObject:chan atIndex:index];
			}
			
			if (self.channelCreationHandler)
				self.channelCreationHandler(chan);
			
			if (join)
				[chan join];

			[chan release];
			
			return [[chan retain] autorelease];
		}
		else {
			return ret;
		}
	}
}

- (void)createConsoleChannel {
	(void)[self addChannel:RCConsoleChannelName join:YES];
}

- (void)removeChannel:(RCChannel *)chan {
	[self removeChannel:chan withMessage:@"Relay Chat."];
}

- (void)removeChannel:(RCChannel *)chan withMessage:(NSString *)quitter {
	@synchronized(self) {
		if (!chan) return;
		[chan partWithMessage:quitter];
		@synchronized(_channels) {
			[_channels removeObject:chan];
		}
	}
}

- (void)moveChannelAtIndex:(NSUInteger)idx toIndex:(NSUInteger)newIdx; {
	@synchronized(_channels) {
		RCChannel *ctrlChan = [_channels objectAtIndex:idx];
		[ctrlChan retain];
		[_channels removeObjectAtIndex:idx];
		[_channels insertObject:ctrlChan atIndex:newIdx-1];
		[ctrlChan release];
	}
//	[[RCNetworkManager sharedNetworkManager] saveNetworks];
}


- (void)enumerateOverChannelsWithBlock:(void (^)(RCChannel *channel, BOOL *stop))block {
	@synchronized(_channels) {
		for (RCChannel *chan in _channels) {
			BOOL shouldStop = NO;
			block(chan, &shouldStop);
			if (shouldStop) {
				break;
			}
		}
	}
}

#pragma mark Socket Handling

- (BOOL)hasPendingBites {
	if (!writebuf) return NO;
	return [writebuf length] > 0;
}

- (BOOL)read {
	
	if (sockfd == -1) return NO;
	if (reading) return YES;
	
	reading = YES;
	// do this in a thread safe manner
	if (!readCache)
		readCache = [[NSMutableData alloc] init];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	char buf[2049];
	ssize_t rc = 0;
	if (self.useSSL)
		rc = SSL_read(ssl, buf, 2048);
	else
		rc = read(sockfd, buf, 2048);
	if (rc <= 0) {
		[pool drain];
		return NO;
	}
	
	[readCache appendBytes:buf length:rc];
	NSRange rr = [readCache rangeOfData:[NSData nlCharacterDataSet] options:0 range:NSMakeRange(0, [readCache length])];
	while (rr.location != NSNotFound) {
		NSData *data = [readCache subdataWithRange:NSMakeRange(0, rr.location + 2)];
		NSString *recd = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		if (recd) {
			[self _handleMessage:recd];
		}
		else {
			recd = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
			if (!recd) {
				// perhaps mac os roman, seems to work for all.
			}
			[self _handleMessage:recd];
		}
		[recd autorelease];
		[readCache replaceBytesInRange:NSMakeRange(0, rr.location + 2) withBytes:NULL length:0];
		rr = [readCache rangeOfData:[NSData nlCharacterDataSet] options:0 range:NSMakeRange(0, [readCache length])];
	}
	
	[pool release];
	reading = NO;
	return YES;
}

- (BOOL)write {
	
	if (sockfd == -1) return NO;
	if (writing) return NO;
	writing = YES;
	ssize_t written = 0;
	if (self.useSSL) {
		written = SSL_write(ssl, [writebuf UTF8String], (int)strlen([writebuf UTF8String]));
	}
	else {
		written = write(sockfd, [writebuf UTF8String], (ssize_t)strlen([writebuf UTF8String]));
	}
	const char *buf = [writebuf UTF8String];
	buf = buf + written;
	[writebuf release];
	writebuf = [[NSMutableString alloc] initWithCString:buf encoding:NSUTF8StringEncoding];
	// this math works. But there must be a more sensible way.
	writing = NO;
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
	if (self.isRegistered && !!cacheLine) {
		[writebuf appendString:cacheLine];
		[cacheLine release];
		cacheLine = nil;
	}
	if (self.isRegistered || !canWait) {
		[writebuf appendString:msg];
	}
	else {
		cacheLine = [[NSMutableString alloc] init];
		[cacheLine appendString:cacheLine];
	}
	return YES;
}

- (void)_handleMessage:(NSString *)messageString {
	if (!RCIRCStringIsValid(messageString)) return;
	messageString = [messageString substringToIndex:[messageString length] - 2];
#if LOGALL
	NSLog(@"received: [%@]", msg);
#endif
	
	RCMessage *message = [[RCMessage alloc] initWithString:messageString];
	[message parse];
	
	NSString *selName = [NSString stringWithFormat:@"handle%@:", [message numeric]];
	SEL pSEL = NSSelectorFromString(selName);
	if ([self respondsToSelector:pSEL]) ((void (*)(id, SEL, id))objc_msgSend)(self, pSEL, message);
	else {
		// may not be a good idea to create it by default
		// but if it's a privmsg, hm..
		// Albeit PRIVMSG is handled separately, and can handle this properly..
		// Will consult with expr
		RCChannel *channel = [self channelWithChannelName:[message destination] ifNilCreate:YES];
		[channel receivedMessage:message];
	}
	[message release];
}

#pragma mark Connection State Management

- (void)connect {
	[disconnectTimer invalidate];
	disconnectTimer = nil;
	if (status == RCSocketStatusConnected || status == RCSocketStatusConnecting) return;
	status = RCSocketStatusConnecting;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	writebuf = [[NSMutableString alloc] init];
	_registered = NO;
	
	sockfd = [self _connectSocket];
	if (sockfd < 0) {
		[pool drain];
		return;
	}
	
	if (!socketQueue)
		socketQueue = dispatch_queue_create([self.uUID UTF8String], 0);
	
	readSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, sockfd, 0, socketQueue);
	
	dispatch_source_set_event_handler(readSource, ^ {
		[self read];
		// create write source and resume/suspend depending if there's data
		// if always in write monitoring, CPU is spiked 10000%
		// abusing the fact that modern systes have indespensible resources
		if ([self hasPendingBites])
			[self write];
	});
	
	dispatch_resume(readSource);
	
	[self sendMessage:@"CAP LS" canWait:NO];
	if ([self.serverPassword length] > 0) {
		[self sendMessage:[@"PASS " stringByAppendingString:self.serverPassword] canWait:NO];
	}
	if (!self.nickname || [self.nickname isEqualToString:@""]) {
		[self setNickname:@"RelayUser"];
	}
	[self sendMessage:[@"USER " stringByAppendingFormat:@"%@ %@ %@ :%@", (self.username ?: self.nickname), self.nickname, self.nickname, (self.realname ?: self.nickname)] canWait:NO];
	[self sendMessage:[@"NICK " stringByAppendingString:self.nickname] canWait:NO];
	[pool drain];
}

- (int)_connectSocket {
	struct hostent *host;
	struct sockaddr_in addr;
	if ((host = gethostbyname([self.serverAddress UTF8String])) == NULL) {
		[self.delegate network:self connectionFailed:RCConnectionFailureObtainingHost];
		// ERROR OBTAINING HOST
		return -1;
	}
	int _sockfd = socket(AF_INET, SOCK_STREAM, 0);
	if (_sockfd < 0) {
		[self.delegate network:self connectionFailed:RCConnectionFailureEstablishingSocket];
		// ERROR ESTABLISHING SOCKET(?)
		return -1;
	}
	int set = 1;
	setsockopt(_sockfd, SOL_SOCKET, SO_NOSIGPIPE, (void *)&set, sizeof(int));
	bzero(&addr, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(self.port);
	addr.sin_addr.s_addr = *(in_addr_t *)(host->h_addr);
	if (connect(_sockfd, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
		[self.delegate network:self connectionFailed:RCConnectionFailureConnecting];
		// ERROR CONNECTING
		return -1;
	}
	if (self.useSSL) {
		SSL_library_init();
		SSL_CTX *rCTX = RCInitContext();
		ctx = rCTX;
		ssl = SSL_new(ctx);
		SSL_set_fd(ssl, _sockfd);
		if (SSL_connect(ssl) == -1) {
			// ERROR CONNECTING (VIA SSL?)
			[self.delegate network:self connectionFailed:RCConnectionFailureConnectingViaSSL];
			return -1;
		}
	}
	
	int flags = fcntl(_sockfd, F_GETFL, 0);
	fcntl(_sockfd, F_SETFL, flags | O_NONBLOCK);
	
	return _sockfd;
}

- (BOOL)isTryingToConnectOrConnected {
	return ([self isConnected] || status == RCSocketStatusConnecting);
}

- (NSString *)defaultQuitMessage {
	NSString *ret = nil;
	if ([self.delegate respondsToSelector:@selector(defaultQuitMessageForNetwork:)]) {
		ret = [self.delegate defaultQuitMessageForNetwork:self];
	}
	return ret ?: @"Ciao!";
}

- (BOOL)disconnectWithMessage:(NSString *)msg {
	if (status == RCSocketStatusConnecting) {
		status = RCSocketStatusClosed;
		close(sockfd);
		sockfd = -1;
		[writebuf release];
		writebuf = nil;
		if (self.useSSL)
			SSL_CTX_free(ctx);
		_registered = NO;
		[self enumerateOverChannelsWithBlock:^(RCChannel *channel, BOOL *stop) {
			[channel disconnected:msg];
		}];
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
	// put lock around status and stuff
	if (status == RCSocketStatusClosed) return;
	
	status = RCSocketStatusClosed;
	
	dispatch_release(readSource);
	readSource = nil;
	readCache = nil;
	
	close(sockfd);
	sockfd = -1;
	[writebuf release];
	writebuf = nil;
	self.away = NO;
	if (self.useSSL)
		SSL_CTX_free(ctx);
	_registered = NO;
	[[self consoleChannel] disconnected:msg];
	[self enumerateOverChannelsWithBlock:^(RCChannel *channel, BOOL *stop) {
		if (![channel isKindOfClass:[RCConsoleChannel class]])
			[channel disconnected:@"Disconnected."];
	}];
}

- (BOOL)disconnect {
	return [self disconnectWithMessage:[self defaultQuitMessage]];
}

- (BOOL)isConnected {
	return (status == RCSocketStatusConnected);
}

#pragma mark IRC Protocol

- (void)sendB64SASLAuth {
	NSString *b64 = [[NSString stringWithFormat:@"%@%C%@%C%@", self.nickname, (unsigned short)0x00, self.nickname, (unsigned short)0x00, self.nickServPassword] base64];
	[self sendMessage:[NSString stringWithFormat:@"AUTHENTICATE %@", b64] canWait:NO];
}

- (void)handle001:(RCMessage *)message {
	// RPL_WELCOME
	// :Welcome to the Internet Relay Network <nick>!<user>@<host>
	status = RCSocketStatusConnected;
	
	[self.delegate networkConnected:self];
	
	_registered = YES;
//	RCChannel *chan = [self consoleChannel];
//	if (chan) [chan receivedMessage:@"Connected to host." from:@"" time:nil type:RCMessageTypeNormal];
	if (_saslWasSuccessful)
		if ([self.nickServPassword length] > 0)
			[self sendMessage:[@"PRIVMSG NickServ :IDENTIFY " stringByAppendingString:self.nickServPassword]];
	
	// framework implementor should join all channels at this point
//	NSMutableString *joinList = [[NSMutableString alloc] initWithString:@"JOIN "];
//	if ([_channels count] > 1) {
//		for (RCChannel *chan in _channels) {
//			if (![chan isKindOfClass:[RCConsoleChannel class]] && ![chan isKindOfClass:[RCPMChannel class]]) {
//				if ([chan joinOnConnect]) {
//					[joinList appendFormat:@"%@,", chan];
//				}
//			}
//		}
//		if ([joinList hasSuffix:@","]) {
//			[joinList deleteCharactersInRange:NSMakeRange([joinList length]-1, 1)];
//		}
//		[self sendMessage:joinList];
//	}
//	[joinList release];
//	[chan receivedMessage:message from:@"" time:nil type:RCMessageTypeNormal];
//	reloadNetworks();
}

// 002 RPL_YOURHOST
// 003 RPL_CREATED
// 004 RPL_MYINFO
// 328 RPL_CHANNEL_URL
// 331 RPL_NOTOPIC
// 332 RPL_TOPIC
// 366 RPL_ENDOFNAMES
// 396 RPL_HOSTHIDDEN
// 404 ERR_CANNOTSENDTOCHAN
// 473 ERR_INVITEONLYCHAN
// 474 ERR_BANNEDFROMCHANNEL
// 475 ERR_BANNEDFROMCHANNNEL
// 482 ERR_BANNEDFROMCHANNEL

- (void)handle005:(RCMessage *)message {
	// RPL_ISUPPORT
	@synchronized(self) {
		NSString *capsString = [message.message substringFromIndex:[message.message rangeOfString:@" "].location + 1];
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
					NSString *rPrefixes = [split objectAtIndex:1];
					NSMutableDictionary *prefixDict = [[NSMutableDictionary alloc] init];
					for (int i = 0; i < [modes length]; i++) {
						NSString *thePrefix = [rPrefixes substringWithRange:NSMakeRange(i, 1)];
						NSString *theMode = [modes substringWithRange:NSMakeRange(i, 1)];
						[prefixDict setObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:i], thePrefix, nil] forKey:theMode];
					}
					self.operatorModes = [[prefixDict copy] autorelease];
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
		[[self consoleChannel] receivedMessage:message from:@"" time:nil type:RCMessageTypeNormal];
#endif
	}
}

- (void)handle010:(RCMessage *)message {
	// RPL_BOUNCE
//	NSString *redirServer = [message parameterAtIndex:1];
//	NSString *redirPort = [message parameterAtIndex:2];
//	NSString *alertString = nil;
//	if ([redirPort integerValue] != 0) {
//		if ([self port] == [redirPort integerValue]) {
//			alertString = [NSString stringWithFormat:@"Server %@ (%@) is redirecting to %@.\nChange server?", [self _description], self.serverAddress, redirServer];
//		}
//		else {
//			alertString = [NSString stringWithFormat:@"Server %@ (%@) is redirecting to %@ on port %@.\nChange server?", [self _description], self.serverAddress, redirServer, redirPort];
//		}
////		RCServerChangeAlertView *ac = [[RCServerChangeAlertView alloc] initWithTitle:nil message:alertString delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Change", nil];
////		[ac setServer:redirServer];
////		[ac setPort:[redirPort intValue]];
////		[ac setTag:RCALERR_SERVCHNGE];
////		dispatch_async(dispatch_get_main_queue(), ^ {
////			[ac show];
////			[ac release];
////		});
//	}
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
	self.away = NO;
}

- (void)handle306:(RCMessage *)message {
	// RPL_NOWAWAY
	self.away = YES;
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
//        [[[RCChatController sharedController] currentChannel] receivedMessage:final from:@"-" time:nil type:RCMessageTypeEvent];
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
////        - (void)receivedMessage:(NSString *)message from:(NSString *)from time:(NSString *)time type:(RCMessageType)type
//        [[[RCChatController sharedController] currentChannel] receivedMessage:connInfo from:@"" time:nil type:RCMessageTypeEvent];
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
//	RCPMChannel *channel = (RCPMChannel *)[self pmChannelWithChannelName:[message parameterAtIndex:1]];
//	[channel receivedWHOISInformation];
	// RPL_ENDOFWHOIS
}

- (void)handle319:(RCMessage *)message {
	// RPL_WHOISCHANNELS
	NSString *whoisChannels = [message parameterAtIndex:2];
//	if (channel) {
		NSArray *chans = [whoisChannels componentsSeparatedByString:@" "];
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
//        [[[RCChatController sharedController] currentChannel] receivedMessage:str from:@"" time:nil type:RCMessageTypeEvent];
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
//	[listCallback setUpdating:YES];
	// RPL_LISTSTART
}

- (void)handle322:(RCMessage *)message {
//	// RPL_LIST
//	if (!listCallback) return;
//	NSString *chan = [message parameterAtIndex:1];
//	//:irc.saurik.com 322 iPhone *
//	if ([chan isEqualToString:@"*"]) return;
//	NSString *count = [message parameterAtIndex:2];
//	NSString *topicModes = [message parameterAtIndex:3];
//	chan = [chan stringByReplacingOccurrencesOfString:@" " withString:@""];
//	count = [count stringByReplacingOccurrencesOfString:@" " withString:@""];
//	if ([topicModes isEqualToString:@" "]) topicModes = nil;
//	if ([topicModes hasPrefix:@" "]) topicModes = [topicModes recursivelyRemovePrefix:@" "];
//	[listCallback receivedChannel:chan withCount:[count intValue] andTopic:topicModes];
	// :irc.saurik.com 322 mx_ #testing 1 :[+nt]
	// :hitchcock.freenode.net 322 mxms_ #testchannelpleaseignore 3 :http://i.imgur.com/LbPvWUV.jpg
}

- (void)handle323:(RCMessage *)message {
	// RPL_LISTEND
//	[listCallback setUpdating:NO];
//	listCallback = nil;
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
	[[self channelWithChannelName:channel] receivedMessage:[NSString stringWithFormat:@"Set by %c%@%c on %@", RCIRCAttributeBold, setter, RCIRCAttributeBold, time] from:@"" time:nil type:RCMessageTypeNormal];
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

- (void)handle372:(RCMessage *)message {
	// RPL_MOTD
//	NSString *val = [[RCNetworkManager sharedNetworkManager] valueForSetting:SHOW_MOTD_KEY];
//	if (val) {
//		if ([val boolValue]) {
//			NSString *line = [message parameterAtIndex:1];
//			RCChannel *chan = [self consoleChannel];
//			[chan receivedMessage:line from:@"" time:nil type:RCMessageTypeNormal];
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
//			[chan receivedMessage:string from:@"" time:nil type:RCMessageTypeNormal];
//		}
//	}
}

- (void)handle376:(RCMessage *)message {
	// :irc.saurik.com 376 _m :End of message of the day.
}

- (void)handle381:(RCMessage *)message {
	_networkOperator = YES;
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

- (void)handle421:(RCMessage *)message {
	// ERR_UNKNOWNCOMMAND
	NSString *command = [message parameterAtIndex:1];
	NSString *reason = [message parameterAtIndex:2];
	NSString *string = [NSString stringWithFormat:@"Error(421): %@ %@", command, reason];
	if ([command isEqualToString:@"CAP"]) {
		// uh
	}
//	[[[RCChatController sharedController] currentChannel] receivedMessage:string from:@"" time:nil type:RCMessageTypeError];
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
	self.nickname = [self.nickname stringByAppendingString:@"_"];
	[self sendMessage:[@"NICK " stringByAppendingString:self.nickname] canWait:NO];
}

- (void)handle437:(RCMessage *)message {
//	[[self consoleChannel] receivedMessage:[message parameterAtIndex:2] from:nil time:nil type:RCMessageTypeNormal];
//	dispatch_async(dispatch_get_main_queue(), ^{
//		RCPrettyAlertView *ac = [[RCPrettyAlertView alloc] initWithTitle:@"Nickname Unavailable" message:[NSString stringWithFormat:@"Please input another nickname for %@ below.", [self _description]] delegate:self cancelButtonTitle:@"Disconnect" otherButtonTitles:@"Retry", nil];
//		[ac setTag:RCALERR_INCUNAME];
//		[ac setAlertViewStyle:UIAlertViewStylePlainTextInput];
//		[ac show];
//		[ac release];
//	});
}

- (void)handle461:(RCMessage *)message {
	// this is broken
	// type /nick for example.
	// wether you hit change or cancel, it disconnects you
	// its stupid.
//	if (isRegistered) {
//		dispatch_async(dispatch_get_main_queue(), ^{
//			RCPrettyAlertView *ac = [[RCPrettyAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Invalid Username (%@)", [self _description]] message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Change", nil];
//			[ac setTag:RCALERR_INCUNAME];
//			[ac setAlertViewStyle:UIAlertViewStylePlainTextInput];
//			[ac show];
//			[ac release];
//		});
//	}
}

- (void)handle464:(RCMessage *)message {
//	dispatch_async(dispatch_get_main_queue(), ^{
//		RCPrettyAlertView *ac = [[RCPrettyAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Invalid Server Password (%@)", [self _description]] message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Change", nil];
//		[ac setTag:RCALERR_INCSPASS];
//		[ac setAlertViewStyle:UIAlertViewStyleSecureTextInput];
//		[ac show];
//		[ac release];
//	});
}

- (void)handle900:(RCMessage *)message {
	_saslWasSuccessful = YES;
	[[self consoleChannel] receivedMessage:@"SASL Authenticate was successful" from:nil time:nil type:RCMessageTypeNormal];
}

- (void)handle903:(RCMessage *)message {
	[self sendMessage:@"CAP END" canWait:NO];
}

- (void)handle904:(RCMessage *)message {
	[self sendMessage:@"CAP END" canWait:NO];
	[[self consoleChannel] receivedMessage:@"SASL Authentication failed." from:nil time:nil type:RCMessageTypeNormal];
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
		if ([capabilities containsObject:@"sasl"] && ([self.nickServPassword length] > 0)) {
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
		extra = ary[(arc4random_uniform((uint32_t)[ary count]))];
	}
	else
		NSLog(@"WTF?!?!! %@", command);
	[self sendMessage:[@"NOTICE " stringByAppendingFormat:@"%@ :\x01%@ %@\x01", from, command, extra]];
}

- (void)handleERROR:(RCMessage *)message {
	NSLog(@"ERROR ENCOUNTERED. %@", message);
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
	if ([from isEqualToString:self.nickname]) {
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
	NSRange rangeOfTime = [message.message rangeOfString:@"\x12\x13"];
	if (rangeOfTime.location != NSNotFound) {
		NSString *time = [message.message substringFromIndex:rangeOfTime.location];
		[targetChannel receivedMessage:(NSString *)kickInfo from:from time:time type:RCMessageTypeKick];
	}
	else {
		[targetChannel receivedMessage:(NSString *)kickInfo from:from time:nil type:RCMessageTypeKick];
	}
	if ([[message parameterAtIndex:1] isEqualToString:self.nickname]) {
		[targetChannel setJoined:NO];
		// check boolean
		// setup auto-rejoin timer
	}
}

- (void)handleMODE:(RCMessage *)message {
	RCChannel *targetChannel = [self channelWithChannelName:[message parameterAtIndex:0]];
	NSString *from = nil;
	RCParseUserMask(message.sender, &from, nil, nil);
	NSString *testMethod = [message.message stringByReplacingOccurrencesOfString:@" " withString:@""];
	if ([message.message length] - [testMethod length] <= 1) return;
	[targetChannel receivedMessage:[NSString stringWithFormat:@"%@ %@", [message parameterAtIndex:1], [message parameterAtIndex:2]] from:from time:nil type:RCMessageTypeMode];
	if ([message.message length] - [testMethod length] > 1) {
		[targetChannel setMode:[message parameterAtIndex:1] forUser:[message parameterAtIndex:2]];
	}
	// only tested with banning people. ;P not channel modes, etc
	// Relay[2626:f803] MSG: :ac3xx!ac3xx@rox-103C7229.ac3xx.com MODE #chat +o _m
}

- (void)handleNICK:(RCMessage *)message {
	NSString *person = nil;
	NSString *newNick = [message parameterAtIndex:0];
	RCParseUserMask(message.sender, &person, nil, nil);
	if ([person isEqualToString:self.nickname]) {
		self.nickname = newNick;
	}
	[self enumerateOverChannelsWithBlock:^(RCChannel *chan, BOOL *stop) {
		if ([chan isUserInChannel:person])
			[chan changeNickForUser:person toNick:newNick];
	}];
}

- (void)handleNOTICE:(RCMessage *)message {
	if (!self.isRegistered) return;
	NSString *from = nil;
	RCParseUserMask(message.sender, &from, nil, nil);
	
	[self.delegate network:self receivedNotice:[message parameterAtIndex:1] user:from];
	
//	if ([[[[RCChatController sharedController] currentChannel] delegate] isEqual:self]) {
//		[[[RCChatController sharedController] currentChannel] receivedMessage:[message parameterAtIndex:1] from:from time:nil type:RCMessageTypeNotice];
//	}
//	else {
//		[[self consoleChannel] receivedMessage:[message parameterAtIndex:1] from:from time:nil type:RCMessageTypeNotice];
//	}
}

- (void)handlePART:(RCMessage *)message {
	NSString *from = message.sender;
	RCParseUserMask(from, &from, nil, nil);
	RCChannel *channel = [self channelWithChannelName:[message parameterAtIndex:0]];
	if ([self.nickname isEqualToString:from]) {
		[channel setSuccessfullyJoined:NO];
	}
	if (![[message parameterAtIndex:0] isEqualToString:message.message])
		[channel receivedMessage:[message parameterAtIndex:1] from:from time:nil type:RCMessageTypePart];
	else [channel receivedMessage:@"" from:from time:nil type:RCMessageTypePart];
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
	NSString *fullMessage = [message message];
	RCMessageType typ = RCMessageTypeNormal;
	NSString *userMessage = nil;
	NSString *from = nil;
	NSString *target = [message destination];
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
//	RCChannel *channel = [self channelWithChannelName:target ifNilCreate:YES];
//	[channel receivedMessage:userMessage from:from time:nil type:typ];
}

- (void)handleQUIT:(RCMessage *)message {
	NSString *from = message.sender;
	RCParseUserMask(from, &from, nil, nil);
	[self enumerateOverChannelsWithBlock:^(RCChannel *chan, BOOL *stop) {
		[chan receivedMessage:message.message from:from time:nil type:RCMessageTypeQuit];
	}];
}

- (void)handleTOPIC:(RCMessage *)message {
	// RPL_SOMETHINGTOPICRELATED
	NSString *from = nil;
	RCParseUserMask(message.sender, &from, nil, nil);
	[[self channelWithChannelName:[message parameterAtIndex:0]] receivedMessage:[message parameterAtIndex:1] from:from time:nil type:RCMessageTypeTopic];
	// :Maximus!~textual@108.132.139.52 TOPIC #k_ :hi
}

@end
