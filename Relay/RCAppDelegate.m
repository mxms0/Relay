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

@implementation RCAppDelegate

@synthesize window = _window, navigationController = _navigationController, isDoubleHeight;

static BOOL isSetup = NO;

- (void)dealloc {
	[_window release];
	[_navigationController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	@autoreleasepool {
		[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent animated:NO];
	}

	/*
    const char *cString = [[[NSBundle mainBundle] pathForResource:@"overdrive" ofType:@"dylib"] UTF8String];
    int ret = -1;
    struct stat buf;
    memset(&buf, 0, sizeof(struct stat));
#if !TARGET_IPHONE_SIMULATOR
    __asm__("mov r0, %1\n\t"
            "mov r1, %2\n\t"
            "mov ip, #188\n\t"
            "svc #0x80\n\t"
            "mov %0, r0"
            : "=r"(ret)
            : "r"(cString), "r"(&buf)
            : "r0", "r1", "ip");
#else
	ret = stat(cString, &buf);
#endif
    NSLog(ret == 0 ? @"overdrive detected" : @"overdrive not found");
	 */
    // nice DRM i won't be using. 
	// thanks a lot nighthawk.
	
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
	UIViewController *rcv;
	Class rcvClass = [RCiPadViewController class];
	NSString *xib = @"RCViewController_iPad";
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		xib = @"RCViewController_iPhone";
		rcvClass = [RCViewController class];
	}
	rcv = [[rcvClass alloc] initWithNibName:xib bundle:nil];
	self.navigationController = [[[UINavigationController alloc] initWithRootViewController:rcv] autorelease];
	[rcv release];
	self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
	[self configureUI];
	if (!isSetup) {
		NSFileManager *manager = [NSFileManager defaultManager];
		NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:PREFS_PLIST];
		[[NSUserDefaults standardUserDefaults] setObject:path forKey:PREFS_PLIST];
		[[NSUserDefaults standardUserDefaults] synchronize];
		if (![manager fileExistsAtPath:PREFS_ABSOLUT]) {
			if (![manager createFileAtPath:PREFS_ABSOLUT contents:(NSData *)[NSDictionary dictionary] attributes:NULL]) {
				NSLog(@"fucked.");
			// fucked.
			}
		}
		[[RCNetworkManager sharedNetworkManager] setIsBG:NO];
		[[RCNetworkManager sharedNetworkManager] unpack];
		isSetup = YES;
		[TestFlight takeOff:@"35b8aa0d259ae0c61c57bc770aeafe63_Mzk5NDYyMDExLTExLTA5IDE4OjQ0OjEwLjc4MTM3MQ"];
		[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
	}
	return YES;
}

- (void)configureUI {
	UINavigationBar *nb = [UINavigationBar appearance];
	[nb setBackgroundImage:[UIImage imageNamed:@"0_addnav"] forBarMetrics:UIBarMetricsDefault];
	NSDictionary *formatting = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:11], UITextAttributeFont, UIColorFromRGB(0x929292), UITextAttributeTextColor,
								[NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset,
								[UIColor whiteColor], UITextAttributeTextShadowColor, nil];
	UIBarButtonItem *btn = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
	[btn setTitleTextAttributes:formatting forState:UIControlStateNormal];
	[btn setBackgroundImage:[[UIImage imageNamed:@"0_navbtn"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

}

/*
 UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 30)];
 [btn setTitle:@"Done" forState:UIControlStateNormal];
 [[btn titleLabel] setTextAlignment:UITextAlignmentCenter];
 [btn setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
 [[btn titleLabel] setShadowOffset:CGSizeMake(0, 1)];
 [[btn titleLabel] setFont:[UIFont boldSystemFontOfSize:11]];
 [btn setTitleColor:UIColorFromRGB(0x929292) forState:UIControlStateDisabled];
 [btn setTitleColor:UIColorFromRGB(0x454646) forState:UIControlStateNormal];
 [btn setBackgroundImage:[[UIImage imageNamed:@"0_navbtn"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
 [btn setBackgroundImage:[[UIImage imageNamed:@"0_navbtn_p"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateHighlighted];
 //	[btn setImage:[UIImage imageNamed:@"0_donebutton_disabled"] forState:UIControlStateDisabled];
 btn.enabled = NO;
 [btn addTarget:self action:@selector(doneConnection) forControlEvents:UIControlEventTouchUpInside];
 UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithCustomView:btn];
 [btn release];
 btn.enabled = !isNew;
 //	[self.navigationItem setRightBarButtonItem:done];
 [done release];
 
 UIButton *cBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 30)];
 [cBtn setTitle:@"Cancel" forState:UIControlStateNormal];
 [cBtn setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
 [[cBtn titleLabel] setShadowOffset:CGSizeMake(0, 1)];
 [[cBtn titleLabel] setFont:[UIFont boldSystemFontOfSize:11]];
 [cBtn setTitleColor:UIColorFromRGB(0x454646) forState:UIControlStateNormal];
 [cBtn setBackgroundImage:[[UIImage imageNamed:@"0_navbtn"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
 [cBtn setBackgroundImage:[[UIImage imageNamed:@"0_navbtn_p"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateHighlighted];
 [cBtn addTarget:self action:@selector(doneWithJoin) forControlEvents:UIControlEventTouchUpInside];
 UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithCustomView:cBtn];
 [cBtn release];
 //	[self.navigationItem setLeftBarButtonItem:cancel];
 [cancel release];
 */
// Do any additional setup after loading the view, typically from a nib.



- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[[RCNetworkManager sharedNetworkManager] setIsBG:YES];
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
	if (![notification userInfo]) return;
	NSDictionary *dict = [notification userInfo];
	RCNetwork *net = [[RCNetworkManager sharedNetworkManager] networkWithDescription:[dict objectForKey:RCCurrentNetKey]];
	[[RCNavigator sharedNavigator] selectNetwork:net];;
	RCChannel *chan = [net channelWithChannelName:[dict objectForKey:RCCurrentChanKey]];
	if ([[RCNavigator sharedNavigator] currentPanel])
		if (![[[[RCNavigator sharedNavigator] currentPanel] channel] isEqual:chan])
			[[RCNavigator sharedNavigator] channelSelected:[chan bubble]];
}

- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame {
	isDoubleHeight = (newStatusBarFrame.size.height == 40);
	if (isDoubleHeight) {
	}
	else {
	}
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

	[[RCNetworkManager sharedNetworkManager] setIsBG:NO];
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
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
