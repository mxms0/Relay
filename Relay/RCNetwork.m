//
//  RCNetwork.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCNetwork.h"
#import "RCNetworkManager.h"
#import "TestFlight.h"

@implementation RCNetwork

@synthesize sDescription, server, nick, username, realname, spass, npass, port, isRegistered, useSSL, COL, channels, _channels, index, useNick, userModes;

- (id)init {
	if ((self = [super init])) {
		status = RCSocketStatusNotOpen;
		shouldSave = NO;
		_scores = 0;
		isRegistered = NO;
		canSend = YES;
		channels = [[NSMutableArray alloc] init];
		_channels = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (id)infoDictionary {
	return [NSDictionary dictionaryWithObjectsAndKeys:
			username, USER_KEY,
			nick, NICK_KEY,
			realname, NAME_KEY,
			spass, S_PASS_KEY,
			npass, N_PASS_KEY,
			sDescription, DESCRIPTION_KEY,
			server, SERVR_ADDR_KEY,
			[NSNumber numberWithInt:port], PORT_KEY,
			[NSNumber numberWithBool:useSSL], SSL_KEY,
			channels, CHANNELS_KEY,
			[NSNumber numberWithBool:COL], COL_KEY,
			nil];
}

- (void)dealloc {
	NSLog(@"cya.");
	[channels release];
	[_channels release];
	[server release];
	[nick release];
	[username release];
	[realname release];
	[spass release];
	[npass release];
	[sDescription release];
	[super dealloc];
}

- (NSString *)_description {
	if (!sDescription) {
		return server;
	}
	return sDescription;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; %@; Index = %d;>", NSStringFromClass([self class]), self, [self infoDictionary], index];
}

- (NSString *)descriptionForComparing {
	return [NSString stringWithFormat:@"%@%@%@%@%d%d", username, nick, realname, server, port, useSSL];
}

- (void)setupRooms:(NSArray *)rooms {
	[rooms retain];
	for (NSString *_chan in rooms) {
		[self addChannel:_chan join:NO];
	}
	[rooms release];
}
- (void)addChannel:(NSString *)_chan join:(BOOL)join {
	if (![[_channels allKeys] containsObject:_chan]) {
		RCChannel *chan;
		if ([_chan isEqualToString:@"IRC"]) chan = [[RCConsoleChannel alloc] initWithChannelName:_chan];
		else if ([_chan hasPrefix:@"#"]) chan = [[RCChannel alloc] initWithChannelName:_chan];
		else chan = [[RCPMChannel alloc] initWithChannelName:_chan];
		[chan setDelegate:self];
		[[self _channels] setObject:chan forKey:_chan];
		[chan release];
		if (![[self channels] containsObject:_chan])
			[[self channels] addObject:_chan];
		if (join) [chan setJoined:YES withArgument:nil];
		if (isRegistered) {
			[[RCNavigator sharedNavigator] addRoom:_chan toServerAtIndex:index];
			[[RCNetworkManager sharedNetworkManager] saveNetworks];
			shouldSave = YES; // if we aren't registered.. it's _likely_ just setup.
		}
	}
	else return;
}

- (void)removeChannel:(RCChannel *)chan {
	[chan setJoined:NO withArgument:@"Relay Chat."];
	[channels removeObject:[chan channelName]];
	[_channels removeObjectForKey:[chan channelName]];
	[[RCNavigator sharedNavigator] removeChannel:chan toServerAtIndex:index];
	[[RCNetworkManager sharedNetworkManager] saveNetworks];
}

#pragma mark - SOCKET STUFF

- (BOOL)connect {
	if (status == RCSocketStatusConnecting) return NO;
	if (status == RCSocketStatusConnected) return NO;
	useNick = nick;
	self.userModes = @"~&@%+";
	RCChannel *chan = [_channels objectForKey:@"IRC"];
	if (chan) [chan recievedMessage:[NSString stringWithFormat:@"Connecting to %@ on port %d", server, port] from:@"" type:RCMessageTypeNormal];
	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_4_0) {
		task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
			[[UIApplication sharedApplication] endBackgroundTask:task];
			task = UIBackgroundTaskInvalid;
		}];
	}

	CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)server, port ? port : 6667, (CFReadStreamRef *)&iStream, (CFWriteStreamRef *)&oStream);
	[iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[iStream setDelegate:self];
	[oStream setDelegate:self];
	if ([iStream streamStatus] == NSStreamStatusNotOpen) [iStream open];
	if ([oStream streamStatus] == NSStreamStatusNotOpen) [oStream open];
	_thread = [NSThread currentThread];
	if (useSSL) {
		[iStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
		[oStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
		NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], kCFStreamSSLAllowsExpiredCertificates,
								  [NSNumber numberWithBool:YES], kCFStreamSSLAllowsAnyRoot, [NSNumber numberWithBool:NO], 
								  kCFStreamSSLValidatesCertificateChain, kCFNull, kCFStreamSSLPeerName, nil];
		CFReadStreamSetProperty((CFReadStreamRef)iStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
		CFWriteStreamSetProperty((CFWriteStreamRef)oStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
		[settings release];
	}
	status = RCSocketStatusConnecting;
	if ([spass length] > 0) {
		[self sendMessage:[@"PASS " stringByAppendingString:spass] canWait:NO];
	}
	[self sendMessage:[@"USER " stringByAppendingFormat:@"%@ %@ %@ :%@", (username ? username : nick), nick, nick, (realname ? realname : nick)] canWait:NO];
	[self sendMessage:[@"NICK " stringByAppendingString:nick] canWait:NO];
	return YES;
}
static NSMutableString *data = nil;
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {

	switch (eventCode) {
		case NSStreamEventEndEncountered: // 16 - Called on ping timeout/closing link
			status = RCSocketStatusClosed;
			[self disconnect];
			return;
		case NSStreamEventErrorOccurred: /// 8 - Unknowns/bad interwebz
			[self disconnect];
			status = RCSocketStatusError;
			return;
		case NSStreamEventHasBytesAvailable: // 2
			if (!data) data = [[NSMutableString alloc] init];
			while ([(NSInputStream *)aStream hasBytesAvailable]) {
				uint8_t buffer[512];
				NSUInteger bytesRead = [iStream read:buffer maxLength:512];
				if (bytesRead) {
					NSString *message = [[NSString alloc] initWithBytesNoCopy:buffer length:bytesRead encoding:NSUTF8StringEncoding freeWhenDone:NO];
					if (message) {
						[data appendString:message];
						[message release];
					}
				}			
			}
			while ([data rangeOfString:@"\r\n"].location != NSNotFound) {
				NSString *send = [[NSString alloc] initWithString:[data substringWithRange:NSMakeRange(0, [data rangeOfString:@"\r\n"].location+2)]];
				[self recievedMessage:send];
				[send release];
				send = nil;
				[data deleteCharactersInRange:NSMakeRange(0, [data rangeOfString:@"\r\n"].location+2)];	
			}
			return;
		case NSStreamEventHasSpaceAvailable: // 4
			if (status == RCSocketStatusConnecting) status = RCSocketStatusConnected;
			if (sendQueue) {
				canSend = NO;
				[oStream write:(uint8_t *)[sendQueue UTF8String] maxLength:[sendQueue length]];
				[oStream write:(uint8_t *)"\r\n" maxLength:2];
				[sendQueue release];
				sendQueue = nil;
			}
			canSend = YES;
			return;
		case NSStreamEventNone:
			return;
		case NSStreamEventOpenCompleted: // 1
			status = RCSocketStatusConnected;
			return;
	}
}

- (BOOL)sendMessage:(NSString *)msg {
	return [self sendMessage:msg canWait:YES];
}

- (BOOL)sendMessage:(NSString *)msg canWait:(BOOL)canWait {	

	if ((!canWait) || isRegistered) {
		NSData *messageData = [[msg stringByAppendingString:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding];
		if (canSend) {
			if ([oStream write:[messageData bytes] maxLength:[messageData length]] != -1) {
					return YES;
			}
			else {
				NSLog(@"BLASPHEMYY");
			}
			[self errorOccured:[oStream streamError]];
		}
	}
	NSLog(@"Adding to queue... %@",msg);
	if (!sendQueue) sendQueue = [[NSMutableString alloc] init];
	[sendQueue appendFormat:@"%@\r\n", msg];
	return NO;
}

- (void)errorOccured:(NSError *)error {
	NSLog(@"Error: %@", [error localizedDescription]);
//	[TestFlight submitFeedback:[error localizedDescription]];
}

- (void)recievedMessage:(NSString *)msg {

	if ([msg isEqualToString:@""] || msg == nil || [msg isEqualToString:@"\r\n"]) return;
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	if ([msg hasPrefix:@"PING"]) {
		[self handlePING:msg];
		[p drain];
		return;
	}
	else if ([msg hasPrefix:@"ERROR"]) {
		//handle..
		NSLog(@"Errorz. %@:%@", msg, server);
		NSString *error = [msg substringWithRange:NSMakeRange(5, [msg length]-5)];
		if ([error hasPrefix:@" :"]) error = [error substringFromIndex:2];
		RCChannel *chan = [_channels objectForKey:@"IRC"];
		[chan recievedMessage:error from:@"" type:RCMessageTypeNormal];
		[p drain];
		return;
	}
	if (![msg hasPrefix:@":"]) {
		[p drain];
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
		NSLog(@"PLZ IMPLEMENT %s %@", (char *)pSEL, msg);
		NSLog(@"Meh. %@\r\n%@", cmd, rest);	
	}
	[scanner release];
	[p drain];
	/*{
	"░░░░░▄▄▄▄▀▀▀▀▀▀▀▀▄▄▄▄▄▄░░░░░░░\
	░░░░░█░░░░▒▒▒▒▒▒▒▒▒▒▒▒░░▀▀▄░░░░\
	░░░░█░░░▒▒▒▒▒▒░░░░░░░░▒▒▒░░█░░░\
	░░░█░░░░░░▄██▀▄▄░░░░░▄▄▄░░░░█░░\
	░▄▀▒▄▄▄▒░█▀▀▀▀▄▄█░░░██▄▄█░░░░█░\
	█░▒█▒▄░▀▄▄▄▀░░░░░░░░█░░░▒▒▒▒▒░█\
	█░▒█░█▀▄▄░░░░░█▀░░░░▀▄░░▄▀▀▀▄▒█\
	░█░▀▄░█▄░█▀▄▄░▀░▀▀░▄▄▀░░░░█░░█░\
	░░█░░░▀▄▀█▄▄░█▀▀▀▄▄▄▄▀▀█▀██░█░░\
	░░░█░░░░██░░▀█▄▄▄█▄▄█▄████░█░░░\
	░░░░█░░░░▀▀▄░█░░░█░█▀██████░█░░\
	░░░░░▀▄░░░░░▀▀▄▄▄█▄█▄█▄█▄▀░░█░░\
	░░░░░░░▀▄▄░▒▒▒▒░░░░░░░░░░▒░░░█░\
	░░░░░░░░░░▀▀▄▄░▒▒▒▒▒▒▒▒▒▒░░░░█░\
	░░░░░░░░░░░░░░▀▄▄▄▄▄░░░░░░░░█░░";
	};*/
}

- (BOOL)disconnect {
	if ((status == RCSocketStatusConnected) || (status == RCSocketStatusConnecting)) {
		[self sendMessage:@"QUIT :Relay 1.0"];
		[[_channels objectForKey:@"IRC"] recievedMessage:@"Disconnected." from:@"" type:RCMessageTypeNormal];
	}	
	if (!(status == RCSocketStatusClosed) && !(status == RCSocketStatusNotOpen)) {
		status = RCSocketStatusClosed;
		[[UIApplication sharedApplication] endBackgroundTask:task];
		task = UIBackgroundTaskInvalid;
		[oStream close];
		[iStream close];
		[oStream release];
		[iStream release];
		oStream = nil;
		iStream = nil;
		NSLog(@"Disconnected.");
	}
	return YES;
}

- (void)networkDidRegister:(BOOL)reg {
	// do jOC (join on connect) rooms
	isRegistered = YES;
	RCChannel *chan = [_channels objectForKey:@"IRC"];
	if (chan) [chan recievedMessage:@"Connected to host." from:@"" type:RCMessageTypeNormal];
	for (NSString *chan in channels) {
		if ([[_channels objectForKey:chan] joinOnConnect]) [[_channels objectForKey:chan] setJoined:YES withArgument:nil];
	}
}

- (BOOL)isConnected {
	return (status == RCSocketStatusConnected);
}

- (NSString *)connectionStatus {
	switch (status) {
		case RCSocketStatusClosed:
			return @"Disconnected";
		case RCSocketStatusError:
			return @"Error Occurred";
		case RCSocketStatusNotOpen:
			return @"Disconnected";
		case RCSocketStatusConnected:
			return @"Connected";
		case RCSocketStatusConnecting:
			return @"Connceting..";
	}
	return @"HAXXXXX";
}

#pragma mark - COMMANDS

- (void)handle001:(NSString *)welcome {
	[self networkDidRegister:YES];
	
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	NSScanner *scanner = [[NSScanner alloc] initWithString:welcome];
	NSString *crap;
	@try {
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner setScanLocation:[scanner scanLocation]+1];
		[scanner scanUpToString:@"\r\n" intoString:&crap];
	}
	@catch (NSException *exception) {
		NSLog(@"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF %s", (char *)_cmd);
	}
	if ([crap hasPrefix:@":"]) crap = [crap substringFromIndex:1];
	RCChannel *chan = [_channels objectForKey:@"IRC"];
	if (chan) [chan recievedMessage:crap from:@"" type:RCMessageTypeNormal];
	[scanner release];
	[p drain];
}


- (void)handle002:(NSString *)infos {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	NSScanner *scanner = [[NSScanner alloc] initWithString:infos];
	NSString *crap;
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner setScanLocation:[scanner scanLocation]+1];
	[scanner scanUpToString:@"\r\n" intoString:&crap];
	if ([crap hasPrefix:@":"]) crap = [crap substringFromIndex:1];
	RCChannel *chan = [_channels objectForKey:@"IRC"];
	if (chan) [chan recievedMessage:crap from:@"" type:RCMessageTypeNormal];
	[scanner release];
	[p drain];
	// Relay[2626:f803] MSG: :fr.ac3xx.com 002 _m :Your host is fr.ac3xx.com, running version Unreal3.2.9
}

- (void)handle003:(NSString *)servInfos {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	NSScanner *scanner = [[NSScanner alloc] initWithString:servInfos];
	NSString *crap;
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner setScanLocation:[scanner scanLocation]+1];
	[scanner scanUpToString:@"\r\n" intoString:&crap];

	if ([crap hasPrefix:@":"]) crap = [crap substringFromIndex:1];
	RCChannel *chan = [_channels objectForKey:@"IRC"];
	if (chan) [chan recievedMessage:crap from:@"" type:RCMessageTypeNormal];
	[scanner release];
	[p drain];
	// Relay[2626:f803] MSG: :fr.ac3xx.com 003 _m :This server was created Fri Dec 23 2011 at 01:21:01 CET
}

