//
//  RCNetworkCellBackgroundView.m
//  Relay
//
//  Created by Max Shavrick on 10/21/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCNetworkCellBackgroundView.h"

@implementation RCNetworkCellBackgroundView
@synthesize isTop, isBottom;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self setBackgroundColor:[UIColor clearColor]];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	UIImage *img = [UIImage imageNamed:@"0_cell_selec"];
	[img drawAsPatternInRect:CGRectMake(6, (isTop ? 0 : 2), 242, 50)];
}

@end
