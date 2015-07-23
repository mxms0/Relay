//
//  RANavigationBarButton.m
//  Relay IRC
//
//  Created by Max Shavrick on 7/22/15.
//  Copyright (c) 2015 Mxms. All rights reserved.
//

#import "RANavigationBarButton.h"

@implementation RANavigationBarButton

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	_isBeingTouched = YES;
	[self setNeedsDisplay];
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	_isBeingTouched = NO;
	[self setNeedsDisplay];
	[super touchesEnded:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	_isBeingTouched = NO;
	[self setNeedsDisplay];
	[super touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	_isBeingTouched = NO;
	[self setNeedsDisplay];
	[super touchesCancelled:touches withEvent:event];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	if (_isBeingTouched) {
		[[UIColor colorWithWhite:0.0 alpha:.1] set];
		
		UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, rect.size.width, rect.size.height - 2) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(4.0f, 4.0f)];
		
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextBeginTransparencyLayer(context, NULL);
		CGContextSetShadowWithColor(context, CGSizeMake(0, 2.0), 1.0f, [UIColor colorWithWhite:0 alpha:.1].CGColor);
		CGContextSetBlendMode(context, kCGBlendModeSourceOut);
		CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0 alpha:.3].CGColor);
		CGContextAddPath(context, path.CGPath);
		CGContextFillPath(context);
		CGContextEndTransparencyLayer(context);
		
		[path fill];
	}
}

@end
