//
//  RCConsoleChannel.m
//  Relay
//
//  Created by Max Shavrick on 3/2/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCConsoleChannel.h"

@implementation RCConsoleChannel

- (void)recievedMessage:(NSString *)message from:(NSString *)from type:(RCMessageType)type {
	
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	RCMessageFlavor flavor;
	NSString *msg;
	switch (type) {
		case RCMessageTypeAction:
			msg = [[NSString stringWithFormat:@"\u2022 %@ %@", from, message] copy];
			flavor = RCMessageTypeAction;
			break;
		case RCMessageTypeNormal:
			msg = [[NSString stringWithFormat:@" %@", message] copy];
			flavor = RCMessageFlavorNormalE;
			break;
		case RCMessageTypeNotice:
			flavor = RCMessageFlavorNotice;
			break;
	}
	[panel postMessage:msg withFlavor:flavor isHighlight:NO];
	[p drain];
	return;
}

@end
