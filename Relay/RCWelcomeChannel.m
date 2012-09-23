//
//  RCWelcomeChannel.m
//  Relay
//
//  Created by Max Shavrick on 6/30/12.
//

#import "RCWelcomeChannel.h"

@implementation RCWelcomeChannel

- (void)setBubble:(RCChannelBubble *)_bubble {
	bubble = _bubble;
	for (id _gest in [_bubble gestureRecognizers]) {
		[_bubble removeGestureRecognizer:_gest];
	}
	// seriously, do not fuck with this.
	// this simple block of code cost me several hours.
	// XXX: DO NOT FUCK WITH
	// XXX: thank you.
}

@end
