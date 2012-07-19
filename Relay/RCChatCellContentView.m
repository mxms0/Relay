//
//  RCChatCellContentView.m
//  Relay
//
//  Created by Max Shavrick on 7/18/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChatCellContentView.h"
#import "RCChatCell.h"

@implementation RCChatCellContentView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	[(RCChatCell *)[self superview] drawContentView:rect];
}

@end
