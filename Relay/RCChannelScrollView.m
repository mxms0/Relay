//
//  RCRoomScrollView.m
//  Relay
//
//  Created by Max Shavrick on 2/25/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChannelScrollView.h"
#import <QuartzCore/QuartzCore.h>

@implementation RCChannelScrollView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self setScrollEnabled:YES];
		[self setDirectionalLockEnabled:NO];
		shouldDrawBG = YES;
		[self setOpaque:NO];
		[self setClearsContextBeforeDrawing:YES];
		[self setClipsToBounds:NO];
		[self.layer setMasksToBounds:NO];
		[self setShowsHorizontalScrollIndicator:NO];
		UIImage *shadow = [UIImage imageNamed:@"0_r_shadow"];
		RCShadowLayer *sLayer = [[RCShadowLayer alloc] init];
		sLayer.contents = (id)shadow.CGImage;
		sLayer.opacity = 0.3;
		sLayer.frame = CGRectMake(0, 32, 320, 15);
		[self.layer addSublayer:sLayer];
		[sLayer release];
	}
	return self;
}

- (void)layoutChannels:(NSArray *)channels {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:_cmd withObject:channels waitUntilDone:NO];
		return;
	}
	if ([[self gestureRecognizers] count] != 0) {
		for (id recog in [self gestureRecognizers]) {
			if ([recog isKindOfClass:[UITapGestureRecognizer class]]) [self removeGestureRecognizer:recog];
		}
	}
	for (id subview in [self subviews]) [subview removeFromSuperview];
	if (!channels) return;
	if ([channels count] == 0) {
		UILabel *nothingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 7.5, 320, 16)];
		nothingLabel.textAlignment = UITextAlignmentCenter;
		nothingLabel.text = @"You have no rooms for this server.. :(";
		nothingLabel.font = [UIFont systemFontOfSize:10];
		nothingLabel.backgroundColor = [UIColor clearColor];
		nothingLabel.textColor = [UIColor darkGrayColor];
		UITapGestureRecognizer *recog = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wantsToJoinChannel:)];
		[recog setNumberOfTapsRequired:2];
		[self addGestureRecognizer:recog];
		[recog release];
		[self addSubview:nothingLabel];
		[nothingLabel release];
		return;
	}
	NSMutableArray *_chans;
	BOOL reorder = !([[[((RCChannelBubble *)[channels objectAtIndex:0]) titleLabel] text] isEqualToString:@"IRC"]);
	if (reorder) {
		_chans = [[NSMutableArray alloc] initWithArray:channels];
		for (RCChannelBubble *bub in _chans) {
			if ([[bub titleLabel].text isEqualToString:@"IRC"]) {
				[_chans removeObject:bub];
				[_chans insertObject:bub atIndex:0];
				break;
			}
			else continue;
		}
		channels = _chans;
	}
	for (RCChannelBubble *bb in channels) {
		UIView *sub = nil;
		if ([[self subviews] count] != 0) sub = [[self subviews] objectAtIndex:[[self subviews] count]-1];
		[bb setFrame:CGRectMake((sub ? sub.frame.size.width+sub.frame.origin.x+2 : 10), 7, bb.frame.size.width, 20)];
		[self addSubview:bb];
	}
	if (reorder) [channels release];
	[self fixLayout];
}

- (void)fixLayout {
	if ([[self subviews] count] == 0) return;

	UIView *sub = nil;
	sub = [[self subviews] objectAtIndex:0];
	for (UIView *subv in [self subviews]) {
		if ([subv frame].origin.x > sub.frame.origin.x) sub = subv;
	}
	[self setContentSize:CGSizeMake((sub.frame.origin.x + sub.frame.size.width+10), self.frame.size.height)];
	[self setScrollEnabled:YES];
}

- (void)clearBG {
	[self setNeedsDisplay];
/* no to self
 when user rotates to landscape
 this is brillaint
 when they rotate back
 it doesn't draw.
 so derp. :P
 */
}

- (void)drawBG {
	[self setNeedsDisplay];
}

- (void)wantsToJoinChannel:(UIGestureRecognizer *)recog {
	NSLog(@"hai");
}

- (void)drawRect:(CGRect)rect {
	id appDelegate = [[UIApplication sharedApplication] delegate];
	UIViewController *vc = [appDelegate navigationController];
	if (UIInterfaceOrientationIsPortrait(vc.interfaceOrientation)) {
		@autoreleasepool {
			UIImage *bg = [UIImage imageNamed:@"0_chanbar"];
			[bg drawInRect:rect];
		}
	}
	else {
		[super drawRect:rect];
	}
}
@end
