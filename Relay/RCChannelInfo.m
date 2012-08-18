//
//  RCChannelInfo.m
//  Relay
//
//  Created by Max Shavrick on 8/18/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChannelInfo.h"

@implementation RCChannelInfo
@synthesize userCount, topic, channel;

- (void)dealloc {
	[topic release];
	[channel release];
	[super dealloc];
}

@end