- (void)handle004:(NSString *)othrInfo {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	NSScanner *scanner = [[NSScanner alloc] initWithString:othrInfo];
	NSString *crap;
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner setScanLocation:[scanner scanLocation]+1];
	[scanner scanUpToString:@"\r\n" intoString:&crap];
	if ([crap hasPrefix:@":"]) crap = [crap substringFromIndex:1];
	RCChannel *chan = [_channels objectForKey:@"IRC"];
	if (chan) [chan recievedMessage:crap from:@"" type:RCMessageTypeNormal];
	[scanner release];
	[p drain];
	// Relay[2626:f803] MSG: :fr.ac3xx.com 004 _m fr.ac3xx.com Unreal3.2.9 iowghraAsORTVSxNCWqBzvdHtGp 
}

- (void)handle005:(NSString *)useInfo {
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
	[scanr release];
	// Relay[2794:f803] MSG: :fr.ac3xx.com 005 _m WALLCHOPS WATCH=128 WATCHOPTS=A SILENCE=15 MODES=12 CHANTYPES=# PREFIX=(qaohv)~&@%+ CHANMODES=beI,kfL,lj,psmntirRcOAQKVCuzNSMTGZ NETWORK=ROXnet CASEMAPPING=ascii EXTBAN=~,qjncrR ELIST=MNUCT STATUSMSG=~&@%+ :are supported by this server
}

