//
//  RCSocket.m
//  Relay
//
//  Created by Max Shavrick on 1/16/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCSocket.h"
#import "RCNetwork.h"
#import <objc/runtime.h>

@implementation RCSocket
@synthesize delegate, status;

- (id)initWithNetwork:(id)_network {
	if ((self = [super init])) {
		status = RCSocketStatusNotOpen;
		network = _network;
		queue = [[NSOperationQueue alloc] init];
	}
	return self;
}

- (BOOL)_connect {
	if ((status != RCSocketStatusConnecting) && (status != RCSocketStatusConnected)) {
	}
	return NO;
}

- (BOOL)sendMessage:(NSString *)msg {

	return NO;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
	static NSMutableString *data = nil;
	switch (eventCode) {
		case NSStreamEventEndEncountered: // 16 - Called on ping timeout/closing link
			status = RCSocketStatusClosed;
			[delegate networkDidRecieveResponse:1];
			NSLog(@"NSStreamEventEndEncountered:%d",NSStreamEventEndEncountered);
			[[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_KEY object:nil];
			break;
		case NSStreamEventErrorOccurred: /// 8 - Unknowns/bad interwebz
			status = RCSocketStatusError;
			[delegate networkDidRecieveResponse:1];
			NSLog(@"NSStreamEventErrorOccurred:%d",NSStreamEventErrorOccurred);
			[[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_KEY object:nil];
			break;
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
			break;
		case NSStreamEventHasSpaceAvailable: // 4
			if (status == RCSocketStatusConnecting)
				status = RCSocketStatusConnected;
			NSLog(@"NSStreamEventHasSpaceAvailable:%d",NSStreamEventHasSpaceAvailable);
			break;
		case NSStreamEventNone:
			NSLog(@"NSStreamEventNone:%d",NSStreamEventNone);
			break;
		case NSStreamEventOpenCompleted: // 1
			status = RCSocketStatusConnected;
			NSLog(@"NSStreamEventOpenCompleted:%d",NSStreamEventOpenCompleted);
			[[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_KEY object:nil];
			break;
	}
}

- (BOOL)_isConnecting {
	return (status == RCSocketStatusConnecting);
}
- (BOOL)_isConnected {
	return (status == RCSocketStatusConnected);
}

- (void)recievedMessage:(NSString *)msg {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	if ([msg hasPrefix:@"PING"]) {
		[self sendMessage:[@"PONG" stringByAppendingString:[msg substringWithRange:NSMakeRange(4, msg.length-4)]]];
		[p drain];
		return;
	}
	else if ([msg hasPrefix:@"ERROR"]) {
		[p drain];
		return;
		// handle error..
	}
	NSScanner *_scanr = [[NSScanner alloc] initWithString:msg];
	NSString *from = @"0_Max";
	NSString *cmd = @"0_HAI";
	[_scanr scanUpToString:@" " intoString:&from];
	[_scanr setScanLocation:[_scanr scanLocation]+1];
	[_scanr scanUpToString:@" " intoString:&cmd];
	NSLog(@"Crap:%@ cmd:%@", from, cmd);
	NSString *_msg = [NSString stringWithFormat:@"handle%@:", cmd];
	SEL _pSEL = NSSelectorFromString(_msg);
	if ([self respondsToSelector:_pSEL]) 
		[self performSelectorInBackground:_pSEL withObject:msg];
	else NSLog(@"PLZ IMPLEMENT: %s", (char *)_pSEL);
	// some messages begin with \x01
	// i think all messages end of \x0D\x0A
	// \x0D\x0A = \r\n :D
	if ([msg hasSuffix:@"\x0A"]) NSLog(@"Haider. %@", [msg dataUsingEncoding:NSUTF8StringEncoding]);
	NSLog(@"message: %@",msg);
	[_scanr release];
	[p drain]; 
}

- (BOOL)_disconnect {

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
			NSLog(@"Disconnecting..");
	}
	return YES;
}

- (void)handleNotice:(NSString *)aNotice {
	
}

- (void)handle001:(NSString *)welcome {
	
}

- (void)handle002:(NSString *)host {
	
}

- (void)dealloc {
	[super dealloc];
}

@end
