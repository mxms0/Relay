//
//  RCCuteView.m
//  Relay
//
//  Created by Max Shavrick on 6/29/13.
//

#import "RCCuteView.h"
#import "RCChatController.h"

@implementation RCCuteView

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	UITouch *tc = [touches anyObject];
	CGPoint pt = [tc locationInView:self];
	if (CGRectContainsPoint(CGRectMake(0, 0, self.frame.size.width, 40), pt)) {
		[self dismiss];
	}
}

- (void)dismiss {
	[[RCChatController sharedController] dismissChannelList:self];
}

@end
