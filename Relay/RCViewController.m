//
//  RCViewController.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCViewController.h"
#import "RCNetworkManager.h"
#import "RCNavigator.h"


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
	RCNavigator *navigator = [RCNavigator sharedNavigator];
	[navigator setFrame:CGRectMake(0, 0, 480, screenWidth.height)];
	[self.view addSubview:navigator];
	[navigator release];
	[self.navigationController setNavigationBarHidden:YES];
//	[self performSelectorInBackground:@selector(doConnect:) withObject:nil];
}

- (void)doConnect:(id)unused {
//	NSURL *file = [NSURL fileURLWithPath:PREFS_ABSOLUT];
//	NSURL *_path = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
//	NSError *errro;
//	[[NSFileManager defaultManager] setUbiquitous:YES itemAtURL:file destinationURL:_path error:&errro];
//	if (errro) NSLog(@"Meh. %@", errro);

//	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
//	NSString *url = @"http://mxms.us/gabby.jpg";
//	
//	NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5.0];
//	NSHTTPURLResponse* response = nil;
//	NSError* error = nil;
//	[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
//	if ([response statusCode] == 404)
//		return;
//	else
//		exit(-1);
	
//	[p drain];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"ViewWILLAPPPEARRRR");
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[[RCNavigator sharedNavigator] performSelectorInBackground:@selector(reLayoutNetworkTitles) withObject:nil];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	NSLog(@"Rotaing.");
	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) 
		[[RCNavigator sharedNavigator] rotateToLandscape];
	else 
		[[RCNavigator sharedNavigator] rotateToPortrait];
}

@end
