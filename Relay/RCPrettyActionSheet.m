//
//  RCPrettyActionSheet.m
//  Relay
//
//  Created by Max Shavrick on 10/20/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCPrettyActionSheet.h"

@implementation RCPrettyActionSheet

- (void)layoutSubviews {
	[super layoutSubviews];
	for (UIButton *vs in [self subviews]) {
		switch ([vs tag]) {
			case 1:
				[vs setBackgroundImage:[[UIImage imageNamed:@"0_as_del"] stretchableImageWithLeftCapWidth:11 topCapHeight:0] forState:UIControlStateNormal];
				[vs setBackgroundImage:[[UIImage imageNamed:@"0_as_del_press"] stretchableImageWithLeftCapWidth:11 topCapHeight:0] forState:UIControlStateHighlighted];
				break;
			case 2:
				[vs setBackgroundImage:[[UIImage imageNamed:@"0_as"] stretchableImageWithLeftCapWidth:11 topCapHeight:0] forState:UIControlStateNormal];
				[vs setBackgroundImage:[[UIImage imageNamed:@"0_as_press"] stretchableImageWithLeftCapWidth:11 topCapHeight:0] forState:UIControlStateHighlighted];
				break;
			case 3:
				[vs setBackgroundImage:[[UIImage imageNamed:@"0_as"] stretchableImageWithLeftCapWidth:11 topCapHeight:0] forState:UIControlStateNormal];
				[vs setBackgroundImage:[[UIImage imageNamed:@"0_as_press"] stretchableImageWithLeftCapWidth:11 topCapHeight:0] forState:UIControlStateHighlighted];
				break;
			case 4:
				[vs setBackgroundImage:[[UIImage imageNamed:@"0_as_cancel"] stretchableImageWithLeftCapWidth:11 topCapHeight:0] forState:UIControlStateNormal];
				[vs setBackgroundImage:[[UIImage imageNamed:@"0_as_cancel_press"] stretchableImageWithLeftCapWidth:10 topCapHeight:0] forState:UIControlStateHighlighted];
				break;
			default:
				break;
		}
	}
}

- (void)drawRect:(CGRect)rect {
	[UIColorFromRGB(0x181d24) set];
	UIRectFill(rect);
	UIImage *img = [UIImage imageNamed:@"0_as_bg"];
	[img drawAsPatternInRect:CGRectMake(0, 0, rect.size.width, img.size.height)];
}

@end