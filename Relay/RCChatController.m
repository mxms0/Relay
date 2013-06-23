//
//  RCChatController.m
//  Relay
//
//  Created by Max Shavrick on 10/26/12.
//

#import "RCChatController.h"
#import "RCXLChatController.h"
#import "RCPrettyActionSheet.h"
#import "RCAddNetworkController.h"

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
		_inst = self;
		[self layoutWithRootViewController:rc];
	}
	return _inst;
}

- (void)setDefaultTitleAndSubtitle {
	[[chatView navigationBar] setTitle:@"Relay"];
	[[chatView navigationBar] setSubtitle:@"Welcome to Relay"];
	[[chatView navigationBar] setNeedsDisplay];
}

- (void)userPanned:(UIPanGestureRecognizer *)pan {
	if (pan.state == UIGestureRecognizerStateChanged) {
		CGPoint tr = [pan translationInView:[chatView superview]];
		CGPoint centr = CGPointMake([chatView center].x +tr.x, [chatView center].y);
		if (draggingUserList && [infoView frame].origin.x > [infoView frame].size.width) {
			draggingUserList = NO;
		}
#if LOGALL
		NSLog(@"HI I AM @ %f", centr.x);
#endif
		if (centr.x < 157 || draggingUserList) {
			draggingUserList = YES;
			[infoView setCenter:CGPointMake([infoView center].x+tr.x, [infoView center].y)];
			[pan setTranslation:CGPointZero inView:[chatView superview]];
			return;
		}
		if (!draggingUserList) {
			if (canDragMainView) {
				//	if (centr.x <= 595 && centr.x > 285) {
				[chatView setCenter:centr];
				[pan setTranslation:CGPointZero inView:[chatView superview]];
				//}
			}
		}
	}
	else if (pan.state == UIGestureRecognizerStateEnded) {
		if (draggingUserList) {
			if ([pan velocityInView:[chatView superview]].x > 0) {
				[self popUserListWithDuration:0.30];
			}
			else {
				[self pushUserListWithDuration:0.30];
			}
		}
		else {
			if (!canDragMainView) return;
			if ([pan velocityInView:chatView.superview].x > 0) {
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

- (void)layoutWithRootViewController:(RCViewController *)rc {
	currentPanel = nil;
	rootView = rc;
	canDragMainView = YES;
	int offx = 0;
	if (isiOS7)
		offx = 20;
	CGSize frame = [[UIScreen mainScreen] applicationFrame].size;
	bottomView = [[RCChatsListViewCard alloc] initWithFrame:CGRectMake(0, offx, frame.width, frame.height)];
	[rc.view insertSubview:bottomView atIndex:0];
	chatView = [[RCViewCard alloc] initWithFrame:CGRectMake(0, offx, frame.width, frame.height)];
	[rc.view insertSubview:chatView atIndex:1];
	infoView = [[RCTopViewCard alloc] initWithFrame:CGRectMake(frame.width, offx, frame.width, frame.height)];
	[rc.view insertSubview:infoView atIndex:2];
	UIPanGestureRecognizer *pg = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userPanned:)];
	[rc.view addGestureRecognizer:pg];
	[pg release];
	chatViewHeights[0] = frame.height-83;
	chatViewHeights[1] = frame.height-299;
	[self setDefaultTitleAndSubtitle];
	[[bottomView navigationBar] setTitle:@"Chats"];
	[[bottomView navigationBar] setSuperSpecialLikeAc3xx2:YES];
	[[infoView navigationBar] setTitle:@"Memberlist"];
	[[infoView navigationBar] setSuperSpecialLikeAc3xx2:YES];
	_bar = [[RCTextFieldBackgroundView alloc] initWithFrame:CGRectMake(0, 800, 320, 40)];
	//[_bar setOpaque:YES];
	[_bar setOpaque:NO];
	field = [[RCTextField alloc] initWithFrame:CGRectMake(15, 7, 299, 31)];
	[field setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
	[field setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	[field setReturnKeyType:UIReturnKeySend];
	[field setTextColor:UIColorFromRGB(0x3E3F3F)];
	[field setFont:[UIFont fontWithName:@"Helvetica" size:12]];
	[field setMinimumFontSize:17];
	[field setAdjustsFontSizeToFitWidth:YES];
	[field setDelegate:self];
	[field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[field setAutocorrectionType:UITextAutocorrectionTypeNo];
	[field setClearButtonMode:UITextFieldViewModeWhileEditing];
	[_bar addSubview:field];
	[field release];
	suggestLocation = [self suggestionLocation];;
}

- (void)correctSubviewFrames {
	CGSize fsize = [[UIScreen mainScreen] applicationFrame].size;
	[bottomView setFrame:CGRectMake(0, bottomView.frame.origin.y, fsize.width, fsize.height)];
	[chatView setFrame:CGRectMake(0, chatView.frame.origin.y, fsize.width, fsize.height)];
	canDragMainView = YES;
	[self setEntryFieldEnabled:YES];
	[currentPanel setFrame:CGRectMake(currentPanel.frame.origin.x, currentPanel.frame.origin.y, fsize.width, fsize.height)];
	/*
	[[[[navigationController topViewController] navigationItem] leftBarButtonItem] setEnabled:YES];
	 */
	[UIView animateWithDuration:0.25 animations:^ {
		[infoView setFrame:CGRectMake(infoView.frame.size.width, infoView.frame.origin.y, infoView.frame.size.width, infoView.frame.size.height)];
	} completion:^(BOOL fin) {
		[infoView findShadowAndDoStuffToIt];
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
	if ([string rangeOfString:@" "].location != NSNotFound) nickSuggestionDisabled = NO;
	if (nickSuggestionDisabled) return YES;
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
					[chatView insertSubview:[RCNickSuggestionView sharedInstance] atIndex:5];
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
	return [UIApp statusBarFrame].size.width > 320;
}

- (void)menuButtonPressed:(id)unused {
	[self menuButtonPressed:unused withSpeed:0.25];
}

- (void)menuButtonPressed:(id)unused withSpeed:(NSTimeInterval)sped {
	[currentPanel resignFirstResponder];
	CGRect frame = chatView.frame;
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
	currentNetwork = [[arg1 superview] net];
	RCPrettyActionSheet *sheet = [[RCPrettyActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"What do you want to do for %@?", [currentNetwork _description]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Edit", ([currentNetwork isTryingToConnectOrConnected] ? @"Disconnect" : @"Connect"), nil];
	[sheet setButtonCount:4];
	[sheet showInView:[[((RCAppDelegate *)[UIApp delegate]) navigationController] view]];
	[sheet release];
}

- (void)presentViewControllerInMainViewController:(UIViewController *)hi {
	UIViewController *rc = [((RCAppDelegate *)[[UIApplication sharedApplication] delegate]) navigationController];
	UINavigationController *ctrl = [[UINavigationController alloc] initWithRootViewController:hi];
	[ctrl setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
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

- (void)presentInitialSetupView {
	return;
	RCInitialSetupView *sv = [[RCInitialSetupView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[sv prepareForDisplay];
	[sv setWindowLevel:7777];
	[sv setHidden:NO];
	[sv setAlpha:5.0];
}

- (void)nickSuggestionCancelled {
	nickSuggestionDisabled = YES;
	[[RCNickSuggestionView sharedInstance] dismiss];
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
				[[NSNotificationCenter defaultCenter] postNotificationName:@"us.mxms.relay.del" object:[currentNetwork uUID]];
				currentNetwork = nil;
			}
			break;
		default:
			break;
	}
}

- (void)closeWithDuration:(NSTimeInterval)dr {
	[UIView animateWithDuration:dr animations:^{
		[chatView setFrame:CGRectMake(0, chatView.frame.origin.y, chatView.frame.size.width, chatView.frame.size.height)];
	} completion:^(BOOL fin) {
		[self setEntryFieldEnabled:YES];
		[chatView findShadowAndDoStuffToIt];
	}];
}

- (void)openWithDuration:(NSTimeInterval)dr {
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:dr];
	[chatView setFrame:CGRectMake(267, chatView.frame.origin.y, chatView.frame.size.width, chatView.frame.size.height)];
	[chatView findShadowAndDoStuffToIt];
	[UIView commitAnimations];
	
	//	[currentPanel resignFirstResponder];
	[self setEntryFieldEnabled:NO];
	[self dismissMenuOptions];
}

- (void)pushUserListWithDuration:(NSTimeInterval)dr {
	RCChannel *channel = [currentPanel channel];
	if ([channel isKindOfClass:[RCPMChannel class]]) {
	//	[topView showUserInfoPanel];
		[((RCChatNavigationBar *)[infoView navigationBar]) setSubtitle:nil];
	}
	else if ([channel isKindOfClass:[RCConsoleChannel class]]) {
		[((RCChatNavigationBar *)[infoView navigationBar]) setSubtitle:nil];
	//	[topView showUserListPanel];
	}
	else if ([channel isKindOfClass:[RCChannel class]]) {
		[[infoView navigationBar] setSubtitle:[NSString stringWithFormat:@"%d users in %@", [[channel fullUserList] count], [channel channelName]]];
	//	[topView showUserListPanel];
	}
	[[infoView navigationBar] setNeedsDisplay];
	[infoView reloadData];
	canDragMainView = NO;
	[self closeWithDuration:0.00];
	
	//[[[[navigationController topViewController] navigationItem] leftBarButtonItem] setEnabled:NO];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:dr];
	[infoView setFrame:CGRectMake(52, infoView.frame.origin.y, infoView.frame.size.width, infoView.frame.size.height)];
	[infoView findShadowAndDoStuffToIt];
	[UIView commitAnimations];
	[currentPanel resignFirstResponder];
	[self setEntryFieldEnabled:NO];
	[self dismissMenuOptions];
}

- (void)popUserListWithDuration:(NSTimeInterval)dr {
	canDragMainView = YES;
	[self setEntryFieldEnabled:YES];
	//[[[[navigationController topViewController] navigationItem] leftBarButtonItem] setEnabled:YES];
	[UIView animateWithDuration:dr animations:^ {
		[infoView setFrame:CGRectMake(infoView.frame.size.width, infoView.frame.origin.y, infoView.frame.size.width, infoView.frame.size.height)];
	} completion:^(BOOL fin) {
		[infoView findShadowAndDoStuffToIt];
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
		CGPoint tr = [pan translationInView:[chatView superview]];
		CGPoint cr = CGPointMake([infoView center].x + tr.x, infoView.center.y);
		if (cr.x >= 180) {
			[infoView setCenter:cr];
			[pan setTranslation:CGPointZero inView:[chatView superview]];
		}
	}
	else if (pan.state == UIGestureRecognizerStateEnded) {
		if ([pan velocityInView:[chatView superview]].x > 0) {
			[self popUserListWithDuration:0.30];
		}
		else {
			[self pushUserListWithDuration:0.30];
		}
	}
}

- (void)bottomLayerSwiped:(UIPanGestureRecognizer *)pan {
	if (pan.state == UIGestureRecognizerStateChanged) {
		CGPoint tr = [pan translationInView:[chatView superview]];
		CGPoint cr = CGPointMake([chatView center].x + tr.x, chatView.center.y);
		if (cr.x >= 180) {
			[chatView setCenter:cr];
			[pan setTranslation:CGPointZero inView:[chatView superview]];
		}
	}
	else if (pan.state == UIGestureRecognizerStateEnded) {
		if ([pan velocityInView:[chatView superview]].x > 0) {
			[self openWithDuration:0.30];
		}
		else {
			[self closeWithDuration:0.30];
		}
	}
}


- (void)userSwiped_specialLikeFr0st:(UIPanGestureRecognizer *)pan {
	if (![self isLandscape]) {
		[self userPanned:pan];
		return;
	}
	if (pan.state == UIGestureRecognizerStateBegan) {
		
		
	}
	else if (pan.state == UIGestureRecognizerStateEnded) {
		
	}
}

- (void)cleanLayersAndMakeMainChatVisible {
	[self popUserListWithDuration:0.00];
	[self closeWithDuration:0.30];
}

- (void)showMenuOptions:(id)unused {
	if ([[currentPanel channel] isKindOfClass:[RCConsoleChannel class]]) return;
	RCChatNavigationBar *rc = (RCChatNavigationBar *)[chatView navigationBar];
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
	RCChatNavigationBar *rc = (RCChatNavigationBar *)[chatView navigationBar];
	for (UIButton *subv in [rc subviews]) {
		if (![subv isKindOfClass:[RCBarButtonItem class]]) {
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
	CGPoint translation = [pan translationInView:[chatView superview]];
	return fabs(translation.x) > fabs(translation.y);
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)oi {
	[UIViewController attemptRotationToDeviceOrientation];
	[self correctSubviewFrames];
	// hi.
}

- (BOOL)isShowingChatListView {
	return (chatView.frame.origin.x > 0);
}

- (void)reloadUserCount {
	RCChannel *chan = [currentPanel channel];
	if ([chan isKindOfClass:[RCPMChannel class]] || [chan isKindOfClass:[RCConsoleChannel class]])
		return;
	[[infoView navigationBar] setSubtitle:[NSString stringWithFormat:@"%d users in %@", [[chan fullUserList] count], [chan channelName]]];
	[[infoView navigationBar] setNeedsDisplay];
}

- (void)selectChannel:(NSString *)channel fromNetwork:(RCNetwork *)_net {
	for (UIView *subv in [chatView subviews]) {
		if ([subv isKindOfClass:[RCChatPanel class]])
			[subv removeFromSuperview];
	}
	[field resignFirstResponder];
	[self setEntryFieldEnabled:YES];
	RCNetwork *net = _net;
	if (!_net) net = [[currentPanel channel] delegate];
	RCChannel *chan = [net channelWithChannelName:channel];
	[chan setNewMessageCount:0];
	[((RCChatNavigationBar *)[chatView navigationBar]) setNeedsDisplay];
	if (!chan) {
		NSLog(@"AN ERROR OCCURED. THIS CHANNEL DOES NOT EXIST BUT IS IN THE TABLE VIEW ANYWAYS.");
		return;
	}
	RCChatPanel *panel = [chan panel];
	[panel setFrame:CGRectMake(0, 43, 320, chatViewHeights[0])];
	[_bar setFrame:CGRectMake(0, panel.frame.origin.y+panel.frame.size.height, _bar.frame.size.width, _bar.frame.size.height)];
	currentPanel = panel;
	[infoView setChannel:chan];
	[chatView insertSubview:panel atIndex:4];
	[((RCChatNavigationBar *)[chatView navigationBar]) setTitle:[chan channelName]];
	NSString *sub = [net _description];
	if (![[net server] isEqualToString:[net _description]])
		sub = [NSString stringWithFormat:@"%@ – %@", [net _description], [net server]];
	[((RCChatNavigationBar *)[chatView navigationBar]) setSubtitle:sub];
	[((RCChatNavigationBar *)[chatView navigationBar]) setNeedsDisplay];
	if (chatView.frame.origin.x > 0)
		[self menuButtonPressed:nil];
	if (!_bar.superview)
		[chatView insertSubview:_bar atIndex:[[chatView subviews] count]];
}

- (CGFloat)suggestionLocation {
	return 184;
}

@end
