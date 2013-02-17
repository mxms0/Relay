//
//  RCChatController.m
//  Relay
//
//  Created by Max Shavrick on 10/26/12.
//

#import "RCChatController.h"
#import "RCChatsListViewController.h"
#import "RCXLChatController.h"
#import "RCUserListViewController.h"

@implementation RCChatController
@synthesize currentPanel, canDragMainView;
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
		navigationController = nil;
		leftView = nil;
		topView = nil;
		_inst = self;
		[self layoutWithRootViewController:rc];
	}
	return _inst;
}

- (void)setDefaultTitleAndSubtitle {
	[((RCChatNavigationBar *)[navigationController navigationBar]) setTitle:@"Relay"];
	[((RCChatNavigationBar *)[navigationController navigationBar]) setSubtitle:@"Welcome to Relay"];
	[[navigationController navigationBar] setNeedsDisplay];
}

- (void)layoutWithRootViewController:(RCViewController *)rc {
	currentPanel = nil;
	rootView = rc;
	canDragMainView = YES;
	CGSize frame = [[UIScreen mainScreen] applicationFrame].size;
	chatViewHeights[0] = frame.height-83;
	chatViewHeights[1] = frame.height-299;
	UIViewController *base = [[UIViewController alloc] init];
	UIViewController *baseTwo = [[UIViewController alloc] init];
	UIViewController *baseThree = [[UIViewController alloc] init];
	navigationController = [[RCChatViewController alloc] initWithRootViewController:baseTwo];
	[navigationController.view setFrame:CGRectMake(0, 0, frame.width, frame.height)];
	[baseTwo.view setFrame:navigationController.view.frame];
	[self setDefaultTitleAndSubtitle];
	[rc.view addSubview:navigationController.view];
	[navigationController setNavigationBarHidden:YES];
	[navigationController setNavigationBarHidden:NO]; // strange hack to make toolbar at top of screen.. :s
	[[navigationController navigationBar] setBackgroundImage:[UIImage imageNamed:@"0_headr"] forBarMetrics:UIBarMetricsDefault];
	leftView = [[RCChatsListViewController alloc] initWithRootViewController:base];
	[((RCChatNavigationBar *)[leftView navigationBar]) setTitle:@"Chats"];
	[((RCChatNavigationBar *)[leftView navigationBar]) setSuperSpecialLikeAc3xx2:YES];
	[rc.view insertSubview:leftView.view atIndex:0];
	[leftView.view setFrame:CGRectMake(0, 0, frame.width, frame.height)];
	[leftView setNavigationBarHidden:YES];
	[leftView setNavigationBarHidden:NO]; // again. ffs
	topView = [[RCUserListViewController alloc] initWithRootViewController:baseThree];
	[topView.view setFrame:CGRectMake(frame.width, 0, frame.width, frame.height)];
	[((RCChatNavigationBar *)[topView navigationBar]) setTitle:@"Memberlist"];
	[((RCChatNavigationBar *)[topView navigationBar]) setSuperSpecialLikeAc3xx2:YES];
	[rc.view insertSubview:topView.view atIndex:[[rc.view subviews] count]];
	[baseThree.view setFrame:topView.view.frame];
	[topView setNavigationBarHidden:YES];
	[topView setNavigationBarHidden:NO];
	[base release];
	[baseTwo release];
	[baseThree release];
	UIPanGestureRecognizer *spr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(bottomLayerSwiped:)];
	[spr setDelegate:self];
	[rc.view addGestureRecognizer:spr];
	[spr release];
	_bar = [[RCTextFieldBackgroundView alloc] initWithFrame:CGRectMake(0, 300, 320, 40)];
	[_bar setOpaque:YES];
	field = [[RCTextField alloc] initWithFrame:CGRectMake(15, 5, 299, 31)];
	[field setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
	[field setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	[field setReturnKeyType:UIReturnKeySend];
	[field setTextColor:UIColorFromRGB(0x3E3F3F)];
	[field setFont:[UIFont fontWithName:@"Helvetica" size:12]];
	[field setMinimumFontSize:17];
	[field setAdjustsFontSizeToFitWidth:YES];
	[field setDelegate:self];
	[field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[field setClearButtonMode:UITextFieldViewModeWhileEditing];
	[_bar addSubview:field];
	[field release];
	[navigationController.view insertSubview:_bar atIndex:3];
	UIPanGestureRecognizer *panr = [[UIPanGestureRecognizer alloc] initWithTarget:[RCChatController sharedController] action:@selector(userSwiped:)];
	[panr setDelegate:[RCChatController sharedController]];
	[navigationController.view addGestureRecognizer:panr];
	[panr release];
	suggestLocation = [self suggestionLocation];
}

- (void)correctSubviewFrames {
	CGSize fsize = [[UIScreen mainScreen] applicationFrame].size;
	[leftView setFrame:CGRectMake(0, 0, fsize.width, fsize.height)];
	[navigationController setFrame:CGRectMake(0, 0, fsize.width, fsize.height)];
	canDragMainView = YES;
	[self setEntryFieldEnabled:YES];
	[currentPanel setFrame:CGRectMake(currentPanel.frame.origin.x, currentPanel.frame.origin.y, fsize.width, fsize.height)];
	[[[[navigationController topViewController] navigationItem] leftBarButtonItem] setEnabled:YES];
	[UIView animateWithDuration:0.25 animations:^ {
		[topView setFrame:CGRectMake(topView.view.frame.size.width, 0, topView.view.frame.size.width, topView.view.frame.size.height)];
	} completion:^(BOOL fin) {
		[topView findShadowAndDoStuffToIt];
	}];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	[self repositionKeyboardForUse:YES animated:YES];
	[currentPanel scrollToBottom];
	return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	[self repositionKeyboardForUse:NO animated:YES];
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([textField.text isEqualToString:@""] || textField.text == nil) return NO;
	NSString *appstore_txt = [textField.text retain];
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
	dispatch_async(queue, ^ {
		dispatch_sync(dispatch_get_main_queue(), ^ {
			[[currentPanel channel] userWouldLikeToPartakeInThisConversation:appstore_txt];
			[appstore_txt release];
		});
	});
	//	[self performSelectorInBackground:@selector(__reallySend:) withObject:textField.text];
	[textField setText:@""];
	[[RCNickSuggestionView sharedInstance] dismiss];
	return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([[currentPanel channel] isPrivate]) return YES;
	NSString *text = [[textField text] retain]; // has to be obtained from a main thread.
	UITextField *tf = [textField retain];
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
	dispatch_async(queue, ^ {
		NSString *lolhaiqwerty = text;
		NSRange rr = NSMakeRange(0, range.location + string.length);
		lolhaiqwerty = [lolhaiqwerty stringByReplacingCharactersInRange:range withString:string];
		for (int i = (range.location + string.length-1); i >= 0; i--) {
			if ([lolhaiqwerty characterAtIndex:i] == ' ') {
				rr.location = i + 1;
				rr.length = ((range.location + string.length) - rr.location);
				break;
			}
		}
		NSString *personMayb = [lolhaiqwerty substringWithRange:rr];
#if LOGALL
		NSLog(@"Word of SAY is [%@]", personMayb);
#endif
		if (!personMayb) {
			dispatch_sync(dispatch_get_main_queue(), ^{
				[[RCNickSuggestionView sharedInstance] dismiss];
				[tf release];
				[text release]; // may cause crash.
				return;
			});
		}
		else if ([personMayb length] == 0) {
			dispatch_sync(dispatch_get_main_queue(), ^{
				[[RCNickSuggestionView sharedInstance] dismiss];
				[tf release];
			});
		}
		else if ([personMayb length] > 1) {
			NSArray *found = [[currentPanel channel] usersMatchingWord:personMayb];
			dispatch_sync(dispatch_get_main_queue(), ^{
				if ([found count] > 0) {
					[[RCNickSuggestionView sharedInstance] setRange:rr inputField:tf];
					[navigationController.view insertSubview:[RCNickSuggestionView sharedInstance] atIndex:5];
					[[RCNickSuggestionView sharedInstance] showAtPoint:CGPointMake(10, suggestLocation) withNames:found];
				}
				else {
					[[RCNickSuggestionView sharedInstance] dismiss];
				}
				[tf release];
			});
		}
		else {
			dispatch_sync(dispatch_get_main_queue(), ^{
				[[RCNickSuggestionView sharedInstance] dismiss];
				[tf release];
			});
		}
		[text release]; // may cause crash.
	});
	return YES;
}

- (void)repositionKeyboardForUse:(BOOL)us animated:(BOOL)anim {
	if (anim) {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.25];
	}
	CGRect main = CGRectMake(0, 43, 320, chatViewHeights[(int)us]);
	[currentPanel setFrame:main];
	[_bar setFrame:CGRectMake(0, currentPanel.frame.origin.y + currentPanel.frame.size.height, 320, 40)];
	
	if (anim) [UIView commitAnimations];
	if (!us) {
		[[RCNickSuggestionView sharedInstance] dismiss];
	}
}

- (void)setEntryFieldEnabled:(BOOL)en {
	[field setEnabled:en];
}

- (BOOL)isLandscape {
	// hopefully reliable..
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

static RCNetwork *currentNetwork = nil;
// should probably just make UIAlertView subclass.. derp

- (void)showNetworkOptions:(id)arg1 {
	currentNetwork = [(RCNetworkHeaderButton *)[arg1 superview] net];
	RCPrettyActionSheet *sheet = [[RCPrettyActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"What do you want to do for %@?", [currentNetwork _description]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Edit", ([currentNetwork isTryingToConnectOrConnected] ? @"Disconnect" : @"Connect"), nil];
	[sheet showInView:[[[UIApp delegate] navigationController] view]];
	[sheet release];
}

- (void)presentViewControllerInMainViewController:(UIViewController *)hi {
	UIViewController *rc = [((RCAppDelegate *)[[UIApplication sharedApplication] delegate]) navigationController];
	UINavigationController *ctrl = [[UINavigationController alloc] initWithRootViewController:hi];
	[ctrl setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
	[rc presentModalViewController:ctrl animated:YES];
	[ctrl release];
}

- (void)showNetworkAddViewController {
	RCAddNetworkController *newc = [[RCAddNetworkController alloc] initWithNetwork:nil];
	[self presentViewControllerInMainViewController:newc];
	[newc release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[actionSheet dismissWithClickedButtonIndex:buttonIndex animated:YES];
		[self showDeleteConfirmationForNetwork];
	}
	else if (buttonIndex == 1) {
		RCAddNetworkController *addNet = [[RCAddNetworkController alloc] initWithNetwork:currentNetwork];
		[self presentViewControllerInMainViewController:addNet];
		[addNet release];
		currentNetwork = nil;
		// edit.
	}
	else if (buttonIndex == 2) {
		[currentNetwork connectOrDisconnectDependingOnCurrentStatus];
		currentNetwork = nil;
		//connect
	}
	else if (buttonIndex == 4) {
		// cancel.
		// kbye
	}
}

- (void)showDeleteConfirmationForNetwork {
	RCPrettyAlertView *qq = [[RCPrettyAlertView alloc] initWithTitle:@"Are you sure?" message:[NSString stringWithFormat:@"Are you sure you want to delete %@? This action cannot be undone.", [currentNetwork _description]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
	[qq setTag:DEL_CONFIRM_KEY];
	[qq show];
	[qq release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch ([alertView tag]) {
		case DEL_CONFIRM_KEY:
			if (buttonIndex == 1) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"us.mxms.relay.del" object:[currentNetwork _description]];
				currentNetwork = nil;
			}
			break;
		default:
			break;
	}
}

- (void)closeWithDuration:(NSTimeInterval)dr {
	[UIView animateWithDuration:dr animations:^{
		[navigationController.view setFrame:CGRectMake(0, 0, navigationController.view.frame.size.width, navigationController.view.frame.size.height)];
	} completion:^(BOOL fin) {
		[self setEntryFieldEnabled:YES];
		[navigationController findShadowAndDoStuffToIt];
	}];
}

- (void)openWithDuration:(NSTimeInterval)dr {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:dr];
	[navigationController.view setFrame:CGRectMake(267, 0, navigationController.view.frame.size.width, navigationController.view.frame.size.height)];
	[navigationController findShadowAndDoStuffToIt];
	[UIView commitAnimations];
	
	//	[currentPanel resignFirstResponder];
	[self setEntryFieldEnabled:NO];
	[self dismissMenuOptions];
}

- (void)pushUserListWithDuration:(NSTimeInterval)dr {
	RCChannel *channel = [currentPanel channel];
	if ([channel isKindOfClass:[RCPMChannel class]]) {
		[topView showUserInfoPanel];
		[((RCChatNavigationBar *)[topView navigationBar]) setSubtitle:nil];
	}
	else if ([channel isKindOfClass:[RCConsoleChannel class]]) {
		[((RCChatNavigationBar *)[topView navigationBar]) setSubtitle:nil];
		[topView showUserListPanel];
	}
	else if ([channel isKindOfClass:[RCChannel class]]) {
		[((RCChatNavigationBar *)[topView navigationBar]) setSubtitle:[NSString stringWithFormat:@"%d users in %@", [[channel fullUserList] count], [channel channelName]]];
		[topView showUserListPanel];
	}
	[((RCChatNavigationBar *)[topView navigationBar]) setNeedsDisplay];
	[topView reloadData];
	canDragMainView = NO;
	[self closeWithDuration:0.00];
	[[[[navigationController topViewController] navigationItem] leftBarButtonItem] setEnabled:NO];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:dr];
	[topView setFrame:CGRectMake(52, 0, topView.view.frame.size.width, topView.view.frame.size.height)];
	[topView findShadowAndDoStuffToIt];
	[UIView commitAnimations];
	[currentPanel resignFirstResponder];
	[self setEntryFieldEnabled:NO];
	[self dismissMenuOptions];
}

- (void)popUserListWithDuration:(NSTimeInterval)dr {
	canDragMainView = YES;
	[self setEntryFieldEnabled:YES];
	[[[[navigationController topViewController] navigationItem] leftBarButtonItem] setEnabled:YES];
	[UIView animateWithDuration:dr animations:^ {
		[topView setFrame:CGRectMake(topView.view.frame.size.width, 0, topView.view.frame.size.width, topView.view.frame.size.height)];
	} completion:^(BOOL fin) {
		[topView findShadowAndDoStuffToIt];
	}];
}

- (void)pushUserListWithDefaultDuration {
	[self pushUserListWithDuration:0.30];
}

- (void)popUserListWithDefaultDuration {
	[self popUserListWithDuration:0.30];
}

- (CGRect)frameForChatPanel {
	if ([self isLandscape])
		return CGRectMake(0, 43, 480, 213);
	else
		return CGRectMake(0, 43, 320, 376);
}

- (void)userSwiped_specialLikeAc3xx:(UIPanGestureRecognizer *)pan {
	if (pan.state == UIGestureRecognizerStateChanged) {
		CGPoint tr = [pan translationInView:[navigationController.view superview]];
		CGPoint cr = CGPointMake([topView.view center].x + tr.x, topView.view.center.y);
		if (cr.x >= 180) {
			[topView setCenter:cr];
			[pan setTranslation:CGPointZero inView:[navigationController.view superview]];
		}
	}
	else if (pan.state == UIGestureRecognizerStateEnded) {
		if ([pan velocityInView:[navigationController.view superview]].x > 0) {
			[self popUserListWithDuration:0.30];
		}
		else {
			[self pushUserListWithDuration:0.30];
		}
	}
}

- (void)bottomLayerSwiped:(UIPanGestureRecognizer *)pan {
	if (pan.state == UIGestureRecognizerStateChanged) {
		CGPoint tr = [pan translationInView:[navigationController.view superview]];
		CGPoint cr = CGPointMake([navigationController.view center].x + tr.x, navigationController.view.center.y);
		if (cr.x >= 180) {
			[navigationController setCenter:cr];
			[pan setTranslation:CGPointZero inView:[navigationController.view superview]];
		}
	}
	else if (pan.state == UIGestureRecognizerStateEnded) {
		if ([pan velocityInView:[navigationController.view superview]].x > 0) {
			[self openWithDuration:0.30];
		}
		else {
			[self closeWithDuration:0.30];
		}
	}
}


- (void)userSwiped_specialLikeFr0st:(UIPanGestureRecognizer *)pan {
	if (![self isLandscape]) {
		[self userSwiped:pan];
		return;
	}
	if (pan.state == UIGestureRecognizerStateBegan) {
		
		
	}
	else if (pan.state == UIGestureRecognizerStateEnded) {
		
	}
}

- (void)userSwiped:(UIPanGestureRecognizer *)pan {
	if ([self isLandscape]) {
		[self userSwiped_specialLikeFr0st:pan];
		return;
	}
	if (pan.state == UIGestureRecognizerStateChanged) {
		CGPoint tr = [pan translationInView:[navigationController.view superview]];
		CGPoint centr = CGPointMake([navigationController.view center].x +tr.x, [navigationController.view center].y);
		if (draggingUserList && [topView.view frame].origin.x > [topView.view frame].size.width) {
			draggingUserList = NO;
		}
#if LOGALL
		NSLog(@"HI I AM @ %f", centr.x);
#endif
		if (centr.x < 157 || draggingUserList) {
			draggingUserList = YES;
			[topView setCenter:CGPointMake([topView.view center].x+tr.x, [topView.view center].y)];
			[pan setTranslation:CGPointZero inView:[navigationController.view superview]];
			return;
		}
		if (!draggingUserList) {
			if (canDragMainView) {
				//	if (centr.x <= 595 && centr.x > 285) {
					[navigationController setCenter:centr];
					[pan setTranslation:CGPointZero inView:[navigationController.view superview]];
				//}
			}
		}
	}
	else if (pan.state == UIGestureRecognizerStateEnded) {
		if (draggingUserList) {
			if ([pan velocityInView:[navigationController.view superview]].x > 0) {
				[self popUserListWithDuration:0.30];
			}
			else {
				[self pushUserListWithDuration:0.30];
			}
		}
		else {
			if (!canDragMainView) return;
			if ([pan velocityInView:navigationController.view.superview].x > 0) {
				[self openWithDuration:0.30];
			}
			else
				[self closeWithDuration:0.30];
		}
		draggingUserList = NO;
	}
	else if (pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed) {
		[self cleanLayersAndMakeMainChatVisible];
	}
}

- (void)cleanLayersAndMakeMainChatVisible {
	[self popUserListWithDuration:0.00];
	[self closeWithDuration:0.30];
}

- (void)showMenuOptions:(id)unused {
	if ([[currentPanel channel] isKindOfClass:[RCConsoleChannel class]]) return;
	RCChatNavigationBar *rc = (RCChatNavigationBar *)[navigationController navigationBar];
	NSMutableArray *buttons = [[NSMutableArray alloc] init];
	UIButton *joinr = [[UIButton alloc] init];
	SEL jsel = @selector(joinOrConnectDependingOnState);
	if (![[currentPanel channel] joined]) {
		[joinr setImage:[UIImage imageNamed:@"0_joinliv"] forState:UIControlStateNormal];
	}
	else {
		[joinr setImage:[UIImage imageNamed:@"0_cncl"] forState:UIControlStateNormal];
		jsel = @selector(dismissMenuOptions);
	}
	[joinr addTarget:self action:jsel forControlEvents:UIControlEventTouchUpInside];
	[buttons addObject:joinr];
	[joinr release];
	UIButton *trsh = [[UIButton alloc] init];
	[trsh setImage:[UIImage imageNamed:@"0_trshdis"] forState:UIControlStateNormal];
	[trsh addTarget:self action:@selector(deleteCurrentChannel) forControlEvents:UIControlEventTouchUpInside];
	[buttons addObject:trsh];
	[trsh release];
	UIButton *meml = [[UIButton alloc] init];
	[meml setImage:[UIImage imageNamed:@"0_meml"] forState:UIControlStateNormal];
	[meml addTarget:self action:@selector(showMemberList) forControlEvents:UIControlEventTouchUpInside];
	[buttons addObject:meml];
	[meml release];
	UIButton *lev = [[UIButton alloc] init];
	UIImage *levi = nil;
	SEL fsel = @selector(leaveCurrentChannel);
	if ([[currentPanel channel] joined]) {
		levi = [UIImage imageNamed:@"0_lev"];
	}
	else {
		levi = [UIImage imageNamed:@"0_cncl"];
		fsel = @selector(dismissMenuOptions);
	}
	[lev setImage:levi forState:UIControlStateNormal];
	[lev addTarget:self action:fsel forControlEvents:UIControlEventTouchUpInside];
	[buttons addObject:lev];
	[lev release];
	[rc setDrawIndent:YES];
	[rc setNeedsDisplay];
	for (int i = 0; i < [buttons count]; i++) {
		CGRect frame = CGRectMake(65, 2, [rc frame].size.width-130, 43);
		CGFloat indivSize = frame.size.width/[buttons count];
		UIButton *b = (UIButton *)[buttons objectAtIndex:i];
		[b setFrame:CGRectMake(i*indivSize+(frame.origin.x), 1, indivSize, frame.size.height)];
		[b setAlpha:0];
		[UIView beginAnimations:nil context:nil];
		[rc addSubview:b];
		[b setAlpha:1];
		[UIView commitAnimations];
	}
}

- (void)dismissMenuOptions {
	RCChatNavigationBar *rc = (RCChatNavigationBar *)[navigationController navigationBar];
	for (UIButton *subv in [rc subviews]) {
		if ([subv isKindOfClass:[UIButton class]]) {
			if ([subv tag] != 1132) {
				[subv removeFromSuperview];
			}
		}
	}
	[rc setDrawIndent:NO];
	[rc setNeedsDisplay];
}

- (void)deleteCurrentChannel {
	RCPrettyAlertView *confirm = [[RCPrettyAlertView alloc] initWithTitle:@"Are you sure?" message:[NSString stringWithFormat:@"Are you sure you want to remove %@?", [[currentPanel channel] channelName]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Remove", nil];
	[confirm show];
	[confirm release];
	[self dismissMenuOptions];
}

- (void)leaveCurrentChannel {
	if ([[[currentPanel channel] delegate] isConnected])
		[[currentPanel channel] setJoined:NO withArgument:@"Relay."];
	[self dismissMenuOptions];
}

- (void)joinOrConnectDependingOnState {
	if ([[[currentPanel channel] delegate] isConnected]) {
		[[currentPanel channel] setJoined:YES withArgument:nil];
	}
	else {
		[[currentPanel channel] setTemporaryJoinOnConnect:YES];
	}
	[self dismissMenuOptions];
}

- (void)showMemberList {
	[self dismissMenuOptions];
	[self pushUserListWithDefaultDuration];
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)pan {
	CGPoint translation = [pan translationInView:navigationController.view.superview];
	return fabs(translation.x) > fabs(translation.y);
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)oi {
	[UIViewController attemptRotationToDeviceOrientation];
	[self correctSubviewFrames];
	// hi.
}

- (BOOL)isShowingChatListView {
	return (navigationController.view.frame.origin.x > 0);
}

- (void)reloadUserCount {
	RCChannel *chan = [currentPanel channel];
	[((RCChatNavigationBar *)[topView navigationBar]) setSubtitle:[NSString stringWithFormat:@"%d users in %@", [[chan fullUserList] count], [chan channelName]]];
}

- (void)selectChannel:(NSString *)channel fromNetwork:(RCNetwork *)_net {
	for (UIView *subv in [navigationController.view subviews]) {
		if ([subv isKindOfClass:[RCChatPanel class]])
			[subv removeFromSuperview];
	}
	RCNetwork *net = _net;
	if (!_net) net = [[currentPanel channel] delegate];
	RCChannel *chan = [net channelWithChannelName:channel];
	[chan setNewMessageCount:0];
	[((RCChatNavigationBar *)[topView navigationBar]) setNeedsDisplay];
	if (!chan) {
		NSLog(@"AN ERROR OCCURED. THIS CHANNEL DOES NOT EXIST BUT IS IN THE TABLE VIEW ANYWAYS.");
		return;
	}
	RCChatPanel *panel = [chan panel];
	[panel setFrame:CGRectMake(0, 43, 320, chatViewHeights[0])];
	[_bar setFrame:CGRectMake(0, panel.frame.origin.y+panel.frame.size.height, _bar.frame.size.width, _bar.frame.size.height)];
	currentPanel = panel;
	[topView setChannel:chan];
	[navigationController.view insertSubview:panel atIndex:4];
	[((RCChatNavigationBar *)[navigationController navigationBar]) setTitle:[chan channelName]];
	NSString *sub = [net _description];
	if (![[net server] isEqualToString:[net _description]])
		sub = [NSString stringWithFormat:@"%@ – %@", [net _description], [net server]];
	[((RCChatNavigationBar *)[navigationController navigationBar]) setSubtitle:sub];
	[((RCChatNavigationBar *)[navigationController navigationBar]) setNeedsDisplay];
	if (navigationController.view.frame.origin.x > 0)
		[self menuButtonPressed:nil];
}

- (CGFloat)suggestionLocation {
	return 184;
}

@end
