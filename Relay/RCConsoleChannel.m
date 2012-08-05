//
//  RCConsoleChannel.m
//  Relay
//
//  Created by Max Shavrick on 3/2/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCConsoleChannel.h"

@implementation RCConsoleChannel

- (id)initWithChannelName:(NSString *)_name {
    if ((self = [super initWithChannelName:_name])) {
    }
    return self;
}

- (void)setSuccessfullyJoined:(BOOL)success {
    joined = success;
}

- (void)recievedMessage:(NSString *)message from:(NSString *)from type:(RCMessageType)type {
	NSString *msg = @"";
	switch (type) {
		case RCMessageTypeAction:
			msg = [NSString stringWithFormat:@"\u2022 %@ %@", from, message];
			break;
		case RCMessageTypeNormal:
			msg = [NSString stringWithFormat:@"%@", message];
			type = RCMessageTypeNormalE;
			break;
		case RCMessageTypeNotice:
			msg = [NSString stringWithFormat:@"-%@- %@", from, message];
			break;
	}
	[panel postMessage:msg withType:type highlight:NO];
	return;
}

@end
