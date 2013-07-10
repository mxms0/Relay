//
//  RCCuteView.m
//  Relay
//
//  Created by Siberia on 6/29/13.
//

#import "RCCuteView.h"
#import "RCChatController.h"

@implementation RCCuteView

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	UITouch *tc = [touches anyObject];
	CGPoint pt = [tc locationInView:self];
	if (CGRectIntersectsRect(CGRectMake(pt.x, pt.y, 13, 13), CGRectMake(0, 0, 320, 40))) {
		// sorry.
		[self dismiss];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	[[[self subviews] objectAtIndex:0] touchesBegan:touches withEvent:event];
	[[[self subviews] objectAtIndex:0] hitTest:[[touches anyObject] locationInView:nil] withEvent:event];
	MARK;
}

- (void)dismiss {
	[[RCChatController sharedController] dismissChannelList:self animated:YES];
}

@end
