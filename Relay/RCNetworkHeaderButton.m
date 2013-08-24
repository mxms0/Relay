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
		coggearwhat = [[UIButton alloc] initWithFrame:CGRectMake(3, 1, 34, 44)];
		[coggearwhat addTarget:[RCChatController sharedController] action:@selector(showNetworkOptions:) forControlEvents:UIControlEventTouchUpInside];
		[coggearwhat setImage:[[RCSchemeManager sharedInstance] imageNamed:@"iconcog"] forState:UIControlStateNormal];
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
	UIColor *shadowColor = [UIColor blackColor];
	UIColor *subtitleColor = UIColorFromRGB(0x999999);
	CGSize shadowSize = CGSizeMake(0, -1);
	UIImage *bg = nil;
	BOOL isSelected = ([net expanded] || _pSelected);
	if ([[RCSchemeManager sharedInstance] isDark]) {
		if ([net isConnected]) {
			
		}
		else {
			
		}
	}
	else {
		if ([net isConnected]) {

		}
		else {
			
		}
		shadowColor = [UIColor whiteColor];
		textColor = UIColorFromRGB(0x666666);
		shadowSize = CGSizeZero;
	}
	if (isSelected) {
		bg = [[RCSchemeManager sharedInstance] imageNamed:@"net_selectedbg"];
	}
	else {
		bg = [[RCSchemeManager sharedInstance] imageNamed:@"net_deselectedbg"];
	}
	
	[bg drawInRect:rect];
	if (isSelected) {
		[UIColorFromRGB(0x161618) set];
		UIRectFill(CGRectMake(0, rect.size.height-.5, rect.size.width, .5));
		[UIColorFromRGB(0x2A2E37) set];
	}
	NSString *text = [net _description];
	NSString *detail = [net server];
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetShadowWithColor(ctx, shadowSize, 0, shadowColor.CGColor);
	CGContextSetFillColorWithColor(ctx, textColor.CGColor);
	CGContextScaleCTM(ctx, [[UIScreen mainScreen] scale], [[UIScreen mainScreen] scale]);
	[text drawInRect:CGRectMake(19, 1, 200, 40) withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:9] lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentLeft];
	CGContextSetFillColorWithColor(ctx, subtitleColor.CGColor);
	[detail drawInRect:CGRectMake(19, 12, 200, 30) withFont:[UIFont fontWithName:@"HelveticaNeue" size:5.5]];
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
