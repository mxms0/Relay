//
//  RCPrettyAlertView.m
//  Relay
//
//  Created by Max Shavrick on 7/22/12.
//

#import "RCPrettyAlertView.h"

@implementation RCPrettyAlertView

- (void)layoutSubviews {
	[super layoutSubviews];
	BOOL setbg = NO;
	for (id v in [self subviews]) {
		if ([v isKindOfClass:[UIImageView class]]) {
			if (!setbg) {
				[(UIImageView *)v setImage:[[UIImage imageNamed:@"0_alertview"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
				UIImageView *gradient = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"0_alertview_mask"]];
				[v addSubview:gradient];
				[gradient release];
				setbg = YES;
			}
		}
		if ([v isKindOfClass:[UIButton class]]) {
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
