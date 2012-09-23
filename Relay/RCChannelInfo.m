//
//  RCChannelInfo.m
//  Relay
//
//  Created by Max Shavrick on 8/18/12.
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
