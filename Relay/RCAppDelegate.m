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
static BOOL isSetup = NO;

- (void)dealloc {
	[_window release];
	[_navigationController release];
    [super dealloc];
}

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
	
	[self performSelectorInBackground:@selector(_setup) withObject:nil];
	return YES;
}

- (void)_setup {
	dispatch_async(dispatch_get_main_queue(), ^{
		[self configureUI];
		if (!isSetup) {
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
			isSetup = YES;
	//		[TestFlight takeOff:@"35b8aa0d259ae0c61c57bc770aeafe63_Mzk5NDYyMDExLTExLTA5IDE4OjQ0OjEwLjc4MTM3MQ"];
	//		[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
		}
	});	
}

- (void)configureUI {
	UINavigationBar *nb = [UINavigationBar appearance];
	[nb setBackgroundImage:[UIImage imageNamed:@"0_addnav"] forBarMetrics:UIBarMetricsDefault];
	NSDictionary *formatting = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:11], UITextAttributeFont, UIColorFromRGB(0x454646), UITextAttributeTextColor,
								[NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
								[UIColor whiteColor], UITextAttributeTextShadowColor, nil];
	NSDictionary *dFormatting = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:11], UITextAttributeFont, UIColorFromRGB(0x929292), UITextAttributeTextColor,
								 [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
								 [UIColor whiteColor], UITextAttributeTextShadowColor, nil];
	UIBarButtonItem *btn = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
	[btn setTitleTextAttributes:formatting forState:UIControlStateNormal];
	[btn setTitleTextAttributes:dFormatting forState:UIControlStateDisabled];
	[btn setBackgroundImage:[[UIImage imageNamed:@"0_navbtn"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	[btn setBackgroundImage:[[UIImage imageNamed:@"0_navbtn_p"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
	[btn setTitlePositionAdjustment:UIOffsetMake(0, 1) forBarMetrics:UIBarMetricsDefault];
	[btn setBackButtonBackgroundImage:[[UIImage imageNamed:@"0_navback"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	[btn setBackButtonBackgroundImage:[[UIImage imageNamed:@"0_navback_pressed"] stretchableImageWithLeftCapWidth:15 topCapHeight:15] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
	[btn setBackButtonTitlePositionAdjustment:UIOffsetMake(-1, 1) forBarMetrics:UIBarMetricsDefault];
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	NSLog(@"Meh %f", [UIApp backgroundTimeRemaining]);
	double ttime = [UIApp backgroundTimeRemaining];
	if (ttime > 60.00)
		ttime -= 60.00;
	[self performSelector:@selector(showExpirationWarning) withObject:nil afterDelay:ttime];
	[[RCNetworkManager sharedNetworkManager] setIsBG:YES];
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
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
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	reloadNetworks();
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application {
	NSLog(@"I want to liveeeeeee");
	/*
	 Called when the application is about to terminate.
	 Save data if appropriate.
	 See also applicationDidEnterBackground:.
	 */
}

@end
