//
//  RCChannel.m
//  Relay
//
//  Created by James Long on 24/12/2011.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import "RCChannel.h"

@implementation RCChannel

- (id)initWithRoomName:(NSString *)_name {
	if ((self = [super init])) {
		name = [_name retain];
	}
	return self;
}

- (void)messageRecieved:(NSString *)message from:(NSString *)from {
	// post to chat panel... ;D
}

- (void)dealloc {
	[super dealloc];
	[name release];
}

@end
