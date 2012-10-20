//
//  RCNavigationBar.m
//  Relay
//
//  Created by Max Shavrick on 2/25/12.
//

#import "RCNavigationBar.h"
#import "RCNavigator.h"

@implementation RCNavigationBar

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self.layer setMasksToBounds:NO];
		[self setClipsToBounds:NO];
		RCShadowLayer *shadow = [[RCShadowLayer alloc] init];
		UIImage *shd = [UIImage imageNamed:@"0_r_shadow"];
		shadow.contents = (id)shd.CGImage;
		[shadow setFrame:CGRectMake(0, self.frame.size.height+44, self.frame.size.width, 15)];
		[shadow setOpacity:0.3];
		[shadow setShouldRasterize:YES];
        shadow.zPosition = 100;
		[self.layer addSublayer:shadow];
		[shadow release];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	float y = self.frame.size.height;
	if (self.frame.size.width == 320.0f) {
		y += 44;
	}
	for (CALayer *ll in [self.layer sublayers]) {
		if ([ll isKindOfClass:[RCShadowLayer class]]) {
			[ll setFrame:CGRectMake(0, y, self.frame.size.width, 15)];
		}
	}
}

@end
