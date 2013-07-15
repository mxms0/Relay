//
//  RCAddCell.m
//  Relay
//
//  Created by Max Shavrick on 3/21/12.
//

#import "RCAddCell.h"
#import <QuartzCore/QuartzCore.h>
#import "RCBasicViewController.h"

@implementation RCAddCell

- (void)drawRect:(CGRect)rect {
	[UIColorFromRGB(0x393d4a) set];
	UIRectFill(rect);
}

@end
