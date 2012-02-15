//
//  RCNetwork.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCNetwork.h"
#import "RCNetworkManager.h"

@implementation RCNetwork

@synthesize sDescription, server, nick, username, realname, spass, npass, port, isRegistered, useSSL, COL, channels, _channels;

- (id)init {
	if ((self = [super init])) {
		shouldSave = NO;
		_scores = 0;
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

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; %@;>", NSStringFromClass([self class]), self, [self infoDictionary]];
}

- (NSString *)descriptionForComparing {
	return [NSString stringWithFormat:@"%@%@%@%@%d%d", username, nick, realname, server, port, useSSL];
}

- (void)setupRooms:(NSArray *)rooms {
	for (NSString *_chan in rooms) {
		[self addChannel:_chan join:NO];
	}
}
- (void)addChannel:(NSString *)_chan join:(BOOL)join {
	if (![[_channels allKeys] containsObject:_chan]) {
		RCChannel *chan = [[RCChannel alloc] init];
		[chan setChannelName:_chan];
		[[self _channels] setObject:chan forKey:_chan];
		[chan release];
		if (![[self channels] containsObject:_chan])
			[[self channels] addObject:_chan];
		if (join)
			[self sendMessage:[@"JOIN " stringByAppendingString:_chan]];
		[[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_KEY object:nil];
		shouldSave = YES;
	}
	else return;
 
}

#pragma mark - SOCKET STUFF

- (BOOL)connect {
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
	if ([iStream streamStatus] == NSStreamStatusNotOpen)
		[iStream open];
	if ([oStream streamError] == NSStreamStatusNotOpen)
		[oStream open];
	
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
		[self sendMessage:[@"PASS " stringByAppendingString:spass]];
	}
	[self sendMessage:[@"USER " stringByAppendingFormat:@"%@ %@ %@ :%@", (username ? username : nick), nick, nick, (realname ? realname : nick)]];
	[self sendMessage:[@"NICK " stringByAppendingString:nick]];
	return YES;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
	static NSMutableString *data = nil;
	switch (eventCode) {
		case NSStreamEventEndEncountered: // 16 - Called on ping timeout/closing link
			status = RCSocketStatusClosed;
			NSLog(@"NSStreamEventEndEncountered:%d", NSStreamEventEndEncountered);
			[[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_KEY object:nil];
			return;
		case NSStreamEventErrorOccurred: /// 8 - Unknowns/bad interwebz
			status = RCSocketStatusError;
			NSLog(@"NSStreamEventErrorOccurred:%d", NSStreamEventErrorOccurred);
			[[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_KEY object:nil];
			return;
		case NSStreamEventHasBytesAvailable: // 2
			if (!data) data = [NSMutableString new];
			uint8_t buffer;
			NSUInteger bytesRead = [(NSInputStream *)aStream read:&buffer maxLength:1];
			if (bytesRead)
				[data appendFormat:@"%c", buffer];
			if ([data hasSuffix:@"\r\n"]) {
				[self recievedMessage:data];
				[data release];
				data = nil;
			}
			return;
		case NSStreamEventHasSpaceAvailable: // 4
			if (status == RCSocketStatusConnecting)
				status = RCSocketStatusConnected;
			NSLog(@"NSStreamEventHasSpaceAvailable:%d", NSStreamEventHasSpaceAvailable);
			return;
		case NSStreamEventNone:
			NSLog(@"NSStreamEventNone:%d", NSStreamEventNone);
			return;
		case NSStreamEventOpenCompleted: // 1
			status = RCSocketStatusConnected;
			NSLog(@"NSStreamEventOpenCompleted:%d", NSStreamEventOpenCompleted);
			[[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_KEY object:nil];
			return;
	}
}

- (BOOL)sendMessage:(NSString *)msg {
	NSData *messageData = [[msg stringByAppendingString:@"\r\n"] dataUsingEncoding:NSASCIIStringEncoding];
	if ([oStream write:[messageData bytes] maxLength:[messageData length]] != -1) {
		return YES;
	}
	[self errorOccured:[oStream streamError]];
	return NO;
}

- (void)errorOccured:(NSError *)error {
	NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)recievedMessage:(NSString *)msg {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	if ([msg hasPrefix:@"PING"]) {
		[self handlePING:msg];
		[p drain];
		return;
	}
	else if ([msg hasPrefix:@"ERROR"]) {
		//handle..
		[p drain];
		return;
	}
	NSScanner *_scanr = [[NSScanner alloc] initWithString:msg];
	NSString *from = @"_"; // what is wrong with you
	NSString *cmd = @"_"; // i agree with him ^
	[_scanr scanUpToString:@" " intoString:&from];
	[_scanr setScanLocation:[_scanr scanLocation]+1];
	[_scanr scanUpToString:@" " intoString:&cmd];
	NSString *selName = [NSString stringWithFormat:@"handle%@:", cmd];
	SEL pSEL = NSSelectorFromString(selName);
	if ([self respondsToSelector:pSEL]) 
		[self performSelector:pSEL withObject:msg];
	else NSLog(@"PLZ IMPLEMENT: %s MSG: %@", (char *)pSEL, msg);
	
	if (![msg hasSuffix:@"\x0A"]) NSLog(@"HAXHAXHAXHAXHAXHAHAX000101010");
	// told not to always trust server. 
	[_scanr release];
	// some messages begin with \x01
	// i think all messages end of \x0D\x0A
	// \x0D\x0A = \r\n :D	
	[p drain];
}

- (BOOL)disconnect {
	if ((status == RCSocketStatusConnected) || (status == RCSocketStatusConnecting)) {
		[self sendMessage:@"QUIT :Relay 1.0"];
		status = RCSocketStatusClosed;
		[[UIApplication sharedApplication] endBackgroundTask:task];
		task = UIBackgroundTaskInvalid;
		[[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_KEY object:nil];
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
	NSLog(@"Meh. %@ : %@", channels, _channels);
	for (RCChannel *chan in channels) {
		/*if ([[_channels objectForKey:chan] joinOnConnect])*/ [[_channels objectForKey:chan] setJoined:YES withArgument:nil];
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
}

- (void)handle002:(NSString *)infos {
	// Relay[2626:f803] MSG: :fr.ac3xx.com 002 _m :Your host is fr.ac3xx.com, running version Unreal3.2.9
}

- (void)handle003:(NSString *)servInfos {
	// Relay[2626:f803] MSG: :fr.ac3xx.com 003 _m :This server was created Fri Dec 23 2011 at 01:21:01 CET
}

- (void)handle004:(NSString *)othrInfo {
	// Relay[2626:f803] MSG: :fr.ac3xx.com 004 _m fr.ac3xx.com Unreal3.2.9 iowghraAsORTVSxNCWqBzvdHtGp 
}

- (void)handle005:(NSString *)useInfo {
	// Relay[2794:f803] MSG: :fr.ac3xx.com 005 _m WALLCHOPS WATCH=128 WATCHOPTS=A SILENCE=15 MODES=12 CHANTYPES=# PREFIX=(qaohv)~&@%+ CHANMODES=beI,kfL,lj,psmntirRcOAQKVCuzNSMTGZ NETWORK=ROXnet CASEMAPPING=ascii EXTBAN=~,qjncrR ELIST=MNUCT STATUSMSG=~&@%+ :are supported by this server
}

- (void)handle251:(NSString *)infos {
	// Relay[3067:f803] MSG: :fr.ac3xx.com 251 _m :There are 1 users and 4 invisible on 1 servers
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

- (void)handle353:(NSString *)users {
	// add users to room listing..
}
- (void)handle366:(NSString *)end {
	// end of /NAMES list
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
	// motd.
}

- (void)handle433:(NSString *)use {
	// nick is in use.
	_scores++;
	NSString *format = @"%@";
	for (int i = 0; i < _scores; i++) format = [format stringByAppendingString:@"_"];
	[self sendMessage:[@"NICK " stringByAppendingFormat:format, nick]];
}

- (void)handleNOTICE:(NSString *)notice {
	NSLog(@"NOTICE: %@", notice);
}

- (void)handlePRIVMSG:(NSString *)privmsg {	
	NSLog(@"MSG: %@ BYTES: %@", privmsg, [privmsg dataUsingEncoding:NSASCIIStringEncoding]);
	NSLog(@"HAS COLOR: %d", (BOOL)([privmsg rangeOfString:@"\x03"].location != NSNotFound));
	NSScanner *_scanner = [[NSScanner alloc] initWithString:privmsg];
	NSString *from = @"";
	NSString *cmd = from; // will be unused.
	NSString *room = from;
	NSString *msg = from;
	[_scanner scanUpToString:@" " intoString:&from];
	[_scanner scanUpToString:@" " intoString:&cmd];
	[_scanner scanUpToString:@" " intoString:&room];
	[_scanner scanUpToString:@" :" intoString:&msg];
	msg = [msg substringFromIndex:1];
	from = [from substringFromIndex:1];
	[self parseUsermask:from nick:&from user:nil hostmask:nil];
	NSLog(@"vars %@ %@ %@ %@", from, cmd, room, msg);
	if ([msg hasPrefix:@"\x01"]) {
		msg = [msg substringFromIndex:1];
		NSLog(@"HAI. %@:%@", msg, [msg dataUsingEncoding:NSUTF8StringEncoding]);
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
			msg = [msg substringWithRange:NSMakeRange(7, msg.length-8)];
			[((RCChannel *)[_channels objectForKey:room]) recievedMessage:msg from:from type:RCMessageTypeAction];
			[[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_KEY object:nil];
			[_scanner release];
			return;
		}
	}
	else {
//		msg = [msg substringWithRange:NSMakeRange(0, )];
		[((RCChannel *)[_channels objectForKey:room]) recievedMessage:msg from:from type:RCMessageTypeNormal];
		[[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_KEY object:nil];
		// tell the channel a message was recieved. P:
	}
	[_scanner release];
}

- (void)handleKICK:(NSString *)aKick {
	
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
	NSLog(@"VARS: %@ %@ %@ %@", _from, cmd, to, request);
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

- (void)handleJOIN:(NSString *)join {
	// add user unless self
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	NSScanner *_scanner = [[NSScanner alloc] initWithString:join];
	NSString *user = @"_";
	NSString *cmd = user;
	NSString *room = cmd;
	NSString *_nick = room;
	[_scanner scanUpToString:@" " intoString:&user];
	[_scanner scanUpToString:@" " intoString:&cmd];
	[_scanner scanUpToString:@" :" intoString:&room];
	user = [user substringFromIndex:1];
	room = [room substringFromIndex:1];
	NSString *__nick = nick;
	[self parseUsermask:user nick:&_nick user:nil hostmask:nil];
	NSLog(@"VARS: %@ %@ %@", user, _nick, room);
	for (int i = 0; i < _scores; i++) __nick = [__nick stringByAppendingString:@"_"];
	if ([_nick isEqualToString:__nick]) {
		[self addChannel:[room stringByReplacingOccurrencesOfString:@"\r\n" withString:@""] join:NO];
		[_scanner release];
		return;
	}
	NSLog(@"%@ JOINED %@", _nick, room);
	[_scanner release];
	[p drain];
}

- (void)handleQUIT:(NSString *)quitter {
	 
}

- (void)handleMODE:(NSString *)modes {
	NSLog(@"MODE : %@", modes);
	// Relay[2626:f803] MSG: :ac3xx!ac3xx@rox-103C7229.ac3xx.com MODE #chat +o _m
}

- (void)handlePING:(NSString *)pong {
	NSLog(@"SEND PONG! : %@", pong);
	if ([pong hasPrefix:@"PING"]) {
		[self sendMessage:[@"PONG " stringByAppendingString:[pong substringWithRange:NSMakeRange(5, pong.length-5)]]];
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
	}
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
