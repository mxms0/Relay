//
//  RCNetworkHeaderButton.m
//  Relay
//
//  Created by Max Shavrick on 10/21/12.
//

#import "RCNetworkHeaderButton.h"
#import "RCnetwork.h"
#import "RCChatController.h"

@implementation RCNetworkHeaderButton
@synthesize section, showsGlow;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self setOpaque:YES];
		coggearwhat = [[UIButton alloc] initWithFrame:CGRectMake(3, 0, 34, 44)];
		[coggearwhat addTarget:[RCChatController sharedController] action:@selector(showNetworkOptions:) forControlEvents:UIControlEventTouchUpInside];
		[coggearwhat setImage:[UIImage imageNamed:@"settingsbutton"] forState:UIControlStateNormal];
		[self addSubview:coggearwhat];
		[coggearwhat release];
	}
	return self;
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	[self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	_pSelected = YES;
	[self setNeedsDisplay];
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	_pSelected = NO;
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	_pSelected = NO;
	[self setNeedsDisplay];
	[super touchesEnded:touches withEvent:event];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	UIColor *textColor = UIColorFromRGB(0xcccccc);
	if ([net expanded] || _pSelected) {
		if ([net isConnected]) {
			textColor = UIColorFromRGB(0xcccccc);
		}
		else {
			textColor = UIColorFromRGB(0xcccccc);
		}
		[UIColorFromRGB(0x353538) set];
		UIRectFill(rect);
		UIImage *arrow = [UIImage imageNamed:@"0_arrowd"];
		[arrow drawInRect:CGRectMake(232,14, 16, 16)];
	}
	else {
		[UIColorFromRGB(0x353538) set];
		UIRectFill(rect);
		UIImage *ul = [UIImage imageNamed:@"0_underline"];
		[ul drawAsPatternInRect:CGRectMake(0, 42, rect.size.width, 2)];
		UIImage *arrow = [UIImage imageNamed:@"0_arrowr"];
		[arrow drawInRect:CGRectMake(232, 14, 16, 16)];
		if ([net isConnected]) {
			textColor = [UIColor whiteColor];
		}
		if (showsGlow) {
		}
	}
	NSString *text = [net _description];
	NSString *detail = [net server];
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetShadowWithColor(ctx, CGSizeMake(0, -1), 0, [UIColor blackColor].CGColor);
	CGContextSetFillColorWithColor(ctx, textColor.CGColor);
	CGContextScaleCTM(ctx, [[UIScreen mainScreen] scale], [[UIScreen mainScreen] scale]);
	[text drawInRect:CGRectMake(20, 1, 200, 40) withFont:[UIFont boldSystemFontOfSize:9] lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
	[detail drawInRect:CGRectMake(20, 12, 200, 30) withFont:[UIFont systemFontOfSize:5.5]];
}

- (void)setNetwork:(RCNetwork *)_net {
	[net release];
	net = [_net retain];
	_pSelected = [net expanded];
}

- (RCNetwork *)net {
	return net; // please excuse me for this mess.
}

- (void)dealloc {
	[net release];
	[super dealloc];
}

@end
