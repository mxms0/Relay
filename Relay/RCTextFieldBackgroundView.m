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
	[[[UIImage imageNamed:@"0_input"] stretchableImageWithLeftCapWidth:20 topCapHeight:20] drawInRect:(CGRect){{0,0}, self.frame.size}];
}

@end
