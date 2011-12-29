//
//  RCSocket.m
//  Relay
//
//  Created by Max Shavrick on 12/23/11.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import "RCSocket.h"
#define B_LOG(y) NSLog(@"LOG: %s %d %@ %d", __FILE__, __LINE__, NSStringFromSelector(_cmd), y);

@implementation RCSocket
@synthesize server, nick, port, wantsSSL, servPass, status, channels, isRegistered, username, realName;

- (BOOL)connect {
	parser = [[RCResponseParser alloc] init];
	channels = [[NSMutableArray alloc] init];
	isRegistered = NO;
	parser.delegate = self;
	CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)server, port ? port : 6667, (CFReadStreamRef *)&iStream, (CFWriteStreamRef *)&oStream);
	[iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[iStream setDelegate:self];
	[oStream setDelegate:self];
	if ([iStream streamStatus] == NSStreamStatusNotOpen)
		[iStream open];
	if ([oStream streamStatus] == NSStreamStatusNotOpen)
		[oStream open];
	if (wantsSSL) {
		[iStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
		[oStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
		NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], kCFStreamSSLAllowsExpiredCertificates,
								  [NSNumber numberWithBool:YES], kCFStreamSSLAllowsAnyRoot, [NSNumber numberWithBool:NO], 
								  kCFStreamSSLValidatesCertificateChain, kCFNull, kCFStreamSSLPeerName, nil];
		CFReadStreamSetProperty((CFReadStreamRef)iStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
		CFWriteStreamSetProperty((CFWriteStreamRef)oStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
		[settings release];
	}
	if ([self status] == RCSocketStatusOpen || [self status] == RCSocketStatusConnecting) {
		return NO; //already connected or trying to connect.
	}
	status = RCSocketStatusConnecting;
    if (servPass)
        [self sendMessage:[NSString stringWithFormat:@"PASS %@", servPass]];
    
    [self sendMessage:[@"USER " stringByAppendingFormat:@"%@ %@ %@ %@", (username ? username : nick), nick, nick, (realName ? realName : nick)]];
    [self sendMessage:[@"NICK " stringByAppendingString:nick]];
    
	return YES;
}

- (BOOL)disconnect {
	[self sendMessage:@"QUIT Relay 1.0"];
	status = RCSocketStatuClosed;
	[parser release];
	[iStream close];
	[oStream close];
	[iStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[oStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[iStream setDelegate:nil];
	[oStream setDelegate:nil];
	[iStream release];
	[oStream release];
	iStream = nil;
	oStream = nil;
	NSLog(@"Disconnected...");
	return YES;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
	static NSMutableString *response;
	switch (eventCode) {
		case NSStreamEventEndEncountered:
			if (status != RCSocketStatusError) {
				status = RCSocketStatuClosed;
				[self disconnect];
			}
			break;
		case NSStreamEventErrorOccurred:
			if (status == RCSocketStatusError) {
				[self disconnect];
				[[NSNotificationCenter defaultCenter] postNotificationName:@"RELOAD_NETWORKS" object:nil];
			}
			status = RCSocketStatusError;
			break;
		case NSStreamEventHasBytesAvailable:
			if (!response) 
				response = [[NSMutableString alloc] init];
			uint8_t buffer;
			NSInteger read = [(NSInputStream *)aStream read:&buffer maxLength:1];
			if (read)
				[response appendFormat:@"%c", buffer];
			if ([response hasSuffix:@"\r\n"]) {
				[self messageRecieved:response];
				[response release];
				response = nil;
			}
			break;
		case NSStreamEventHasSpaceAvailable:
			if (status == RCSocketStatusConnecting) 
				status = RCSocketStatusOpen;
				[[NSNotificationCenter defaultCenter] postNotificationName:@"RELOAD_NETWORKS" object:nil];
			break;
		case NSStreamEventNone:
			break;
		case NSStreamEventOpenCompleted:
			break;
			
	}
}

- (void)messageRecieved:(NSString *)message {
	if ([message hasPrefix:@"PING"]) {
		NSLog(@"PING! %@", message);
		NSRange rangeOfPing = [message rangeOfString:@"PING :"];
		[self sendMessage:[@"PONG " stringByAppendingString:[message substringWithRange:NSMakeRange(rangeOfPing.location+rangeOfPing.length, message.length-(rangeOfPing.location+rangeOfPing.length))]]];
	}
	else {
		[parser messageRecieved:message];
	}
}

- (void)respondToVersion:(NSString *)from {
	NSLog(@"VERSION: %@",from);
	[self sendMessage:[@"NOTICE VERSION " stringByAppendingFormat:@"%@ Relay 1.0b1!",from]];
}

- (void)joinRoom:(NSString *)room {
	if (![channels containsObject:room]) {
		[self sendMessage:[@"JOIN " stringByAppendingString:room]];
		[self addRoom:room];
	}
	else return;
}

- (void)addRoom:(NSString *)roomName {
	if (![channels containsObject:roomName]) {
		[channels addObject:roomName];
	}
	NSLog(@"Meh. %@",roomName);
}

- (BOOL)isConnected {
	return ((status == RCSocketStatusOpen) || (status == RCSocketStatusConnecting));
}

- (void)addUser:(NSString *)_nick toRoom:(NSString *)room {
	NSLog(@"%@ Joiend %@", _nick, room);
}

- (void)channel:(NSString *)chan recievedMessage:(NSString *)msg fromUser:(NSString *)usr {
	NSLog(@"%@:[%@:%@]", chan, msg, usr);
}

- (NSArray *)parseString:(NSString *)string {
    NSScanner *scan = [NSScanner scannerWithString:string];
    if ([string hasPrefix:@":"]) {
        [scan setScanLocation:1];
    }
    NSString *sender = nil;
    NSString *command = nil;
    NSString *argument = nil;
    
    [scan scanUpToString:@" " intoString:&sender];
    [scan scanUpToString:@" " intoString:&command];
    [scan scanUpToString:@"\r\n" intoString:&argument];
    return [NSArray arrayWithObjects:sender, command, argument, nil];
}

- (void)sendMessage:(NSString *)command {
	NSString *message = [command stringByAppendingString:@"\r\n"];
    NSData *messageData = [message dataUsingEncoding:NSASCIIStringEncoding];
    [oStream write:[messageData bytes] maxLength:[messageData length]];
}

- (void)dealloc {
	[super dealloc];
	[server release];
	[nick release];
	[username release];
	[realName release];
	[channels release];
	[iStream release];
	[oStream release];
}

@end
