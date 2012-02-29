//
//  RCChannelBubble.m
//  Relay
//
//  Created by Max Shavrick on 2/25/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChannelBubble.h"

@implementation RCChannelBubble
@synthesize _highlighted;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[[self titleLabel] setFont:[UIFont boldSystemFontOfSize:13.5]];
		[[self titleLabel] setTextColor:[UIColor blackColor]];
		[[self titleLabel] setShadowColor:[UIColor darkGrayColor]];
		[[self titleLabel] setShadowOffset:CGSizeMake(0, 1)];
		selected = NO;
		hasNew = NO;
		_highlighted = NO;
    }
    return self;
}

- (void)_setSelected:(BOOL)_selected {
	if (selected == _selected) return;
	selected = _selected;
	hasNew = NO;
	_highlighted = NO;
	if (selected) {
		@autoreleasepool {
			UIImage *image = [[UIImage imageNamed:@"0_bble"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)];
			[self setBackgroundImage:image forState:UIControlStateNormal];
			[self setBackgroundImage:image forState:UIControlStateHighlighted];
			[self setBackgroundImage:image forState:UIControlStateSelected];
			[[self titleLabel] setShadowColor:[UIColor darkGrayColor]];
		}
	}
	else {
		[self setBackgroundImage:nil forState:UIControlStateNormal];
		[self setBackgroundImage:nil forState:UIControlStateHighlighted];
		[self setBackgroundImage:nil forState:UIControlStateSelected];
		[[self titleLabel] setTextColor:[UIColor blackColor]];
		[[self titleLabel] setShadowColor:[UIColor whiteColor]];
	}
}

- (void)setMentioned:(BOOL)mentioned {
	if (_highlighted == mentioned) return;
	_highlighted = mentioned;
	if (mentioned) {
		[[self titleLabel] setTextColor:[UIColor redColor]];
	}
	else {
		if (selected) {
			[[self titleLabel] setShadowColor:[UIColor whiteColor]];	
		}
	}
}

- (void)setHasNewMessage:(BOOL)msgs {
	if (msgs == hasNew) return;
	hasNew = msgs;
	if (hasNew) {
		if (!_highlighted) [[self titleLabel] setTextColor:[UIColor blueColor]];
	}
	else {
		if (selected) [[self titleLabel] setShadowColor:[UIColor whiteColor]];		
	}
}


@end
