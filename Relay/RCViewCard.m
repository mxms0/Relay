//
//  RCViewCard.m
//  Relay
//
//  Created by Max Shavrick on 6/16/13.
//

#import "RCViewCard.h"
#import "RCChatsListViewCard.h"
#import "RCTopViewCard.h"

@implementation RCViewCard
@synthesize navigationBar;
@class RCChatsListViewCard;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		if (![self isKindOfClass:[RCChatsListViewCard class]]) {
			navigationBar = [[RCChatNavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
			[self addSubview:navigationBar];
			navigationBar.layer.zPosition = 100000;
			[navigationBar release];
			[self setBackgroundColor:[UIColor clearColor]];
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
			[self.layer insertSublayer:bg atIndex:1];
			[bg release];
		}
		else if (![self isKindOfClass:[RCTopViewCard class]]) {
			
			// no buttons shows up
			// wat
			// k
			RCBarButtonItem *bs = [[RCBarButtonItem alloc] init];
			[bs setImage:[UIImage imageNamed:@"0_listrbtn"] forState:UIControlStateNormal];
			[bs setImage:[UIImage imageNamed:@"0_listrbtn_pressed"] forState:UIControlStateHighlighted];
			[bs setFrame:CGRectMake(2, 2, 50, 45)];
			[bs setHidden:NO];
			[bs.layer setZPosition:100001];
			[bs setBackgroundColor:[UIColor blackColor]];
			[navigationBar addSubview:bs];
		}
    }
    return self;
}

- (void)setCenter:(CGPoint)ct {
	[super setCenter:ct];
	[self findShadowAndDoStuffToIt];
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
}

- (void)findShadowAndDoStuffToIt {
	BOOL shouldBeVisible = (self.frame.origin.x >= 0);
	for (CALayer *sub in [self.layer sublayers]) {
		if ([[sub name] isEqualToString:@"0_fuckingshadow"]) {
			[sub setFrame:CGRectMake(sub.frame.origin.x, sub.frame.origin.y, sub.frame.size.width, self.frame.size.height)];
			if (self.frame.origin.x >= self.frame.size.width) {
				[sub setHidden:YES];
			}
			else {
				[sub setHidden:!shouldBeVisible];
			}
			break;
		}
	}
}

- (void)drawRect:(CGRect)rect {
	[UIColorFromRGB(0xDDE0E5) set];
	UIRectFill(CGRectMake(0, 10, rect.size.width, rect.size.height));
}

@end
