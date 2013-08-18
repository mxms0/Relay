//
//  RCActionSheetButton.m
//  Relay
//
//  Created by Max Shavrick on 8/16/13.
//

#import "RCActionSheetButton.h"

@implementation RCActionSheetButton
@synthesize type;

- (id)initWithFrame:(CGRect)frame type:(RCActionSheetButtonType)typ {
	if ((self = [super initWithFrame:frame])) {
		type = typ;
		NSString *imageName = @"as_gray";
		if (typ == RCActionSheetButtonTypeCancel)
			imageName = @"as_blue";
		else if (typ == RCActionSheetButtonTypeDestructive)
			imageName = @"as_red";
		[self setBackgroundImage:[[[RCSchemeManager sharedInstance] imageNamed:imageName] stretchableImageWithLeftCapWidth:8 topCapHeight:8] forState:UIControlStateNormal];
		[self setBackgroundImage:[[[RCSchemeManager sharedInstance] imageNamed:[imageName stringByAppendingString:@"_press"]] stretchableImageWithLeftCapWidth:8 topCapHeight:8] forState:UIControlStateHighlighted];
		[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[[self titleLabel] setFont:[UIFont boldSystemFontOfSize:17]];
		[[self titleLabel] setShadowOffset:CGSizeMake(0, -1)];
		[[self titleLabel] setShadowColor:[UIColor blackColor]];
	}
    return self;
}


@end
