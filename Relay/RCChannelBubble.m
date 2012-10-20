//
//  RCChannelBubble.m
//  Relay
//
//  Created by Max Shavrick on 2/25/12.
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
            image = [[[UIImage imageNamed:@"0_bble"] resizableImageWithCapInsets:UIEdgeInsetsMake(0,10, 0, 10)] retain];
        }
		[[self titleLabel] setFont:[UIFont boldSystemFontOfSize:13]];
		[[self titleLabel] setShadowOffset:CGSizeMake(0, 1)];
		isSelected = NO;
		hasNewMessages = NO;
		hasNewHighlights = NO;
		_rcount = 0;
		self.exclusiveTouch = YES;
        channel = channel_;
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

- (void)setTitle:(NSString *)title forState:(UIControlState)state {
	[super setTitle:title forState:state];
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

- (void)tapPerformed:(UIGestureRecognizer *)suicidee {
	if (delegate) {
		if (suicidee.state == UIGestureRecognizerStateBegan) {
			if (delegate) 
				[delegate displayOptionsForChannel:self];
		}
	}
    [self fixColors];
}

- (void)dealloc {
    @synchronized(self) {
        [super dealloc];
    }
}

- (void)fixColors {
    [self retain];
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		@synchronized(self) {
			@synchronized([self channel]) {
				if (isSelected) {
					if ([self backgroundImageForState:UIControlStateNormal] != image) {
						[self setBackgroundImage:image forState:UIControlStateNormal];
					}
					[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
					[self setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
					if (![(RCChannel *)[self channel] joined]) {
						[self setTitleColor:UIColorFromRGB(0x8d9196) forState:UIControlStateNormal];
						[self setTitleShadowColor:UIColorFromRGB(0x262729) forState:UIControlStateNormal];
					}
				}
				else {
					[self setBackgroundImage:nil forState:UIControlStateNormal];
					if (hasNewHighlights) {
						[self setTitleColor:UIColorFromRGB(0xDB4949) forState:UIControlStateNormal];
						[self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
					}
					else if (hasNewMessages) {
						[self setTitleColor:UIColorFromRGB(0x498ADB) forState:UIControlStateNormal];
						[self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    }
					else {
						[self setTitleColor:UIColorFromRGB(0x3e3f3f) forState:UIControlStateNormal];
						[self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
					}
					if (![(RCChannel*)[self channel] joined]) {
						[self setTitleColor:UIColorFromRGB(0xa7abb1) forState:UIControlStateNormal];
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
