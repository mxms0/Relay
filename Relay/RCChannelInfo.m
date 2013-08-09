//
//  RCChannelInfo.m
//  Relay
//
//  Created by Max Shavrick on 8/18/12.
//

#import "RCChannelInfo.h"

@implementation RCChannelInfo
@synthesize userCount, topic, channel, isAlreadyInChannel;

- (id)description {
	return [NSString stringWithFormat:@"<RCChannelInfo %p; channel = %@;>", self, channel];
}

- (void)dealloc {
	[topic release];
	[channel release];
	[super dealloc];
}

@end
