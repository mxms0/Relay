//
//  RCTitleLabel.m
//  Relay
//
//  Created by Max Shavrick on 2/25/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCTitleLabel.h"

@implementation RCTitleLabel

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.textAlignment = UITextAlignmentCenter;
		self.shadowColor = UIColorFromRGB(0xf3f3f4);
		self.shadowOffset = CGSizeMake(0,1);
		self.textColor = UIColorFromRGB(0x3e3f3f);
		self.font = [UIFont systemFontOfSize:30];
		[self setUserInteractionEnabled:YES];
		[self setAdjustsFontSizeToFitWidth:YES];
		[self setMinimumFontSize:13];
		[self setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
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
