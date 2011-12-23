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
@synthesize server, nick, port, wantsSSL, servPass;

- (BOOL)connect {
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
    
    if (servPass)
        [self sendMessage:[NSString stringWithFormat:@"PASS %@", servPass]];
    
    [self sendMessage:@"USER ac3xx ac3xx ac3xx ac3xx"];
    [self sendMessage:@"NICK ac3xxlulz"];
    
	return YES;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
	static NSMutableString *response;
	switch (eventCode) {
		case NSStreamEventEndEncountered:
			B_LOG(NSStreamEventEndEncountered);
			break;
		case NSStreamEventErrorOccurred:
			B_LOG(NSStreamEventErrorOccurred);
			break;
		case NSStreamEventHasBytesAvailable:
		//	B_LOG(NSStreamEventHasBytesAvailable);
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
			B_LOG(NSStreamEventHasSpaceAvailable);
			break;
		case NSStreamEventNone:
			B_LOG(NSStreamEventNone);
			break;
		case NSStreamEventOpenCompleted:
			B_LOG(NSStreamEventOpenCompleted);
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
		objc_msgSend([RCResponseParser sharedParser], NSSelectorFromString([NSStringFromSelector(_cmd) stringByAppendingString:@"delegate:"]), message, self);
	}
}

- (NSArray *)parseString:(NSString *)string {
    NSScanner *scan = [NSScanner scannerWithString:string];
    if([string hasPrefix:@":"]) {
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
	[iStream release];
	[oStream release];
}

@end
