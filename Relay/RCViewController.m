//
//  RCViewController.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCViewController.h"
#import "RCNetworkManager.h"
#import "RCNavigator.h"
#import "RCPrettyAlertView.h"

@implementation RCViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	NSLog(@"CLEANUP CLEANUP EVERYBODY CLEANUP");
}

#pragma mark - VIEW SHIT

- (void)viewDidLoad {
    [super viewDidLoad];

	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert];
	CGSize screenWidth = [[UIScreen mainScreen] applicationFrame].size;
	[self.navigationController setNavigationBarHidden:YES];
	rootView = [[UIViewController alloc] init]; 
	navigationController = [[UINavigationController alloc] initWithRootViewController:rootView];
	[self.view addSubview:navigationController.view];
	[self.view setFrame:CGRectMake(0, 0, 320, 460)];
	[navigationController setNavigationBarHidden:YES];
	[navigationController setNavigationBarHidden:NO]; // strange hack to make toolbar at top of screen.. :s
	[[navigationController navigationBar] setBackgroundImage:[UIImage imageNamed:@"0_headr"] forBarMetrics:UIBarMetricsDefault];
leftView = [[RCChatsListViewController alloc] init];
	[self.view insertSubview:leftView.view atIndex:0];
	UIButton *listr = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 31)];
	[listr setImage:[UIImage imageNamed:@"0_listrbtn"] forState:UIControlStateNormal];
	[listr setImage:[UIImage imageNamed:@"0_listrbtn_pressed"] forState:UIControlStateHighlighted];
	UIBarButtonItem *fs = [[UIBarButtonItem alloc] initWithCustomView:listr];
	[[rootView navigationItem] setLeftBarButtonItem:fs];
	[fs release];
	[listr release];
	UIButton *ppls = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 41, 31)];
	[ppls setImage:[UIImage imageNamed:@"0_pple"] forState:UIControlStateNormal];
	[ppls setImage:[UIImage imageNamed:@"0_pple_press"] forState:UIControlStateHighlighted];
	UIBarButtonItem *bs = [[UIBarButtonItem alloc] initWithCustomView:ppls];
	[[rootView navigationItem] setRightBarButtonItem:bs];
	[bs release];
	[ppls release];

}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotate {
	return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[[RCNavigator sharedNavigator] rotateToInterfaceOrientation:toInterfaceOrientation];
}

@end
