//
//  RCNickSuggestionView.m
//  Relay
//
//  Created by Max Shavrick on 1/6/13.
//

#import "RCNickSuggestionView.h"
#import "RCChatController.h"

@implementation RCNickSuggestionView
@synthesize displayPoint, range, inputField;

static id _nInstance = nil;
+ (id)sharedInstance {
	if (!_nInstance) _nInstance = [[self alloc] init];
	return _nInstance;
}

- (id)init {
	if ((self = [super init])) {
		[self setFrame:CGRectMake(10, 0, 280, 30)];
		[self setBackgroundColor:[UIColor clearColor]];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	UIImage *img = [[UIImage imageNamed:@"0_sugbg"] stretchableImageWithLeftCapWidth:8 topCapHeight:6];
	[img drawInRect:CGRectMake(0, 0, 280, 30)];
}

- (void)showAtPoint:(CGPoint)p withNames:(NSArray *)names {
	for (UIView *v in [self subviews])
		[v removeFromSuperview];
	int maxWidth = 300;
	int cx = 4;
	for (NSString *n in names) {
		int len = (int)[n sizeWithFont:[UIFont boldSystemFontOfSize:11]].width;
		if (5 + (cx + len) > maxWidth) break;
		RCNickButton *b = [[RCNickButton alloc] initWithFrame:CGRectMake(cx, 0, (float)len+14, self.frame.size.height)];
		[b addTarget:self action:@selector(nickSelected:) forControlEvents:UIControlEventTouchUpInside];
		[b setTitle:n forState:UIControlStateNormal];
		[self addSubview:b];
		[b release];
		cx += b.frame.size.width;
	}
	[self setFrame:CGRectMake(p.x, p.y, self.frame.size.width, self.frame.size.height)];
	self.alpha = 1;
}

- (void)nickSelected:(UIButton *)bt {
	if (inputField) {
		[inputField setText:[[inputField text] stringByReplacingCharactersInRange:range withString:[[bt titleLabel] text]]];
		[self dismiss];
		[self setRange:NSMakeRange(0, 0) inputField:nil];
	}
}

- (void)setRange:(NSRange)rr inputField:(UITextField *)ff {
	[self setRange:rr];
	[self setInputField:ff];
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
