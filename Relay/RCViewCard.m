//
//  RCViewCard.m
//  Relay
//
//  Created by Max Shavrick on 6/16/13.
//

#import "RCViewCard.h"

@implementation RCViewCard
@synthesize needsBlueBackground, isBottomView, navigationBar;

- (id)initWithFrame:(CGRect)frame isBottomView:(BOOL)bb {
	if ((self = [super initWithFrame:frame])) {
		[self setIsBottomView:bb];
		navigationBar = [[RCChatNavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		[self addSubview:navigationBar];
		[navigationBar release];
		[self setBackgroundColor:[UIColor clearColor]];
		if (!bb) {
			[self setOpaque:YES];
			CALayer *shdw = [[CALayer alloc] init];
			[shdw setName:@"0_fuckingshadow"];
			UIImage *mfs = [UIImage imageNamed:@"0_hzshdw"];
			[shdw setContents:(id)mfs.CGImage];
			[shdw setShouldRasterize:YES];
			[shdw setHidden:YES];
			[shdw setFrame:CGRectMake(-mfs.size.width+3, 0, mfs.size.width, self.frame.size.height)];
			[self.layer insertSublayer:shdw atIndex:0];
			[shdw release];
			CALayer *bg = [[CALayer alloc] init];
			[bg setBackgroundColor:UIColorFromRGB(0xDDE0E5).CGColor];
			[bg setShouldRasterize:YES];
			[bg setFrame:CGRectMake(0, 10, frame.size.width, frame.size.height)];
			[self.layer insertSublayer:bg atIndex:[self.layer.sublayers count]-1];
			[bg release];
		}
    }
    return self;
}

- (void)setCenter:(CGPoint)ct {
	[super setCenter:ct];
	[self findShadowAndDoStuffToIt];
}

- (void)findShadowAndDoStuffToIt {
	BOOL shouldBeVisible = ((self.frame.origin.x >= 0 && (self.frame.origin.x <= self.frame.size.width)));
	for (CALayer *sub in [self.layer sublayers]) {
		if ([[sub name] isEqualToString:@"0_fuckingshadow"]) {
			[sub setFrame:CGRectMake(sub.frame.origin.x, sub.frame.origin.y, sub.frame.size.width, self.frame.size.height)];
			[sub setHidden:!shouldBeVisible];
			break;
		}
	}
}

- (void)drawRect:(CGRect)rect {
	if (needsBlueBackground) {
		
	}
	else {
		[UIColorFromRGB(0xDDE0E5) set];
	}
	UIRectFill(CGRectMake(0, 10, rect.size.width, rect.size.height));
}

@end