- (void)handle251:(NSString *)infos {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	NSScanner *scanner = [[NSScanner alloc] initWithString:infos];
	NSString *crap;
	@try {
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner setScanLocation:[scanner scanLocation]+1];
		[scanner scanUpToString:@"\r\n" intoString:&crap];
	}
	@catch (NSException *exception) {
		NSLog(@"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF %s", (char *)_cmd);
	}
	if ([crap hasPrefix:@":"]) crap = [crap substringFromIndex:1];
	RCChannel *chan = [_channels objectForKey:@"IRC"];
	if (chan) [chan recievedMessage:crap from:@"" type:RCMessageTypeNormal];
	[scanner release];
	[p drain];
	// Relay[3067:f803] MSG: :fr.ac3xx.com 251 _m :There are 1 users and 4 invisible on 1 servers
}

- (void)handle252:(NSString *)opsOnline {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	NSScanner *scanner = [[NSScanner alloc] initWithString:opsOnline];
	NSString *crap;
	@try {
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner setScanLocation:[scanner scanLocation]+1];
		[scanner scanUpToString:@"\r\n" intoString:&crap];
	}
	@catch (NSException *exception) {
		NSLog(@"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF %s", (char *)_cmd);
	}
	if ([crap hasPrefix:@":"]) crap = [crap substringFromIndex:1];
	RCChannel *chan = [_channels objectForKey:@"IRC"];
	if (chan) [chan recievedMessage:crap from:@"" type:RCMessageTypeNormal];
	[scanner release];
	[p drain];
	// :irc.saurik.com 252 _m 2 :operator(s) online
}

