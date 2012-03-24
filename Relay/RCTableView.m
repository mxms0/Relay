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

- (CAGradientLayer *)shadowAsInverse:(BOOL)inverse {
	CAGradientLayer *newShadow = [[[CAGradientLayer alloc] init] autorelease];
	CGRect newShadowFrame = CGRectMake(0, 0, self.frame.size.width, inverse ? SHADOW_INVERSE_HEIGHT : SHADOW_HEIGHT);
	newShadow.frame = newShadowFrame;
	CGColorRef darkColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:inverse ? (SHADOW_INVERSE_HEIGHT / SHADOW_HEIGHT) * 0.5 : 0.5].CGColor;
	CGColorRef lightColor =	[self.backgroundColor colorWithAlphaComponent:0.0].CGColor;
	newShadow.colors = [NSArray arrayWithObjects:(id)(inverse ? lightColor : darkColor), (id)(inverse ? darkColor : lightColor), nil];
	return newShadow;
}


- (void)layoutSubviews {
	[super layoutSubviews];
	
	NSArray *indexPathsForVisibleRows = [self indexPathsForVisibleRows];
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
//			[cell.layer insertSublayer:bottomShadow atIndex:0];
		}
		else if ([cell.layer.sublayers indexOfObjectIdenticalTo:bottomShadow] != 0) {
			[cell insertSubview:bottomShadow atIndex:0];
		//	[cell.layer insertSublayer:bottomShadow atIndex:0];
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
	}
}

- (void)dealloc {
	[bottomShadow release];
	[super dealloc];
}

@end
