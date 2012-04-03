//
//  RCNewMessagesBubble.m
//  Relay
//
//  Created by Max Shavrick on 3/25/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCNewMessagesBubble.h"
#import <QuartzCore/QuartzCore.h>

@implementation RCNewMessagesBubble

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		noglow = [[[UIImage imageNamed:@"0_rednotification_noglow"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)] retain];
		glow = [[[UIImage imageNamed:@"0_rednotification_glow"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)] retain];
		[self setBackgroundImage:noglow forState:UIControlStateNormal];
		[self setBackgroundImage:noglow forState:UIControlStateHighlighted];
		[self setBackgroundImage:noglow forState:UIControlStateSelected];
		[[self titleLabel] setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[[self titleLabel] setTextAlignment:UITextAlignmentCenter];
		[[self titleLabel] setFont:[UIFont boldSystemFontOfSize:11.5]];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[[self titleLabel] setHidden:NO];
	[[self titleLabel] setShadowColor:[UIColor blackColor]];
	[[self titleLabel] setTextColor:[UIColor whiteColor]];
	[[self titleLabel] setShadowOffset:CGSizeMake(0, 1)];
}

- (void)realignTitleLabel {
	[[self titleLabel] setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

- (void)pulse {
	[UIView animateWithDuration:5 delay:2 options:UIViewAnimationCurveEaseIn animations:^{ 
		[self setBackgroundImage:glow forState:UIControlStateNormal];
		
	} completion:^(BOOL finished) {
		if (finished) 
			[self setBackgroundImage:noglow forState:UIControlStateNormal];
	}];	
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
