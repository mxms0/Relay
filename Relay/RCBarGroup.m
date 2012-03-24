//
//  RCBarGroup.m
//  Relay
//
//  Created by Max Shavrick on 3/23/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCBarGroup.h"

@implementation RCBarGroup

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.clipsToBounds = NO;
		left = [[RCBar alloc] initWithFrame:CGRectMake(0, 0, 11, 31)];
		right = [[RCBar alloc] initWithFrame:CGRectMake(7, 0, 11, 31)];
		[left setImage:[UIImage imageNamed:@"0_normalbar"]];
		[right setImage:[UIImage imageNamed:@"0_normalbar"]];
		[self addSubview:left];
		[self addSubview:right];
		[left release];
		[right release];
    }
    return self;
}

- (void)setLeftBarMode:(int)modr {
	if (!left) return;
	if (left.mode == modr) return;
	[left setMode:modr];
	@autoreleasepool {
		switch (left.mode) {
			case 0:
				[left setImage:[UIImage imageNamed:@"0_normalbar"]];
				break;
			case 1:
				[left setImage:[UIImage imageNamed:@"0_bluebar_noglow"]];
				break;
			case 2:
				[left setImage:[UIImage imageNamed:@"0_redbar_noglow"]];
				break;
			default:
				break;
		}
	}
}

- (void)setRightBarMode:(int)modr {
	if (!right) return;
	if (right.mode == modr) return;
	[right setMode:modr];
	@autoreleasepool {
		switch (right.mode) {
			case 0:
				[right setImage:[UIImage imageNamed:@"0_normalbar"]];
				break;
			case 1:
				[right setImage:[UIImage imageNamed:@"0_bluebar_noglow"]];
				break;
			case 2:
				[right setImage:[UIImage imageNamed:@"0_redbar_noglow"]];
				break;
			default:
				break;
		}
	}
}

@end
