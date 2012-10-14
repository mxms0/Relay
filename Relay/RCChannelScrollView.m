//
//  RCRoomScrollView.m
//  Relay
//
//  Created by Max Shavrick on 2/25/12.
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
		[self setShowsHorizontalScrollIndicator:NO];
        [self setScrollsToTop:NO];
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
				[bub retain];
				[_chans removeObject:bub];
				[_chans insertObject:bub atIndex:0];
				[bub release];
				break;
			}
			else continue;
		}
		channels = _chans;
	}
	RCChannelBubble *pr = nil;
	for (RCChannelBubble *bb in channels) {
		[bb setFrame:CGRectMake((pr ? pr.frame.size.width+pr.frame.origin.x : 10), (self.frame.size.height/2)-(bb.frame.size.height/2), bb.frame.size.width, 32)];
		[self addSubview:bb];
        [bb fixColors];
		pr = bb;
	}
	if (reorder) [channels release];
	[self fixLayout];
}

- (void)fixLayout {
	if ([[self subviews] count] == 0) return;
	UIView *sub = [[self subviews] objectAtIndex:0];
	for (UIView *subv in [self subviews]) {
		if ([subv frame].origin.x > sub.frame.origin.x) sub = subv;
	}
	[self setContentSize:CGSizeMake((sub.frame.origin.x + sub.frame.size.width+10), self.frame.size.height)];
	[self setScrollEnabled:YES];
}

- (void)clearBG {
	[self setNeedsDisplay];
}

- (void)drawBG {
	[self setNeedsDisplay];
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
