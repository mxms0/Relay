//
//  RCChatNavigationBar.m
//  Relay
//
//  Created by Max Shavrick on 10/27/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChatNavigationBar.h"

@implementation RCChatNavigationBar
@synthesize subtitle, title;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		title = nil;
		subtitle = nil;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	UIImage *bg = [UIImage imageNamed:@"0_headr"];
	[bg drawAtPoint:CGPointMake(0, 0)];
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0, [UIColor whiteColor].CGColor);
	CGContextSetFillColorWithColor(ctx, UIColorFromRGB(0x282C40).CGColor);
	CGFloat size = 0.0;
	float maxWidth = (rect.size.width-100);
	CGSize drawingSize = [title sizeWithFont:[UIFont boldSystemFontOfSize:24] minFontSize:18 actualFontSize:&size forWidth:maxWidth lineBreakMode:UILineBreakModeClip];
	[title drawInRect:CGRectMake(50, (!!subtitle ? 1 : (((rect.size.height-4)/2)-(size/2))), maxWidth, 30) withFont:[UIFont boldSystemFontOfSize:size] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
	if (subtitle) {
		CGFloat subsze = 0.0;
		CGSize smallDSize = [subtitle sizeWithFont:[UIFont systemFontOfSize:12] minFontSize:11 actualFontSize:&subsze forWidth:maxWidth lineBreakMode:UILineBreakModeClip];
		CGContextSetFillColorWithColor(ctx, UIColorFromRGB(0x626464).CGColor);
		[subtitle drawInRect:CGRectMake(50, 3+size, maxWidth, 14) withFont:[UIFont systemFontOfSize:subsze] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
	}
}

- (void)dealloc {
	[title release];
	[subtitle release];
	[super dealloc];
}

@end
