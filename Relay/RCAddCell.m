//
//  RCAddCell.m
//  Relay
//
//  Created by Max Shavrick on 3/21/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCAddCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation RCAddCell
@synthesize isBottom, isTop;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		isTop = NO; isBottom = NO;
		self.textLabel.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	if (isTop || isBottom) {
		int setup = (UIRectCornerTopLeft | UIRectCornerTopRight);
		if (isBottom) setup = (UIRectCornerBottomLeft | UIRectCornerBottomRight);
		UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:setup cornerRadii:CGSizeMake(4.0, 4.0)];
		CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
		maskLayer.path = maskPath.CGPath;
		self.layer.mask = maskLayer;
		[maskLayer release];
	}
	self.clipsToBounds = YES;
	self.backgroundColor = UIColorFromRGB(0xECECEC);
	self.frame = CGRectMake(10, self.frame.origin.y, 300, 47);
}

- (void)drawRect:(CGRect)rect {
	if (!isTop) {
		[UIColorFromRGB(0xABABAB) set];
		UIRectFill(CGRectMake(0, 0, 300, 1));
	}
}

@end
