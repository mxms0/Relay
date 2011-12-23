//
//  RCSocket.m
//  Relay
//
//  Created by Max Shavrick on 12/23/11.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import "RCSocket.h"

@implementation RCSocket
@synthesize server, nick, port, wantsSSL;

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
	return YES;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
	NSLog(@"Stream: %@ EventCode: %d", aStream, eventCode);
}

- (void)dealloc {
	[super dealloc];
	[server release];
	[nick release];
	[iStream release];
	[oStream release];
}

@end
