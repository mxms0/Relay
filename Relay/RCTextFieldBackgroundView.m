//
//  RCTextFieldBackgroundView.m
//  Relay
//
//  Created by Max Shavrick on 7/16/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCTextFieldBackgroundView.h"

@implementation RCTextFieldBackgroundView

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	if (rect.size.width > 320) {
		[[UIImage imageNamed:@"0_input_l"] drawInRect:rect];
	}
	else {
		[[UIImage imageNamed:@"0_input"] drawInRect:rect];
	}
}

@end
