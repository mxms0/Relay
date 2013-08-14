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
		net = nil;
		[self setOpaque:YES];
		coggearwhat = [[UIButton alloc] initWithFrame:CGRectMake(194, 0, 34, 44)];
		[coggearwhat addTarget:[RCChatController sharedController] action:@selector(showNetworkOptions:) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:coggearwhat];
		[coggearwhat release];
	}
	return self;
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	if (selected) {
		[coggearwhat setImage:[UIImage imageNamed:@"0_COGGEARWHAT_pres"] forState:UIControlStateNormal];
	}
	else {
		[coggearwhat setImage:[UIImage imageNamed:@"0_COGGEARWHAT"] forState:UIControlStateNormal];
	}
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
	UIColor *textColor = [UIColor colorWithRed:0.409 green:0.434 blue:0.523 alpha:1.000];
	UIColor *subTextColor = UIColorFromRGB(0x556280);
	if ([net expanded] || _pSelected) {
		if ([net isConnected]) {
			subTextColor = UIColorFromRGB(0xb5bbcc);
			textColor = UIColorFromRGB(0xEdeff5);
		}
		else {
			subTextColor = UIColorFromRGB(0xaaabb0);
			textColor = UIColorFromRGB(0xd5d7dd);
		}
		UIImage *bg = [UIImage imageNamed:@"0_selch"];
		[bg drawInRect:CGRectMake(0, 0, rect.size.width, 44)];
		UIImage *arrow = [UIImage imageNamed:@"0_arrowd"];
		[arrow drawInRect:CGRectMake(232,14, 16, 16)];
	}
	else {
		[UIColorFromRGB(0x29324A) set];
		UIRectFill(rect);
		UIImage *ul = [UIImage imageNamed:@"0_underline"];
		[ul drawAsPatternInRect:CGRectMake(0, 42, rect.size.width, 2)];
		UIImage *arrow = [UIImage imageNamed:@"0_arrowr"];
		[arrow drawInRect:CGRectMake(232, 14, 16, 16)];
		if ([net isConnected]) {
			textColor = [UIColor whiteColor];
		}
		if (showsGlow) {
			UIImage *glow = [UIImage imageNamed:@"0_sglow"];
			[glow drawInRect:CGRectMake(0, 0, glow.size.width, glow.size.height)];
		}
	}
	NSString *text = [net _description];
	NSString *detail = [net server];
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(ctx, textColor.CGColor);
	CGContextScaleCTM(ctx, [[UIScreen mainScreen] scale], [[UIScreen mainScreen] scale]);
	[text drawInRect:CGRectMake(5, 1, 200, 40) withFont:[UIFont boldSystemFontOfSize:9] lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
	CGContextSetFillColorWithColor(ctx, subTextColor.CGColor);
	[detail drawInRect:CGRectMake(5, 13, 200, 30) withFont:[UIFont systemFontOfSize:5.5]];
}

- (void)setNetwork:(RCNetwork *)_net {
	[net release];
	net = [_net retain];
	_pSelected = [net expanded];
	NSString *img = @"0_COGGEARWHAT";
	if (_pSelected)
		img = @"0_COGGEARWHAT_pres";
	[coggearwhat setImage:[UIImage imageNamed:img] forState:UIControlStateNormal];
}

- (RCNetwork *)net {
	return net; // please excuse me for this mess.
}

- (void)dealloc {
	[net release];
	[super dealloc];
}

@end
