//
//  RCSearchBar.m
//  Relay
//
//  Created by Max Shavrick on 8/15/13.
//

#import "RCSearchBar.h"

@implementation RCSearchBar

- (void)layoutSubviews {
	[super layoutSubviews];
	for (UIView *subv in [self subviews]) {
		if ([subv isKindOfClass:NSClassFromString(@"UISearchBarTextField")]) {
			for (UIView *esubv in [[[subv subviews] copy] autorelease]) {
				if ([esubv isKindOfClass:NSClassFromString(@"UITextFieldBorderView")]) {
					[esubv removeFromSuperview];
					break;
				}
			}
		}
	}
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	UIImage *textField = [UIImage imageNamed:@"maintextfield"];
	[textField drawInRect:rect];
}

@end
