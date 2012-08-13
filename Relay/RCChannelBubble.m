//
//  RCChannelBubble.m
//  Relay
//
//  Created by Max Shavrick on 2/25/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChannelBubble.h"
#import "RCNavigator.h"
static UIImage* image = nil;
@implementation RCChannelBubble
@synthesize hasNewHighlights, isSelected, _rcount;

- (BOOL)_selected
{
    return self.isSelected;
}

- (id)initWithFrame:(CGRect)frame andChan:(RCChannel*)channel_ {
	if ((self = [super initWithFrame:frame])) {
        if (!image) {
            image = [[[UIImage imageNamed:@"0_bble"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 9, 0, 9)] retain];
        }
		[[self titleLabel] setFont:[UIFont boldSystemFontOfSize:13]];
		[[self titleLabel] setShadowOffset:CGSizeMake(0, 1)];
        /*
         BOOL isSelected;
         BOOL hasNewMessages;
         BOOL hasNewHighlights;
         */
		isSelected = NO;
		hasNewMessages = NO;
		hasNewHighlights = NO;
		_rcount = 0;
        channel = channel_;
		self.alpha = 1;
		self.reversesTitleShadowWhenHighlighted = NO;
        self.adjustsImageWhenHighlighted = NO;
        [self fixColors];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"NO");
    [self release];
    return nil;
}

- (RCChannel*)channel
{
    return channel;
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
		if (![channel isPrivate]) {
			UILongPressGestureRecognizer *longHold = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showUserList:)];
			[longHold setNumberOfTapsRequired:0];
			[longHold setMinimumPressDuration:0.5];
			[self addGestureRecognizer:longHold];
			[longHold release];
		}
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
            //	[[[self allTargets] anyObject] channelWantsSuicide:self];
		}
	}
    [self fixColors];
}

- (void) fixColors
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        if (isSelected) {
            if ([self backgroundImageForState:UIControlStateNormal] != image) {
                [self setBackgroundImage:image forState:UIControlStateNormal];
            }
            [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self setTitleShadowColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        } else
        {
            [self setBackgroundImage:nil forState:UIControlStateNormal];
            if (hasNewHighlights) {
                [self setTitleColor:UIColorFromRGB(0xea584f) forState:UIControlStateNormal];
                [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
            } else if (hasNewMessages) {
                [self setTitleColor:UIColorFromRGB(0x4f94ea) forState:UIControlStateNormal];
                [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
            } else {
                [self setTitleColor:UIColorFromRGB(0x3e3f3f) forState:UIControlStateNormal];
                [self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }
        [self layoutSubviews];
    });
}

- (void)_setSelected:(BOOL)selected {
    @synchronized(self)
    {
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
    @synchronized(self)
    {
        if (mentioned == hasNewHighlights || isSelected == YES) {
            return;
        }
        hasNewHighlights = YES;
        hasNewMessages = NO;
        [self fixColors];
    }
}

- (void)setHasNewMessage:(BOOL)msgs {
    @synchronized(self)
    {
        if (msgs == hasNewMessages || isSelected == YES || hasNewHighlights == YES) {
            return;
        }
        hasNewMessages = msgs;
        [self fixColors];
    }
}

@end
