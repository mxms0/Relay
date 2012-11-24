//
//  RCSuperSpecialTableView.m
//  Relay
//
//  Created by Max Shavrick on 11/23/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCSuperSpecialTableView.h"

@implementation RCSuperSpecialTableView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	NSArray *indexPathsForVisibleRows = [self indexPathsForVisibleRows];
	if ([indexPathsForVisibleRows count] == 0) {
		[jaggs removeFromSuperlayer];
		[jaggs release];
		jaggs = nil;
	}
	
	NSIndexPath *lastRow = [indexPathsForVisibleRows lastObject];
	if ([lastRow section] == [self numberOfSections] - 1 &&
		[lastRow row] == [self numberOfRowsInSection:[lastRow section]] - 1) {
		UIView *cell = [self cellForRowAtIndexPath:lastRow];
		if (!jaggs) {
			jaggs = [[CALayer alloc] init];
			UIImage *jg = [UIImage imageNamed:@"0_jaggs"];
			jaggs.contents = (id)jg.CGImage;
			[cell.layer insertSublayer:jaggs atIndex:0];
		}
		else if ([cell.layer.sublayers indexOfObjectIdenticalTo:jaggs] != 0) {
			[cell.layer insertSublayer:jaggs atIndex:0];
		}
		
		CGRect shadowFrame = jaggs.frame;
		shadowFrame.size.width = cell.frame.size.width;
		shadowFrame.origin.y = cell.frame.size.height;
		shadowFrame.size.height = 4;
		jaggs.frame = shadowFrame;
	}
	else {
		[jaggs removeFromSuperlayer];
		[jaggs release];
		jaggs = nil;
	}
}

@end
