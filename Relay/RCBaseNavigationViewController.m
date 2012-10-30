//
//  RCBaseNavigationViewController.m
//  Relay
//
//  Created by Max Shavrick on 10/28/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCBaseNavigationViewController.h"

@implementation RCBaseNavigationViewController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
	if ((self = [super initWithNavigationBarClass:[RCChatNavigationBar class] toolbarClass:[UIToolbar class]])) {
		[self setViewControllers:[NSArray arrayWithObject:rootViewController] animated:NO];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
