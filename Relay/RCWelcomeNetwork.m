//
//  RCWelcomeNetwork.m
//  Relay
//
//  Created by Max Shavrick on 2/27/12.
//

#import "RCWelcomeNetwork.h"

@implementation RCWelcomeNetwork

- (RCChannel *)addChannel:(NSString *)_chan join:(BOOL)join {
	RCWelcomeChannel *chan = [[RCWelcomeChannel alloc] initWithChannelName:_chan];
	[chan setDelegate:self];
	[chan setSuccessfullyJoined:YES];
    @synchronized(_channels) {
        [_channels addObject:chan];
    }
	[chan release];
	[chan setJoined:YES withArgument:nil];
    return chan;
}

- (void)connect {
}

- (BOOL)sendMessage:(NSString *)msg {
	return YES;
}

@end
