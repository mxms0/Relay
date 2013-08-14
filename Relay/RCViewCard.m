//
//  RCViewCard.m
//  Relay
//
//  Created by Max Shavrick on 6/16/13.
//

#import "RCViewCard.h"
#import "RCChatsListViewCard.h"
#import "RCTopViewCard.h"
#import "RCChatController.h"
#import "RCChannelListViewCard.h"

@implementation RCViewCard
@synthesize navigationBar;
@class RCChatsListViewCard;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self setOpaque:YES];
		[self setExclusiveTouch:YES];
		if (![self isKindOfClass:[RCChatsListViewCard class]]) {
			navigationBar = [[RCChatNavigationBar alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 44)];
			[self addSubview:navigationBar];
			navigationBar.layer.zPosition = 100000;
			[navigationBar release];
			[self setBackgroundColor:[UIColor clearColor]];
			CALayer *shdw = [[CALayer alloc] init];
			[shdw setName:@"0_fuckingshadow"];
			UIImage *mfs = [UIImage imageNamed:@"0_hzshdw"];
			[shdw setContents:(id)mfs.CGImage];
			[shdw setShouldRasterize:YES];
			[shdw setHidden:YES];
			[shdw setOpacity:0.5];
			[shdw setFrame:CGRectMake(-mfs.size.width+3, 0, mfs.size.width, self.frame.size.height)];
			[self.layer insertSublayer:shdw atIndex:0];
			[shdw release];
			CALayer *bg = [[CALayer alloc] init];
			[bg setBackgroundColor:UIColorFromRGB(0x353538).CGColor];
			[bg setShouldRasterize:YES];
			[bg setFrame:CGRectMake(0, 10, frame.size.height+44, frame.size.height)];
			[self.layer insertSublayer:bg atIndex:1];
			[bg release];
		}
		if ([NSStringFromClass([self class]) isEqualToString:@"RCViewCard"]) {
			RCBarButtonItem *bs = [[RCBarButtonItem alloc] init];
			[bs setImage:[UIImage imageNamed:@"mainhamburger"] forState:UIControlStateNormal];
			[bs setFrame:CGRectMake(1, 0, 50, 45)];
			[bs setTag:RCChannelListButtonTag];
			[bs addTarget:[RCChatController sharedController] action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
			[navigationBar addSubview:bs];
			[bs release];
			RCBarButtonItem *cs = [[RCBarButtonItem alloc] init];
			[cs setImage:[UIImage imageNamed:@"userlistbutton"] forState:UIControlStateNormal];
			[cs setFrame:CGRectMake(frame.size.width - 50, 0, 50, 45)];
			[cs setTag:RCUserListButtonTag];
			[cs addTarget:[RCChatController sharedController] action:@selector(pushUserListWithDefaultDuration) forControlEvents:UIControlEventTouchUpInside];
			[navigationBar addSubview:cs];
			[cs release];
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
	navigationBar.frame = CGRectMake(navigationBar.frame.origin.x,navigationBar.frame.origin.y, frame.size.width, navigationBar.frame.size.height);
	[navigationBar setNeedsDisplay];
}

- (void)setLeftBarButtonItemEnabled:(BOOL)en {
	for (RCBarButtonItem *bv in [self.navigationBar subviews]) {
		if ([bv tag] == RCChannelListButtonTag) {
			[bv setEnabled:en];
			break;
		}
	}
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
	[super drawRect:rect];
	[UIColorFromRGB(0x353538) set];
	UIRectFill(CGRectMake(0, 10, rect.size.width, rect.size.height));
}

@end
