//
//  RCInitialSetupView.m
//  Relay
//
//  Created by Max Shavrick on 6/21/13.
//

#import "RCInitialSetupView.h"

@implementation RCInitialSetupView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)prepareForDisplay {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(screenRect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, screenRect);
	UIView *v = [UIApp keyWindow];
    [v.layer renderInContext:ctx];
	CGContextSetGrayFillColor(ctx, 0.0, 0.5);
	CGContextFillRect(ctx, screenRect);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	newImage = [newImage imageWith3x3GaussianBlur];
	[self setBackgroundColor:[UIColor colorWithPatternImage:newImage]];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	CGRect drawingRect = CGRectMake(20, 40, 280, rect.size.height - 80);
    CGSize radiusSize = CGSizeMake(8, 8);
	CGRect outerRect = CGRectMake(drawingRect.origin.x - 1, drawingRect.origin.y - 1, drawingRect.size.width + 2, drawingRect.size.height + 2);
    UIBezierPath *outerPatb = [UIBezierPath bezierPathWithRoundedRect:outerRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:radiusSize];
	[UIColorFromRGB(0xE2E5E5) set];
    [outerPatb fill];
    CGRect innerRect = drawingRect;
    UIBezierPath *innerPath = [UIBezierPath bezierPathWithRoundedRect:innerRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:radiusSize];
	[UIColorFromRGB(0xE7E9EB) set];
    [innerPath fill];
	UIImage *title = [UIImage imageNamed:@"imabadperson"];
	[title drawInRect:CGRectMake((rect.size.width/2) - (title.size.width/2), 60, title.size.width, title.size.height)];
}

@end
