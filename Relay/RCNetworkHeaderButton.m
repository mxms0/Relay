//
//  RCNetworkHeaderButton.m
//  Relay
//
//  Created by Max Shavrick on 10/21/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCNetworkHeaderButton.h"
#import "RCnetwork.h"

@implementation RCNetworkHeaderButton
@synthesize section;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_pSelected = NO;
		net = nil;
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
	
	if ([net expanded] || _pSelected) {
		UIImage *img = [UIImage imageNamed:@"0_cell_selec"];
		[img drawAsPatternInRect:CGRectMake(0, 0, rect.size.width, 44)];
		UIImage *arrow = [UIImage imageNamed:@"0_arrowd"];
		[arrow drawInRect:CGRectMake(232,15, 16, 16)];
	}
	else {
		UIImage *ul = [UIImage imageNamed:@"0_underline"];
		[ul drawAsPatternInRect:CGRectMake(0, 42, rect.size.width, 2)];
	}
	NSString *text = [net _description];
	NSString *detail = [net server];
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0, [UIColor blackColor].CGColor);
	CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
	CGContextScaleCTM(ctx, [[UIScreen mainScreen] scale], [[UIScreen mainScreen] scale]);
	[text drawInRect:CGRectMake(5, 1, 200, 40) withFont:[UIFont boldSystemFontOfSize:9] lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentLeft];
	CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.909 alpha:0.800].CGColor);
	[detail drawInRect:CGRectMake(5, 13, 200, 30) withFont:[UIFont systemFontOfSize:5.5]];
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
