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
	// will clear all private message whois infos
	// if that still fails, will clear user lists. maybe.s
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
	UIWindow *wv = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
	[wv setWindowLevel:1000000];
	[wv setHidden:NO];
	[wv setBackgroundColor:[UIColor clearColor]];
	UITapGestureRecognizer *tp = [[UITapGestureRecognizer alloc] initWithTarget:[RCChatController sharedController] action:@selector(statusWindowTapped:)];
	[wv addGestureRecognizer:tp];
	[tp release];
	if ([[[RCNetworkManager sharedNetworkManager] networks] count] == 0) {
		[[RCChatController sharedController] presentInitialSetupView];
	}
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[[RCChatController sharedController] rotateToInterfaceOrientation:self.interfaceOrientation];
}

@end
