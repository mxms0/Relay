//
//  RCChannel.m
//  Relay
//
//  Created by Max Shavrick on 1/23/12.
//

#import "RCChannel.h"

@implementation RCChannel

@synthesize channelName;

- (void)dealloc {
	[channelName release];
	[super dealloc];
}

- (id)description {
	return [NSString stringWithFormat:@"[%@ %@]", [super description], channelName];
}

@end
