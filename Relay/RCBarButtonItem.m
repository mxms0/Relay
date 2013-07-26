//
//  RCBarButtonItem.m
//  Relay
//
//  Created by Max Shavrick on 6/19/13.
//

#import "RCBarButtonItem.h"

@implementation RCBarButtonItem

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	if (shouldDrawBG) {
	//	UIImage *tch = [UIImage imageNamed:@"0_tch"];
	//	[tch drawAtPoint:CGPointMake(9, 6)];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	shouldDrawBG = YES;
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	shouldDrawBG = NO;
	[self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	shouldDrawBG = NO;
	[self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesCancelled:touches withEvent:event];
	shouldDrawBG = NO;
	[self setNeedsDisplay];
}

@end
