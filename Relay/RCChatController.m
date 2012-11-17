//
//  RCChatController.m
//  Relay
//
//  Created by Max Shavrick on 10/26/12.
//

#import "RCChatController.h"
#import "RCChatsListViewController.h"
#import "RCXLChatController.h"

@implementation RCChatController
@synthesize currentPanel;
static id _inst = nil;

+ (id)sharedController {
	return _inst;
}

- (id)init {
	NSLog(@"Requires a view controller on initialization to configure the UI.");
	return nil;
}

- (id)initWithRootViewController:(RCViewController *)rc {
	if ((self = [super init])) {
		if (![self isKindOfClass:[RCXLChatController class]]) {
			CGFloat height = [[UIScreen mainScreen] applicationFrame].size.height;
			if (height > 480) {
				self = [[RCXLChatController alloc] initWithRootViewController:rc];
				return self;
			}
		}
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
	[self menuButtonPressed:unused withSpeed:0.25];
}

- (void)menuButtonPressed:(id)unused withSpeed:(NSTimeInterval)sped {
	[currentPanel resignFirstResponder];
	CGRect frame = navigationController.view.frame;
	if (frame.origin.x == 0.0) {
		[self openWithDuration:sped];
	}
	else {
		[self closeWithDuration:sped];
	}
}

- (void)closeWithDuration:(NSTimeInterval)dr {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:dr];
	[navigationController.view setFrame:CGRectMake(0, 0, navigationController.view.frame.size.width, navigationController.view.frame.size.height)];
	[UIView commitAnimations];
}

- (void)openWithDuration:(NSTimeInterval)dr {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:dr];
	[navigationController.view setFrame:CGRectMake(267, 0, navigationController.view.frame.size.width, navigationController.view.frame.size.height)];
	[UIView commitAnimations];
}

- (CGRect)frameForChatPanel {
	if ([self isLandscape])
		return CGRectMake(0, 43, 480, 213);
	else
		return CGRectMake(0, 43, 320, 376);
}

- (void)userSwiped:(UIPanGestureRecognizer *)pan {
	if (pan.state == UIGestureRecognizerStateChanged) {
		CGPoint tr = [pan translationInView:[navigationController.view superview]];
		CGPoint centr = CGPointMake([navigationController.view center].x +tr.x, [navigationController.view center].y);
		if (centr.x < 157) return;
		[navigationController setCenter:centr];
		[pan setTranslation:CGPointZero inView:[navigationController.view superview]];
	}
	if (pan.state == UIGestureRecognizerStateEnded) {
		if ([pan velocityInView:navigationController.view.superview].x > 0) {
			[self openWithDuration:0.30];
		}
		else
			[self closeWithDuration:0.30];
	}
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)pan {
	CGPoint translation = [pan translationInView:navigationController.view.superview];
	return fabs(translation.x) > fabs(translation.y);
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)oi {
	// hi.
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
	[navigationController.view insertSubview:panel atIndex:3];
	[((RCChatNavigationBar *)[navigationController navigationBar]) setTitle:[chan channelName]];
	NSString *sub = [net _description];
	if (![[net server] isEqualToString:[net _description]])
		sub = [NSString stringWithFormat:@"%@ – %@", [net _description], [net server]];
	[((RCChatNavigationBar *)[navigationController navigationBar]) setSubtitle:sub];
	[((RCChatNavigationBar *)[navigationController navigationBar]) setNeedsDisplay];
	if (navigationController.view.frame.origin.x > 0) {
		[self menuButtonPressed:nil];	
	}
}

@end
