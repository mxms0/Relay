//
//  RCTextField.m
//  Relay
//
//  Created by Max Shavrick on 3/21/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCTextField.h"

@implementation RCTextField

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
	}
	return self;
}

- (void)drawPlaceholderInRect:(CGRect)rect {
	[UIColorFromRGB(0xCDCDCD) setFill];
	[[self placeholder] drawInRect:CGRectMake(rect.origin.x, 0, rect.size.width, rect.size.height) withFont:[UIFont systemFontOfSize:13]];
}

@end
