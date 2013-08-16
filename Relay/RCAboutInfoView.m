//
//  RCAboutInfoView.m
//  Relay
//
//  Created by Max Shavrick on 8/16/13.
//

#import "RCAboutInfoView.h"

@implementation RCAboutInfoView
@synthesize attributedString;

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[attributedString drawInRect:rect];
}

@end
