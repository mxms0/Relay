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
			NSLog(@"Meh %@", NSStringFromCGRect([v frame]));
		}
	}
}

@end
