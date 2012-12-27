//
//  RCViewController.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCViewController.h"
#import "RCNetworkManager.h"
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
	[[RCChatController alloc] initWithRootViewController:self];
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[[RCChatController sharedController] rotateToInterfaceOrientation:self.interfaceOrientation];
}

@end
