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
	[self.navigationController setNavigationBarHidden:YES];
	CGSize frame = [[UIScreen mainScreen] applicationFrame].size;
	UIViewController *base = [[UIViewController alloc] init];
	UIViewController *baseTwo = [[UIViewController alloc] init];
	navigationController = [[RCChatViewController alloc] initWithRootViewController:baseTwo];
	[((RCChatNavigationBar *)[navigationController navigationBar]) setTitle:@"Relay"];
	[((RCChatNavigationBar *)[navigationController navigationBar]) setSubtitle:@"Welcome to Relay"];
	[[navigationController navigationBar] setNeedsDisplay];
	[self.view addSubview:navigationController.view];
	[self.view setFrame:CGRectMake(0, 0, 320, 460)];
	[navigationController setNavigationBarHidden:YES];
	[navigationController setNavigationBarHidden:NO]; // strange hack to make toolbar at top of screen.. :s
	[[navigationController navigationBar] setBackgroundImage:[UIImage imageNamed:@"0_headr"] forBarMetrics:UIBarMetricsDefault];
	leftView = [[RCChatsListViewController alloc] initWithRootViewController:base];
	[self.view insertSubview:leftView.view atIndex:0];
	[leftView.view setFrame:CGRectMake(0, 0, 320, 520)];
	[leftView setNavigationBarHidden:YES];
	[leftView setNavigationBarHidden:NO]; // again. ffs
	UIButton *listr = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 42, 31)];
	[listr setImage:[UIImage imageNamed:@"0_listrbtn"] forState:UIControlStateNormal];
	[listr setImage:[UIImage imageNamed:@"0_listrbtn_pressed"] forState:UIControlStateHighlighted];
	[listr addTarget:self action:@selector(menuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *fs = [[UIBarButtonItem alloc] initWithCustomView:listr];
	[[[navigationController topViewController] navigationItem] setLeftBarButtonItem:fs];
	[fs release];
	[listr release];
	UIButton *ppls = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 41, 31)];
	[ppls setImage:[UIImage imageNamed:@"0_pple"] forState:UIControlStateNormal];
	[ppls setImage:[UIImage imageNamed:@"0_pple_press"] forState:UIControlStateHighlighted];
	UIBarButtonItem *bs = [[UIBarButtonItem alloc] initWithCustomView:ppls];
	[[[navigationController topViewController] navigationItem] setRightBarButtonItem:bs];
	[bs release];
	[ppls release];
	NSLog(@"meh %@", [self.view recursiveDescription]);
}

- (void)menuButtonPressed:(id)unused {
	CGRect frame = navigationController.view.frame;
	if (frame.origin.x == 0.0) {
		frame.origin.x = 267;
	}
	else {
		frame.origin.x = 0;
	}
	[UIView beginAnimations:nil context:nil];
	[navigationController setFrame:frame];
	[UIView commitAnimations];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
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
