//
//  RCActionSheetButtonView.m
//  Relay
//
//  Created by Max Shavrick on 8/17/13.
//

#import "RCActionSheetButtonView.h"

@implementation RCActionSheetButtonView

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[[UIColor colorWithRed:43/255.0f green:43/255.0f blue:46/255.0f alpha:1.0f] set];
	UIRectFill(CGRectMake(0, 0, rect.size.width, rect.size.height));
	UIImage *img = [[RCSchemeManager sharedInstance] imageNamed:@"as_top_gloss"];
	[img drawInRect:CGRectMake(0, 0, rect.size.width, img.size.height)];
}

@end
