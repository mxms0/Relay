//
//  RCNickSuggestionView.m
//  Relay
//
//  Created by Max Shavrick on 1/6/13.
//

#import "RCNickSuggestionView.h"

@implementation RCNickSuggestionView
@synthesize displayPoint;

static id _nInstance = nil;
+ (id)sharedInstance {
	if (!_nInstance) _nInstance = [[self alloc] init];
	return _nInstance;
}

- (void)showAtPoint:(CGPoint)p withNames:(NSArray *)names {
	for (UIView *v in [self subviews])
		[v removeFromSuperview];
	int maxWidth = 300;
	int cx = 5;
	for (NSString *n in names) {
		int len = (int)[n sizeWithFont:[UIFont boldSystemFontOfSize:9]].width;
		if (5 + (cx + len) > maxWidth) break;
		UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
		[b setTitle:n forState:UIControlStateNormal];
		[b setBackgroundColor:[UIColor blackColor]];
		[[b titleLabel] setFont:[UIFont boldSystemFontOfSize:9]];
		[b setFrame:CGRectMake(cx, 0, (float)len, self.frame.size.height)];
		[self addSubview:b];
		cx += (len + 5);
	}
	[self setFrame:CGRectMake(p.x, p.y, self.frame.size.width, self.frame.size.height)];
	self.alpha = 1;
}

- (void)dismiss {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.15];
	self.alpha = 0;
	[UIView commitAnimations];
	displayPoint = CGPointZero;
	for (UIView *v in [self subviews])
		[v removeFromSuperview];
}

@end
