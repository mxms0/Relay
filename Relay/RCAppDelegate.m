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
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
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

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[[RCNetworkManager sharedNetworkManager] setIsBG:YES];
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)application:(UIApplication *)application willChangeStatusBarFrame:(CGRect)newStatusBarFrame {
	isDoubleHeight = (newStatusBarFrame.size.height == 40);
	if (isDoubleHeight) {
		//		[[RCPopoverWindow sharedPopover] setFrame:CGRectMake(0, 5, 320, 460)];
	}
	else {
		//[[RCPopoverWindow sharedPopover] setFrame:CGRectMake(0, 0, 320, 480)];	
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
