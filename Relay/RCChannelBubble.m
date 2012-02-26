//
//  RCChannelBubble.m
//  Relay
//
//  Created by Max Shavrick on 2/25/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChannelBubble.h"

@implementation RCChannelBubble

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[[self titleLabel] setFont:[UIFont boldSystemFontOfSize:15]];
		[[self titleLabel] setTextColor:[UIColor blackColor]];
		[[self titleLabel] setShadowColor:[UIColor darkGrayColor]];
		[[self titleLabel] setShadowOffset:CGSizeMake(0, 2)];
		@autoreleasepool {
			UIImage *image = [[UIImage imageNamed:@"0_bble"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)];
			[self setBackgroundImage:image forState:UIControlStateNormal];
			[self setBackgroundImage:image forState:UIControlStateHighlighted];
			[self setBackgroundImage:image forState:UIControlStateSelected];
		}
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
