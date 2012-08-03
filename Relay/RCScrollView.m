//
//  RCScrollView.m
//  Relay
//
//  Created by Max Shavrick on 7/27/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCScrollView.h"
#import <CoreText/CoreText.h>
#import "CHAttributedString.h"
#import "RCMessage.h"

@implementation RCScrollView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self setBackgroundColor:[UIColor clearColor]];
		y = 2;
		[self setScrollEnabled:YES];
	}
	return self;
}

- (void)layoutMessage:(RCMessage *)ms {
	[ms setFrame:CGRectMake(2, y, 316, (self.frame.size.width == 320 ? [ms messageHeight] : [ms messageHeightLandscape])+2)];
	[ms setWrapped:YES];
	//	UIImage *bg = nil;
	//if (ms.frame.size.height > 15) {
	//	float layr = ms.frame.size.height/15;
	//	bg = [UIImage imageNamed:[NSString stringWithFormat:@"0_chatcell_%d", (int)layr]];
	//}
	//else {
	//	bg = [UIImage imageNamed:@"0_chatcell"];
	//}
	//ms.backgroundColor = [UIColor colorWithPatternImage:bg].CGColor;
	[self.layer addSublayer:ms];
	[ms setBackgroundColor:[UIColor whiteColor].CGColor];
	[ms release];
	y = ms.frame.size.height + ms.frame.origin.y;
	[self setContentSize:CGSizeMake(320, y)];
	
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
}

@end
