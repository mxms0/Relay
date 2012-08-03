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
		y = 4;
		[self setScrollEnabled:YES];
	}
	return self;
}

- (void)prepareToRelaySubviews {
	
}

- (void)layoutMessage:(RCMessage *)ms {
	[ms setFrame:CGRectMake(2, y, 316, (self.frame.size.width == 320 ? [ms messageHeight] : [ms messageHeightLandscape])+2)];
	[ms setWrapped:YES];
	[self.layer addSublayer:ms];
	[ms setBackgroundColor:[UIColor clearColor].CGColor];
	[ms release];
	y = ms.frame.size.height + ms.frame.origin.y;
	[self setContentSize:CGSizeMake(320, y)];	
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
}

@end
