//
//  RCPrettyAlertView.m
//  Relay
//
//  Created by Max Shavrick on 7/22/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCPrettyAlertView.h"

@implementation RCPrettyAlertView

- (void)show {
	[super show];
	for (id v in [self subviews]) {
		if ([v isKindOfClass:[UIImageView class]]) {
			[(UIImageView *)v setImage:[[UIImage imageNamed:@"0_alertview"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
			UIImageView *gradient = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"0_alertview_mask"]];
			[v addSubview:gradient];
			[gradient release];
			
		}
		if ([v isKindOfClass:[UIButton class]]) {
			NSLog(@"meh hi %@", [v imageForState:UIControlStateNormal]);
			if ([v tag] == 1) {
				[v setBackgroundImage:[[UIImage imageNamed:@"0_alertview_c"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
				[v setBackgroundImage:[[UIImage imageNamed:@"0_alertview_p"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateHighlighted];
			}
			else if ([v tag] == 2) {
				[v setBackgroundImage:[[UIImage imageNamed:@"0_alertview_d"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
				[v setBackgroundImage:[[UIImage imageNamed:@"0_alertview_p"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateHighlighted];
			}
		}
	}
}

@end
