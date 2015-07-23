//
//  RCChatPanel.m
//  Relay
//
//  Created by Max Shavrick on 2/17/12.
//

#import "RAChatView.h"
#import "RCChannel.h"

@implementation RAChatView
@synthesize channel;

- (id)init {
	if ((self = [super initWithFrame:CGRectZero style:UITableViewStylePlain])) {
		self.opaque = NO;
		[self setBackgroundColor:[UIColor clearColor]];
//		[[self scrollView] setShowsVerticalScrollIndicator:YES]; // Aehmlo wants it. We'll see.
		UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
		v.backgroundColor = [UIColor clearColor];
		[self setTableFooterView:v];
		[v release];
		[self setSeparatorInset:UIEdgeInsetsZero];
	}
	return self;
}

- (void)switchToChannel:(RCChannel *)_channel {
	[self setSeparatorInset:UIEdgeInsetsZero];
	self.channel = _channel;
	[pool release];
	pool = [[self.channel pool] retain];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	return YES;
}

- (void)scrollToTop {
	[self setContentOffset:CGPointZero animated:YES];
}

- (void)scrollToBottom {
	[self scrollToBottomAnimated:YES];
}

- (void)scrollToBottomAnimated:(BOOL)anim {
	[self scrollRectToVisible:CGRectMake(0, self.contentSize.height - self.bounds.size.height, self.bounds.size.width, self.bounds.size.height) animated:anim];
}

- (void)dealloc {
	[pool release];
	[super dealloc];
}

@end
