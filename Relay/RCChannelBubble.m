//
//  RCChannelBubble.m
//  Relay
//
//  Created by Max Shavrick on 2/25/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChannelBubble.h"

@implementation RCChannelBubble
@synthesize _highlighted, _selected;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[[self titleLabel] setFont:[UIFont boldSystemFontOfSize:13]];
		[[self titleLabel] setShadowOffset:CGSizeMake(0, 1)];
		_selected = NO;
		hasNew = NO;
		_highlighted = NO;
		self.reversesTitleShadowWhenHighlighted = NO;
    }
    return self;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
	[super setTitle:title forState:state];
	if (![title isEqualToString:@"IRC"]) {
		UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(suicide:)];
		[longPress setNumberOfTapsRequired:1];
		[longPress setMinimumPressDuration:0.5];
		[self addGestureRecognizer:longPress];
		[longPress release];
	}
}

- (void)suicide:(UIGestureRecognizer *)suicidee {
	if (suicidee.state == UIGestureRecognizerStateBegan) {
		[[[self allTargets] anyObject] channelWantsSuicide:[suicidee view]];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	if (!_selected) {
		[[self titleLabel] setTextColor:[UIColor blackColor]];
		[[self titleLabel] setShadowColor:[UIColor whiteColor]];
	}
}

- (void)_setSelected:(BOOL)selected {
	if (_selected == selected) return;
	_selected = selected;
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
		if (_selected) {
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
		if (_selected) [[self titleLabel] setShadowColor:[UIColor whiteColor]];		
	}
}


@end
