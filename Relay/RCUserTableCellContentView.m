//
//  RCUserTableCellContentView.m
//  Relay
//
//  Created by Max Shavrick on 6/21/13.
//

#import "RCUserTableCellContentView.h"

@implementation RCUserTableCellContentView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	fakeSelected = YES;
	[self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	fakeSelected = NO;
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	fakeSelected = NO;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	RCUserTableCell *cc;
	UIView *v = [self superview];
	if ([[self superview] isKindOfClass:[RCUserTableCell class]]) {
		cc = (RCUserTableCell *)v;
	}
	else {
		cc = (RCUserTableCell *)[v superview];
	}
	if ([cc isWhois]) {
		[UIColorFromRGB(0xEEF2F4) set];
		UIRectFill(rect);
		[UIColorFromRGB(0x4c4c51) set];
		[[((RCPMChannel *)[cc channel]) chanInfos] drawInRect:CGRectMake(2, 2, rect.size.width - 52, 50) withFont:[UIFont systemFontOfSize:12]];
	}
	else {
		UIImage *bg = [UIImage imageNamed:@"0_strangebg"];
		[bg drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height+1) blendMode:kCGBlendModeNormal alpha:(fakeSelected ? 0.9 : 1.0)];
	}
	if (![cc isLast]) {
		UIImage *ul = [UIImage imageNamed:@"0_usl"];
		[ul drawAsPatternInRect:CGRectMake(0, 43, rect.size.width, 1)];
	}
}

@end
