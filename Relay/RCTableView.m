//
//  RCTableView.m
//  Relay
//
//  Created by Max Shavrick on 3/8/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCTableView.h"

@implementation RCTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
	if ((self = [super initWithFrame:frame style:style])) {
		
	}
	return self;
}
- (void)layoutSubviews {
	[super layoutSubviews];
	
/*	NSArray *indexPathsForVisibleRows = [self indexPathsForVisibleRows];
	if ([indexPathsForVisibleRows count] == 0) {
		[bottomShadow removeFromSuperview];
		[bottomShadow release];
		bottomShadow = nil;
		return;
	}
	
	NSIndexPath *lastRow = [indexPathsForVisibleRows lastObject];
	if ([lastRow section] == [self numberOfSections] - 1 &&
		[lastRow row] == [self numberOfRowsInSection:[lastRow section]] - 1) {
		UIView *cell = [self cellForRowAtIndexPath:lastRow];
		if (!bottomShadow) {
			bottomShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"0_shadow_t"]];
			[cell insertSubview:bottomShadow atIndex:0];
		}
		else if ([cell.layer.sublayers indexOfObjectIdenticalTo:bottomShadow] != 0) {
			[cell insertSubview:bottomShadow atIndex:0];
		}
		
		CGRect shadowFrame = bottomShadow.frame;
		shadowFrame.size.width = cell.frame.size.width;
		shadowFrame.origin.y = cell.frame.size.height;
		bottomShadow.frame = shadowFrame;
	}
	else {
		[bottomShadow removeFromSuperview];
		[bottomShadow release];
		bottomShadow = nil;
	}*/
}

- (void)dealloc {
//	[bottomShadow release];
	[super dealloc];
}

@end
