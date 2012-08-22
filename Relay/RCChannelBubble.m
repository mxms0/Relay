//
//  RCChannelBubble.m
//  Relay
//
//  Created by Max Shavrick on 2/25/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChannelBubble.h"
#import "RCNavigator.h"

static UIImage *image = nil;

@implementation RCChannelBubble
@synthesize hasNewHighlights, isSelected, _rcount, channel;

- (BOOL)_selected {
    return self.isSelected;
}

- (id)initWithFrame:(CGRect)frame andChan:(RCChannel *)channel_ {
	if ((self = [super initWithFrame:frame])) {
        if (!image) {
            image = [[[UIImage imageNamed:@"0_bble"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)] retain];
        }
		[[self titleLabel] setFont:[UIFont boldSystemFontOfSize:13]];
		[[self titleLabel] setShadowOffset:CGSizeMake(0, 1)];
		isSelected = NO;
		hasNewMessages = NO;
		hasNewHighlights = NO;
		_rcount = 0;
		self.exclusiveTouch = YES;
        channel = channel_;
		//		UILongPressGestureRecognizer *pp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressBegan:)];
		//pp.minimumPressDuration = 1;
		//[self addGestureRecognizer:pp];
		//[pp release];
		self.alpha = 1;
		self.reversesTitleShadowWhenHighlighted = NO;
        self.adjustsImageWhenHighlighted = NO;
        [self fixColors];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    NSLog(@"NO");
    [self release];
    return nil;
}

- (RCChannel *)channel {
    return channel;
}

- (void)longPressBegan:(UIGestureRecognizer *)gg {
	longPressed = ([gg state] == UIGestureRecognizerStateBegan);
	if (longPressed) {
		//id vv = [[gg view] retain];
		//[[gg view] removeFromSuperview];
		//		[self.superview addSubview:vv];
	}
}
/*
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (longPressed) {
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint touchLocation = [touch locationInView:self.superview];
	self.center = touchLocation;
		
	}
}*/

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
	[super setTitle:title forState:state];
	if (![title isEqualToString:@"IRC"]) {
		delegate = [[self allTargets] anyObject];
		UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(suicide:)];
		[longPress setNumberOfTapsRequired:1];
		[longPress setMinimumPressDuration:0.5];
		[self addGestureRecognizer:longPress];
		[longPress release];
	}
    [self fixColors];
}

- (id)description {
	return [NSString stringWithFormat:@"%@+%@",[super description],self.titleLabel.text];
}

- (void)showUserList:(UIGestureRecognizer *)longHold {
	if (delegate) {
		[delegate tearDownForChannelList:self];
	}
    [self fixColors];
}

- (void)suicide:(UIGestureRecognizer *)suicidee {
	if (delegate) {
		if (suicidee.state == UIGestureRecognizerStateBegan) {
			if (delegate) 
				[delegate channelWantsSuicide:self];
		}
	}
    [self fixColors];
}

- (void)dealloc
{
    @synchronized(self)
    {
        [super dealloc];
    }
}

- (void)fixColors {
    [self retain];
    dispatch_async(dispatch_get_main_queue(), ^(void){
        @synchronized(self)
        {
            @synchronized([self channel])
            {
                NSLog(@"inside fixColors");
                if (isSelected) {
                    if ([self backgroundImageForState:UIControlStateNormal] != image) {
                        [self setBackgroundImage:image forState:UIControlStateNormal];
                    }
                    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [self setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                    if (![(RCChannel*)[self channel] joined]) {
                        [self setTitleColor:UIColorFromRGB(0xc4c4c4) forState:UIControlStateNormal];
                        [self setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
                    }
                } else {
                    [self setBackgroundImage:nil forState:UIControlStateNormal];
                    if (hasNewHighlights) {
                        [self setTitleColor:UIColorFromRGB(0xDB4949) forState:UIControlStateNormal];
                        [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    } else if (hasNewMessages) {
                        [self setTitleColor:UIColorFromRGB(0x498ADB) forState:UIControlStateNormal];
                        [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    } else {
                        [self setTitleColor:UIColorFromRGB(0x3e3f3f) forState:UIControlStateNormal];
                        [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    }
                    if (![(RCChannel*)[self channel] joined]) {
                        [self setTitleColor:UIColorFromRGB(0xc4c4c4) forState:UIControlStateNormal];
                        [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    }
                }
            }
            [self layoutSubviews];
        }
        [self release];
    });
}

- (void)_setSelected:(BOOL)selected {
    @synchronized(self) {
        if (selected == isSelected) {
            return;
        }
        hasNewHighlights = NO;
        hasNewMessages = NO;
        isSelected = selected;
        [self fixColors];
    }
}

- (void)setMentioned:(BOOL)mentioned {
    @synchronized(self) {
        if (mentioned == hasNewHighlights || isSelected == YES) {
            return;
        }
        hasNewHighlights = YES;
        hasNewMessages = NO;
        [self fixColors];
    }
}

- (void)setHasNewMessage:(BOOL)msgs {
    @synchronized(self) {
		if (msgs == hasNewMessages || isSelected == YES || hasNewHighlights == YES) {
			return;
		}
		hasNewMessages = msgs;
		[self fixColors];
	}
}

@end
