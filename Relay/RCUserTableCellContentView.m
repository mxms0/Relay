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
		[self setBackgroundColor:[UIColor colorWithRed:53/255.0f green:53/255.0f blue:56/255.0f alpha:1.0f]];
        [[UIColor colorWithRed:35/255.0f green:35/255.0f blue:36/255.0f alpha:1.0f] set];
        UIRectFill(CGRectMake(0, rect.size.height - 2, rect.size.width, 0.5));
        [[UIColor colorWithRed:73/255.0f green:73/255.0f blue:76/255.0f alpha:1.0f] set];
        UIRectFill(CGRectMake(0, rect.size.height - 1, rect.size.width, 1));
	}
}

@end
