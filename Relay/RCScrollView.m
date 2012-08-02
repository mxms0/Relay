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
		y = 0;
	}
	return self;
}

- (void)layoutMessage:(RCMessage *)ms {
	[ms setFrame:CGRectMake(2, y+2, 316, [ms messageHeight])];
	[ms setWrapped:YES];
	[self.layer addSublayer:ms];
	[ms release];
	y = ms.frame.size.height + ms.frame.origin.y;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
}

@end
