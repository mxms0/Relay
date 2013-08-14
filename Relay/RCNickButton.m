//
//  RCNickButton.m
//  Relay
//
//  Created by Max Shavrick on 1/10/13.
//

#import "RCNickButton.h"

@implementation RCNickButton

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self setTitleColor:UIColorFromRGB(0x498ADB) forState:UIControlStateNormal];
		[self setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[[self titleLabel] setShadowOffset:CGSizeMake(0, 1)];
		[[self titleLabel] setFont:[UIFont boldSystemFontOfSize:11]];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[UIColorFromRGB(0x91979b) set];
	UIRectFill(CGRectMake(self.frame.size.width-1, 1, 1, 29));
}

@end