- (void)handle332:(NSString *)topic {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSScanner *_scanner = [[NSScanner alloc] initWithString:topic];
	NSString *crap = @"_";
	NSString *to = crap;
	NSString *room = to;
	NSString *_topic = room;
	[_scanner scanUpToString:@" " intoString:&crap];
	[_scanner scanUpToString:@" " intoString:&crap];
	[_scanner scanUpToString:@" " intoString:&to];
	[_scanner scanUpToString:@" " intoString:&room];
	[_scanner scanUpToString:@"\r\n" intoString:&_topic];
	_topic = [_topic substringFromIndex:1];
	[[_channels objectForKey:room] recievedEvent:RCEventTypeTopic from:nil message:_topic];
	// :irc.saurik.com 332 _m #bacon :Bacon | where2start? kitchen | Canadian Bacon? get out. | WE SPEAK: BACON, ENGLISH, PORTUGUESE, DEUTSCH. | http://blog.craftzine.com/bacon-starry-night.jpg THIS IS YOU ¬†
	[_scanner release];
	[pool drain];
}

- (void)handle250:(NSString *)countr {
	// :hubbard.freenode.net 250 Guest01 :Highest connection count: 3549 (3548 clients) (177981 connections received)	
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

- (void)handle305:(NSString *)athreeofive {
	NSLog(@"Implying this is a znc.");
	NSLog(@"YAY I'M NO LONGER AWAY.");
	if ([[[[[RCNavigator sharedNavigator] currentPanel] channel] delegate] isEqual:self]) {
		[[[RCNavigator sharedNavigator] currentPanel] postMessage:@"You are no longer being marked as away" withFlavor:RCMessageFlavorTopic	highlight:NO];
	}

}

- (void)handle306:(NSString *)znc {
	NSLog(@"Implying this is a znc.");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSScanner *scanner = [[NSScanner alloc] initWithString:znc];
	NSString *crap;
	NSString *cmd;
	NSString *me;
	[scanner scanUpToString:@" " intoString:&crap];
	[scanner scanUpToString:@" " intoString:&cmd];
	[scanner scanUpToString:@" " intoString:&me];
	useNick = [me retain];
	[scanner release];
	
	[pool drain];
	// :fr.ac3xx.com 305 MaxZNC :You are no longer marked as being away
}

- (void)handle331:(NSString *)noTopic {
	// Relay[18195:707] MSG: :irc.saurik.com 331 _m #kk :No topic is set.
}

- (void)handle333:(NSString *)numbers {
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
	[scanner scanUpToString:@"\r\n" intoString:&users];
	if ([users length] > 1) {
		users = [users substringFromIndex:1];
		NSArray *_someUsers = [users componentsSeparatedByString:@" "];
		RCChannel *chan = [_channels objectForKey:room];
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
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	NSScanner *scanner = [[NSScanner alloc] initWithString:motd];
	NSString *crap;
	@try {
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner setScanLocation:[scanner scanLocation]+1];
		[scanner scanUpToString:@"\r\n" intoString:&crap];
	}
	@catch (NSException *exception) {
		NSLog(@"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF %s", (char *)_cmd);
	}
	if ([crap hasPrefix:@":"]) crap = [crap substringFromIndex:1];
	RCChannel *chan = [_channels objectForKey:@"IRC"];
	if (chan) [chan recievedMessage:crap from:@"" type:RCMessageTypeNormal];
	[scanner release];
	[p drain];
	// :irc.saurik.com 375 _m :irc.saurik.com message of the day
}

- (void)handle372:(NSString *)noMotd {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	NSScanner *scanner = [[NSScanner alloc] initWithString:noMotd];
	NSString *crap;
	@try {
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner scanUpToString:@" " intoString:&crap];
		[scanner setScanLocation:[scanner scanLocation]+1];
		[scanner scanUpToString:@"\r\n" intoString:&crap];
	}
	@catch (NSException *exception) {
		NSLog(@"FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF %s", (char *)_cmd);
	}
	if ([crap hasPrefix:@":"]) crap = [crap substringFromIndex:1];
	RCChannel *chan = [_channels objectForKey:@"IRC"];
	if (chan) [chan recievedMessage:crap from:@"" type:RCMessageTypeNormal];
	[scanner release];
	[p drain];
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

- (void)handle421:(NSString *)unknown {
	NSLog(@"Unknown : %@ BYTES: %@", unknown, [unknown dataUsingEncoding:NSUTF8StringEncoding]);
}

- (void)handle422:(NSString *)motd {
	NSLog(@"Ohai. %@", motd);
}

- (void)handle433:(NSString *)use {
	// nick is in use.
	useNick = [[useNick stringByAppendingString:@"_"] retain]; // set to autorelease, so retain'd copy will be released, and it will be set back to normal. :D
	[self sendMessage:[@"NICK " stringByAppendingString:useNick] canWait:NO];
}

- (void)handleNOTICE:(NSString *)notice {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
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
		[p drain];
		return;
	}
	[self parseUsermask:from nick:&from user:nil hostmask:nil];
	[_scans scanUpToString:@"\r\n" intoString:&msg];
	if ([nick isEqualToString:useNick]) {
		msg = [msg substringFromIndex:1];
	}
	from = [from substringFromIndex:1];
	if ([[RCNavigator sharedNavigator] currentPanel]) {
		if ([[[[[RCNavigator sharedNavigator] currentPanel] channel] delegate] isEqual:self]) {
			[[[[RCNavigator sharedNavigator] currentPanel] channel] recievedMessage:msg from:from type:RCMessageTypeNotice];
		}
		else {
			goto end;
		}
	}
	else {
	end:{
		RCChannel *chan = [_channels objectForKey:@"IRC"];
		[chan recievedMessage:msg from:from type:RCMessageTypeNotice];
	}
	}
	
	[_scans release];
	[p drain];
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
	[_scanner scanUpToString:@"\r\n" intoString:&msg];
	msg = [msg substringFromIndex:1];
	from = [from substringFromIndex:1];
	[self parseUsermask:from nick:&from user:nil hostmask:nil];
	if ([msg hasPrefix:@"\x01"]) {
		msg = [msg substringFromIndex:1];
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
			NSLog(@"Meh. %@:%@", msg, [msg dataUsingEncoding:NSUTF8StringEncoding]);
			if ([msg length] > 7) {
				msg = [msg substringWithRange:NSMakeRange(7, msg.length-8)];
				[((RCChannel *)[_channels objectForKey:room]) recievedMessage:msg from:from type:RCMessageTypeAction];
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
		if (![_channels objectForKey:room]) {
			// magicall.. 0.0
			// has to be a private message.
			// Reasoning: 
			// if we are registered to events from a channel,
			// we must have sent JOIN #channel;
			// which we have caught, and added the RCChannel already.
			[self addChannel:room join:YES];
		}
		[((RCChannel *)[_channels objectForKey:room]) recievedMessage:msg from:from type:RCMessageTypeNormal];
		// tell the channel a message was recieved. P:
	}
	[_scanner release];
}

- (void)handleKICK:(NSString *)aKick {
	// [NSString stringWithFormat:@"%@ %@", from, msg]
	// sending the from, must be User kicked user, and msg must be the reason, 
	// so [chann recievedEvent:RCEventTypeKickBlah from:[NSString stringWithFormat:@"user kicked user", arg1, arg1] message:reason];
}

- (void)handleNICK:(NSString *)nickChange {
	
}

- (void)handleCTCPRequest:(NSString *)_request {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	NSScanner *_sc = [[NSScanner alloc] initWithString:_request];
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
	[self parseUsermask:_from nick:&_from user:nil hostmask:nil];
	request = [request substringWithRange:NSMakeRange(2, request.length-5)];

	if ([request isEqualToString:@"TIME"]) 
		extra = [NSString stringWithFormat:@"%@", [NSDate date]];
	else if ([request isEqualToString:@"VERSION"]) 
		extra = @"Relay 1.0";
	else if ([request isEqualToString:@"USERINFO"]) 
		extra = @"";
	else if ([request isEqualToString:@"CLIENTINFO"]) 
		extra = @"CLIENTINFO VERSION CLIENTINFO USERINFO PING TIME UPTIME";
	else 
		NSLog(@"WTF?!?!! %@", request);
	[self sendMessage:[@"NOTICE " stringByAppendingFormat:@"%@ \x01%@ %@\x01", _from, request, extra]];
	[_sc release];
	[p drain];

}

- (void)handlePART:(NSString *)parted {
	
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	NSScanner *_scanner = [[NSScanner alloc] initWithString:parted];
	NSString *user = @"_";
	NSString *cmd = user;
	NSString *room = cmd;
	NSString *_nick = room;
	[_scanner scanUpToString:@" " intoString:&user];
	[_scanner scanUpToString:@" " intoString:&cmd];
	[_scanner scanUpToString:@" " intoString:&room];
	user = [user substringFromIndex:1];
	room = [room stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
	[self parseUsermask:user nick:&_nick user:nil hostmask:nil];
	if ([_nick isEqualToString:useNick]) {
		NSLog(@"I went byebye. Notify the police");
		[_scanner release];
		return;
	}
	else {
		[[_channels objectForKey:room] recievedEvent:RCEventTypePart from:_nick message:nil];
	}
	[_scanner release];
	[p drain];
}

- (void)handleJOIN:(NSString *)join {
	// add user unless self
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
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
	[self parseUsermask:user nick:&_nick user:nil hostmask:nil];
	
	if ([_nick isEqualToString:useNick]) {
		[self addChannel:room join:NO];
		[self sendMessage:[NSString stringWithFormat:@"NAMES %@\r\nTOPIC %@", room, room]];
		[[_channels objectForKey:room] setSuccessfullyJoined:YES];
	}
	else {
		[[_channels objectForKey:room] recievedEvent:RCEventTypeJoin from:_nick message:nil];
	}
	[_scanner release];
	[pool drain];
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
	if ([msg length] > 1) {
		msg = [msg substringFromIndex:1];
	}
	[self parseUsermask:fullHost nick:&user user:nil hostmask:nil];
	for (NSString *channel in channels) {
		RCChannel *chan = [_channels objectForKey:channel];
		[chan recievedEvent:RCEventTypeQuit from:user message:msg];
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
	[self parseUsermask:settr nick:&settr user:nil hostmask:nil];
	RCChannel *chan = [_channels objectForKey:room];
	if (chan) {
		if ([room isEqualToString:useNick]) {
			[scanr release];
			return;
		}
		if (!user) {
			[chan recievedEvent:RCEventTypeMode from:settr message:[NSString stringWithFormat:@"sets mode %@", modes]];
			[scanr release];
			return;
		}
		[chan recievedEvent:RCEventTypeMode from:settr message:[NSString stringWithFormat:@"sets mode %@ %@", modes, user]];
		[chan setMode:modes forUser:user];
		
	}
	[scanr release];
	// Relay[2626:f803] MSG: :ac3xx!ac3xx@rox-103C7229.ac3xx.com MODE #chat +o _m
}

- (void)handlePING:(NSString *)pong {
	if ([pong hasPrefix:@"PING"]) {
		[self sendMessage:[@"PONG " stringByAppendingString:[pong substringWithRange:NSMakeRange(5, pong.length-5)]] canWait:NO];
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
		[self parseUsermask:from nick:&user user:nil hostmask:nil];
		[self sendMessage:[@"PRIVMSG " stringByAppendingFormat:@"%@ \x01%@ %@\x01", user, @"PING", [msg substringWithRange:NSMakeRange(8, msg.length-9)]]];
		[scannr release];
	}
}

- (void)handlehost:(NSString *)hostInfo {
	RCChannel *chan = [_channels objectForKey:@"IRC"];
	if (chan) {
		[chan recievedMessage:[hostInfo substringFromIndex:1] from:@"" type:RCMessageTypeNormal];
	}
	// :Your host is irc.saurik.com, running version InspIRCd-1.1.18+Gudbrandsdalsost
	// .. ... . .. .. only at irc.saurik.comm
}

- (void)handleTOPIC:(NSString *)topic {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
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
	[self parseUsermask:from nick:&from user:nil hostmask:nil];
	[[_channels objectForKey:room] recievedEvent:RCEventTypeTopic from:from message:newTopic];
	[_scan release];
	[p drain];
}

// PRIVMSG victim :\001CLIENTINFO\001/////
- (void)parseUsermask:(NSString *)mask nick:(NSString **)_nick user:(NSString **)user hostmask:(NSString **)hostmask {
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

@end
