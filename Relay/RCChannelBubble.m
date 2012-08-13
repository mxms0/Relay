//
//  RCChannelBubble.m
//  Relay
//
//  Created by Max Shavrick on 2/25/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChannelBubble.h"
#import "RCNavigator.h"

@implementation RCChannelBubble
@synthesize _highlighted, _selected, _rcount;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[[self titleLabel] setFont:[UIFont boldSystemFontOfSize:13]];
		[[self titleLabel] setShadowOffset:CGSizeMake(0, 1)];
		[[self titleLabel] setTextColor:UIColorFromRGB(0x3e3f3f)];
		_selected = NO;
		hasNew = NO;
		_highlighted = NO;
		_rcount = 0;
		self.alpha = 1;
		self.reversesTitleShadowWhenHighlighted = NO;
    }
    return self;
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
	[super setTitle:title forState:state];
	if (![title isEqualToString:@"IRC"]) {
		delegate = [[self allTargets] anyObject];
		UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(suicide:)];
		[longPress setNumberOfTapsRequired:1];
		[longPress setMinimumPressDuration:0.5];
		[self addGestureRecognizer:longPress];
		[longPress release];
		if ([title hasPrefix:@"#"]) {
			UILongPressGestureRecognizer *longHold = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showUserList:)];
			[longHold setNumberOfTapsRequired:0];
			[longHold setMinimumPressDuration:0.5];
			[self addGestureRecognizer:longHold];
			[longHold release];
		}
	}
}

- (id)description {
	return [NSString stringWithFormat:@"%@+%@",[super description],self.titleLabel.text];
}

- (void)showUserList:(UIGestureRecognizer *)longHold {
	if (delegate) {
		[delegate tearDownForChannelList:self];
	}
}

- (void)suicide:(UIGestureRecognizer *)suicidee {
	if (delegate) {
		if (suicidee.state == UIGestureRecognizerStateBegan) {
			if (delegate) 
				[delegate channelWantsSuicide:self];
		//	[[[self allTargets] anyObject] channelWantsSuicide:self];
		}
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	if (_highlighted) {
		[[self titleLabel] setTextColor:[UIColor redColor]];
		[[self titleLabel] setShadowColor:[UIColor whiteColor]];
		return;
	}
	if (!_selected) {
		[[self titleLabel] setTextColor:UIColorFromRGB(0x3e3f3f)];
		[[self titleLabel] setShadowColor:[UIColor whiteColor]];
	}
}

- (void)_setSelected:(BOOL)selected {
	if (_selected == selected) return;
	_rcount = 0;
	_selected = selected;
	hasNew = NO;
	_highlighted = NO;
	[self setHasNewMessage:NO];
    [self setMentioned:NO];
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
		[[self titleLabel] setTextColor:UIColorFromRGB(0x3e3f3f)];
		[[self titleLabel] setShadowColor:[UIColor whiteColor]];
	}
}

- (void)setMentioned:(BOOL)mentioned {
    if (_selected) {
        return;
    }
	if (_highlighted == mentioned) return;
	_highlighted = mentioned;
	if (_highlighted) {
		[[self titleLabel] setTextColor:UIColorFromRGB(0xDA4156)];
	}
	else {
		if (_selected) {
			[[self titleLabel] setShadowColor:[UIColor whiteColor]];
		}
	}
}

- (void)setHasNewMessage:(BOOL)msgs {
    if (_selected) {
        return;
    }
	if (msgs == hasNew) return;
	hasNew = msgs;
	if (hasNew) {
		if (!_highlighted) {
			if ([[[self titleLabel] text] hasPrefix:@"#"]) {
				[[self titleLabel] setTextColor:UIColorFromRGB(0x4F94EA)];
			}
			else {
				[self setMentioned:YES];
			}
		}
	}
	else {
		if (_selected) [[self titleLabel] setShadowColor:[UIColor whiteColor]];		
	}
}

@end
