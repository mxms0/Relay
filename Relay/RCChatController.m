//
//  RCChatController.m
//  Relay
//
//  Created by Max Shavrick on 10/26/12.
//

#import "RCChatController.h"
#import "RCChatsListViewController.h"

@implementation RCChatController
@synthesize currentPanel;
static id _inst = nil;

+ (id)sharedController; {
	return _inst;
}

- (id)init {
	NSLog(@"Requires a view controller on initialization to configure the UI.");
	return nil;
}

- (id)initWithRootViewController:(RCViewController *)rc {
	if ((self = [super init])) {
		_inst = self;
		currentPanel = nil;
		rootView = rc;
		CGSize frame = [[UIScreen mainScreen] applicationFrame].size;
		UIViewController *base = [[UIViewController alloc] init];
		UIViewController *baseTwo = [[UIViewController alloc] init];
		navigationController = [[RCChatViewController alloc] initWithRootViewController:baseTwo];
		[navigationController.view setFrame:CGRectMake(0, 0, frame.width, frame.height)];
		[baseTwo.view setFrame:navigationController.view.frame];
		[((RCChatNavigationBar *)[navigationController navigationBar]) setTitle:@"Relay"];
		[((RCChatNavigationBar *)[navigationController navigationBar]) setSubtitle:@"Welcome to Relay"];
		[[navigationController navigationBar] setNeedsDisplay];
		[rc.view addSubview:navigationController.view];
		[navigationController setNavigationBarHidden:YES];
		[navigationController setNavigationBarHidden:NO]; // strange hack to make toolbar at top of screen.. :s
		[[navigationController navigationBar] setBackgroundImage:[UIImage imageNamed:@"0_headr"] forBarMetrics:UIBarMetricsDefault];
		leftView = [[RCChatsListViewController alloc] initWithRootViewController:base];
		[((RCChatNavigationBar *)[leftView navigationBar]) setTitle:@"Chats"];
		[rc.view insertSubview:leftView.view atIndex:0];
		[leftView.view setFrame:CGRectMake(0, 0, frame.width, frame.height)];
		[leftView setNavigationBarHidden:YES];
		[leftView setNavigationBarHidden:NO]; // again. ffs
	}
	return _inst;
}

- (BOOL)isLandscape {
	return UIInterfaceOrientationIsLandscape(navigationController.interfaceOrientation);
}

- (void)menuButtonPressed:(id)unused {
	[currentPanel resignFirstResponder];
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

- (CGRect)frameForChatPanel {
	if ([self isLandscape])
		return CGRectMake(0, 44, 480, 212);
	else
		return CGRectMake(0, 44, 320, 372);
}

- (CGRect)frameForInputField:(BOOL)activ {
	float y = 376;
	float w = 320;
	if (activ)
		y = 161;
	if ([self isLandscape])
		w = 480;
	return CGRectMake(0, y, w, 40);
}

- (void)selectChannel:(NSString *)channel fromNetwork:(RCNetwork *)net {
	for (UIView *subv in [navigationController.view subviews]) {
		if ([subv isKindOfClass:[RCChatPanel class]])
			[subv removeFromSuperview];
	}
	RCChannel *chan = [net channelWithChannelName:channel];
	if (!chan) {
		NSLog(@"AN ERROR OCCURED. THIS CHANNEL DOES NOT EXIST BUT IS IN THE TABLE VIEW ANYWAYS.");
		return;
	}
	RCChatPanel *panel = [chan panel];
	[panel setFrame:[self frameForChatPanel]];
	currentPanel = panel;
	[navigationController.view addSubview:panel];
	[self menuButtonPressed:nil];
}

@end
