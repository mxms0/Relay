//
//  RCBaseNavigationViewController.m
//  Relay
//
//  Created by Max Shavrick on 10/28/12.
//

#import "RCBaseNavigationViewController.h"

@implementation RCBaseNavigationViewController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
	if ((self = [super initWithNavigationBarClass:[RCChatNavigationBar class] toolbarClass:[UIToolbar class]])) {
		[self setViewControllers:[NSArray arrayWithObject:rootViewController] animated:NO];
	}
	return self;
}

- (void)setFrame:(CGRect)frame {
	[self.view setFrame:frame];
}

@end
