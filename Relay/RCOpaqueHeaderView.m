//
//  RCOpaqueHeaderView.m
//  Relay
//
//  Created by Max Shavrick on 8/23/13.
//

#import "RCOpaqueHeaderView.h"

@implementation RCOpaqueHeaderView

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[UIColorFromRGB(0x2b2b2e) set];
	UIRectFill(rect);
	[UIColorFromRGB(0x414143) set];
	UIRectFill(CGRectMake(0, 0, rect.size.width, 1));
	[UIColorFromRGB(0x161618) set];
	UIRectFill(CGRectMake(0, rect.size.height-.5, rect.size.width, .5));
}

@end
