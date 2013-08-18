//
//  RCAppDelegate.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCAppDelegate.h"
#import "RCViewController.h"
#import "RCNetworkManager.h"
#import "RCiPadViewController.h"
#include <execinfo.h>
#include <stdio.h>
#include <stdlib.h>
#import "TestFlight.h"
#import "RCAddNetworkController.h"
#include <pwd.h>

@implementation RCAppDelegate

@synthesize window = _window, navigationController = _navigationController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	UIViewController *rcv;
	Class rcvClass = [RCiPadViewController class];

	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		rcvClass = [RCViewController class];
	}
	
    rcv = [[rcvClass alloc] init];
	self.navigationController = [[[UINavigationController alloc] initWithRootViewController:rcv] autorelease];
	[rcv release];
	self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
	[self _setup];
//	[TestFlight takeOff:TEAM_TOKEN];
	return YES;
}

- (void)_setup {
	char *hdir = getenv("HOME");
	if (!hdir) {
		NSLog(@"CAN'T FIND HOME DIRECTORY TO LOAD NETWORKS");
		exit(1);
	}
	NSString *absol = [NSString stringWithFormat:@"%s/Documents/Networks.plist", hdir];
	NSFileManager *manager = [NSFileManager defaultManager];
	if (![manager fileExistsAtPath:absol]) {
		if (![manager createFileAtPath:absol contents:(NSData *)[NSDictionary dictionary] attributes:NULL]) {
			NSLog(@"Could not create temporary networks property list.");
		}
	}
	[[RCNetworkManager sharedNetworkManager] setIsBG:NO];
	[[RCNetworkManager sharedNetworkManager] unpack];
	[self configureUI];
}

- (void)configureUI {
	UINavigationBar *nb = [UINavigationBar appearance];
	if (!isiOS7) {
		[nb setBackgroundImage:[[RCSchemeManager sharedInstance] imageNamed:@"mainnavbarbg"] forBarMetrics:UIBarMetricsDefault];
	}
	else {
		[nb setBackgroundImage:[[RCSchemeManager sharedInstance] imageNamed:@"ios7_mainnavbarbg"] forBarMetrics:UIBarMetricsDefault];
		[UIApplication sharedApplication].statusBarStyle = 1;
	}
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
#if LOGALL
	NSLog(@"Background Time Remaining %f", [UIApp backgroundTimeRemaining]);
#endif
	double ttime = [UIApp backgroundTimeRemaining];
	if (ttime > 60.00)
		ttime -= 60.00;
	[self performSelector:@selector(showExpirationWarning) withObject:nil afterDelay:ttime];
	[[RCNetworkManager sharedNetworkManager] setIsBG:YES];
    for (RCNetwork *network in [[RCNetworkManager sharedNetworkManager] networks]) {
        if ([network isConnected] && !network.isAway) {
            [network sendMessage:@"AWAY :Be back later."];
        }
    }
}

- (void)showExpirationWarning {
	BOOL _connected = NO;
	for (RCNetwork *net in [[RCNetworkManager sharedNetworkManager] networks]) {
		if ([net isConnected]) {
			_connected = YES;
			break;
		}
	}
	if (!_connected) return;
	UILocalNotification *nb = [[UILocalNotification alloc] init];
	[nb setAlertAction:@"Open"];
	[nb setAlertBody:@"You will be disconnected in less than a minute due to inactivity."];
	[UIApp presentLocalNotificationNow:nb];
	[nb release];	
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	if (![notification userInfo]) return;
	NSDictionary *dict = [notification userInfo];
	RCNetwork *net = [[RCNetworkManager sharedNetworkManager] networkWithDescription:[dict objectForKey:RCCurrentNetKey]];
	NSString *chan = [dict objectForKey:RCCurrentChanKey];
	[[RCChatController sharedController] selectChannel:chan fromNetwork:net];
}

- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame {
	[[RCChatController sharedController] correctSubviewFrames];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showExpirationWarning) object:nil];
	[[RCNetworkManager sharedNetworkManager] setIsBG:NO];
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
    for (RCNetwork *network in [[RCNetworkManager sharedNetworkManager] networks]) {
		if ([network isConnected])
			[network sendMessage:@"AWAY"];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	reloadNetworks();
}

- (void)applicationWillTerminate:(UIApplication *)application {
	NSLog(@"I want to liveeeeeee");
}

- (void)dealloc {
	[_window release];
	[_navigationController release];
    [super dealloc];
}

@end
