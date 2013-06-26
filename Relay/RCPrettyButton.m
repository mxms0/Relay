//
//  RCPrettyButton.m
//  Relay
//
//  Created by Max Shavrick on 1/15/13.
//

#import "RCPrettyButton.h"

@implementation RCPrettyButton

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self setBackgroundImage:[[UIImage imageNamed:@"0_pbbg"] stretchableImageWithLeftCapWidth:8 topCapHeight:8] forState:UIControlStateNormal];
		[self setBackgroundImage:[[UIImage imageNamed:@"0_pbbg_p"] stretchableImageWithLeftCapWidth:8 topCapHeight:8] forState:UIControlStateHighlighted];
		[self setTitleColor:UIColorFromRGB(0x3E3F3F) forState:UIControlStateNormal];
		[self setTitleColor:UIColorFromRGB(0x323333) forState:UIControlStateHighlighted];
		[[self titleLabel] setFont:[UIFont boldSystemFontOfSize:14]];
	}
    return self;
}

@end
