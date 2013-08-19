//
//  RCTextFieldBackgroundView.m
//  Relay
//
//  Created by Max Shavrick on 7/16/12.
//

#import "RCTextFieldBackgroundView.h"

@implementation RCTextFieldBackgroundView

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[[UIColor clearColor] set];
	[[[UIImage imageNamed:@"maintextfield"] stretchableImageWithLeftCapWidth:19 topCapHeight:0] drawInRect:(CGRect){{0, 2}, self.frame.size}];
}

@end
