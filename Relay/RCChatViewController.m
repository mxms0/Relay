//
//  RCChatViewController.m
//  Relay
//
//  Created by Max Shavrick on 10/28/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChatViewController.h"

@implementation RCChatViewController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
	if ((self = [super initWithRootViewController:rootViewController])) {
		[self.view setOpaque:YES];
		CALayer *shdw = [[CALayer alloc] init];
		[shdw setName:@"0_fuckingshadow"];
		UIImage *mfs = [UIImage imageNamed:@"0_hzshdw"];
		[shdw setContents:(id)mfs.CGImage];
		[shdw setShouldRasterize:YES];
		[shdw setFrame:CGRectMake(-mfs.size.width+3, 0, mfs.size.width, self.view.frame.size.height)];
		[self.view.layer insertSublayer:shdw atIndex:0];
		[shdw release];
		UIButton *listr = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 31)];
		[listr setImage:[UIImage imageNamed:@"0_listrbtn"] forState:UIControlStateNormal];
		[listr setImage:[UIImage imageNamed:@"0_listrbtn_pressed"] forState:UIControlStateHighlighted];
		[listr addTarget:[RCChatController sharedController] action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
		[listr setExclusiveTouch:YES];
		UIBarButtonItem *fs = [[UIBarButtonItem alloc] initWithCustomView:listr];
		[[[self topViewController] navigationItem] setLeftBarButtonItem:fs];
		[fs release];
		[listr release];
		UIButton *ppls = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 41, 31)];
		[ppls setImage:[UIImage imageNamed:@"0_pple"] forState:UIControlStateNormal];
		[ppls setImage:[UIImage imageNamed:@"0_pple_press"] forState:UIControlStateHighlighted];
		[ppls setExclusiveTouch:YES];
		[ppls addTarget:[RCChatController sharedController] action:@selector(pushUserListWithDefaultDuration) forControlEvents:UIControlEventTouchUpInside];
		UIBarButtonItem *bs = [[UIBarButtonItem alloc] initWithCustomView:ppls];
		[[[self topViewController] navigationItem] setRightBarButtonItem:bs];
		[bs release];
		[ppls release];
		UIPanGestureRecognizer *swip = [[UIPanGestureRecognizer alloc] initWithTarget:[RCChatController sharedController] action:@selector(userSwiped:)];
		[[[[self topViewController] navigationController] navigationBar] addGestureRecognizer:swip];
		[[[[self topViewController] navigationController] navigationBar] setIsMain:YES];
		[swip release];
	}
	return self;
}

- (void)setFrame:(CGRect)rect {
	for (CALayer *sub in [self.view.layer sublayers]) {
		if ([[sub name] isEqualToString:@"0_fuckingshadow"]) {
			[sub setFrame:CGRectMake(sub.frame.origin.x, sub.frame.origin.y, sub.frame.size.width, self.view.frame.size.height)];
			[sub setHidden:(rect.origin.x == 0)];
			break;
		}
	}
	self.view.frame = rect;
}

- (void)setCenter:(CGPoint)cc {
	self.view.center = cc;
	for (CALayer *sub in [self.view.layer sublayers]) {
		if ([[sub name] isEqualToString:@"0_fuckingshadow"]) {
			[sub setFrame:CGRectMake(sub.frame.origin.x, sub.frame.origin.y, sub.frame.size.width, self.view.frame.size.height)];
			[sub setHidden:(self.view.frame.origin.x == 0)];
			break;
		}
	}
}

- (void)viewDidLoad {
    [super viewDidLoad];
	CALayer *bg = [[CALayer alloc] init];
	[bg setContents:(id)([UIImage imageNamed:@"0_cbg"].CGImage)];
	[bg setFrame:CGRectMake(0, 0, 320, 568)];
	[bg setShouldRasterize:YES];
	[self.view.layer insertSublayer:bg atIndex:[self.view.layer.sublayers count]];
	[bg release];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
