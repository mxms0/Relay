//
//  RCNavigator.m
//  Relay
//
//  Created by Max Shavrick on 2/25/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCNavigator.h"
#import "RCNetworkManager.h"
#import "RCAddNetworkController.h"

@implementation RCNavigator
@synthesize currentPanel, memberPanel, _isLandscape, titleLabel, currentNetwork;
static id _sharedNavigator = nil;

- (id)init {
	return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_rcViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
		if ([_rcViewController isKindOfClass:[UINavigationController class]])
			_rcViewController = [_rcViewController topViewController];
		isFirstSetup = NO;
		_isLandscape = NO;
		window = [RCPopoverWindow sharedPopover];
		memberPanel = [[RCUserListPanel alloc] initWithFrame:CGRectMake(0, 77, 320, 383)];
		memberPanel.backgroundColor = [UIColor clearColor];
		memberPanel.separatorStyle = UITableViewCellSeparatorStyleNone;
		bar = [[RCNavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
        [bar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"0_navbar"]]];
		bar.tag = 100;
		titleLabel = [[RCTitleLabel alloc] initWithFrame:CGRectMake(60, 0, 200, bar.frame.size.height)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setHidden:NO];
		[titleLabel setFont:[UIFont boldSystemFontOfSize:25]];
		UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(editNetwork:)];
		[gesture setMinimumPressDuration:0.7];
		[gesture setNumberOfTapsRequired:0];
		[titleLabel addGestureRecognizer:gesture];
		[gesture release];
		UITapGestureRecognizer *dble = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNetworkPopover:)];
		[dble setNumberOfTapsRequired:1];
		[titleLabel addGestureRecognizer:dble];
		[dble release];
		[bar addSubview:titleLabel];
		[titleLabel release];
		scrollBar = [[RCChannelScrollView alloc] initWithFrame:CGRectMake(0, 45, 320, 32)];
		scrollBar.tag = 200;
		[self addSubview:scrollBar];
		[scrollBar release];
		[self addSubview:bar];
        plus = [[RCBarButton alloc] initWithFrame:[self frameForPlusButton]];
        listr = [[RCBarButton alloc] initWithFrame:[self frameForListButton]];
        [plus setTitle:@"+" forState:UIControlStateNormal];
		[plus setImage:[UIImage imageNamed:@"0_plusbtn"] forState:UIControlStateNormal];
		[plus setImage:[UIImage imageNamed:@"0_plusbtn_pressed"] forState:UIControlStateHighlighted];
		[listr setImage:[UIImage imageNamed:@"0_listrbtn"] forState:UIControlStateNormal];
		[listr setImage:[UIImage imageNamed:@"0_listrbtn_pressed"] forState:UIControlStateHighlighted];
        [bar addSubview:plus];
        [plus addTarget:self action:@selector(presentAddNetworkController) forControlEvents:UIControlEventTouchUpInside];
		[listr addTarget:self action:@selector(presentChannelManagementController) forControlEvents:UIControlEventTouchUpInside];
        [bar addSubview:listr];
        [plus release];
        [listr release];
		[bar release];
		[self bringSubviewToFront:scrollBar];
    }
	_sharedNavigator = self;
    return _sharedNavigator;
}

- (void)presentChannelManagementController {

}

- (void)presentViewControllerInMainViewController:(UIViewController *)hi {
	UIViewController *rc = [((RCAppDelegate *)[[UIApplication sharedApplication] delegate]) navigationController];
	UINavigationController *ctrl = [[UINavigationController alloc] initWithRootViewController:hi];
	[ctrl setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
	[rc presentModalViewController:ctrl animated:YES];
	[ctrl release];
}

- (void)presentAddNetworkController {
    RCAddNetworkController *ctrlr = [[RCAddNetworkController alloc] initWithNetwork:nil];
	[self presentViewControllerInMainViewController:ctrlr];
    [ctrlr release];
}

- (void)addChannel:(NSString *)chan toServer:(RCNetwork *)net {
	if (![chan isEqualToString:@""] && ![chan isEqualToString:@" "]) {
		RCChannelBubble *bubble = [self channelBubbleWithChannelName:chan];
		[[net _bubbles] insertObject:bubble atIndex:([[net _bubbles] count])];
		[bubble release];
		[[net channelWithChannelName:chan] setBubble:bubble];
	}
	if (currentNetwork)
		if ([[net description] isEqualToString:[currentNetwork description]])
			[scrollBar layoutChannels:[currentNetwork _bubbles]];
}

- (void)removeChannel:(RCChannel *)chan fromServer:(RCNetwork *)net {
	for (RCChannelBubble *bb in [net _bubbles]) {
		if ([[[chan channelName] lowercaseString] isEqualToString:[[[bb titleLabel] text] lowercaseString]]) {
			if ([bb _selected]) {
				[currentPanel removeFromSuperview];
				currentPanel = nil;
			}
			[[net _bubbles] removeObject:bb];
			break;
		}
	}
	if ([[[((RCChannel *)memberPanel.delegate) channelName] lowercaseString] isEqualToString:[[chan channelName] lowercaseString]]) {
		memberPanel.delegate = nil;
		memberPanel.dataSource = nil;
		[memberPanel removeFromSuperview];
	}
	if ([[net description] isEqualToString:[currentNetwork description]]) {
		[scrollBar performSelectorOnMainThread:@selector(layoutChannels:) withObject:[currentNetwork _bubbles] waitUntilDone:NO];
	}
}

- (void)addNetwork:(RCNetwork *)net	{
	if (!net) {
		NSLog(@"Dear haxor, an argument goes here. %s", __PRETTY_FUNCTION__);
		return;
	}
	// definitely removing this whole construction 
	// sometime soon/
	// can't stand this ugly mess.
    if (isFirstSetup) {
		for (RCNetwork *net in [[RCNetworkManager sharedNetworkManager] networks]) {
			if ([net isKindOfClass:[RCWelcomeNetwork class]]) {
				[[RCNetworkManager sharedNetworkManager] removeNet:net];
				break;
			}
		}
        titleLabel.text = nil;
        currentNetwork = nil;
        [currentPanel removeFromSuperview];
        currentPanel = nil;
    }
	isFirstSetup = ([net isKindOfClass:[RCWelcomeNetwork class]]);
    if (!isFirstSetup) {
        
    }
	if (titleLabel.text == nil || ([titleLabel.text isEqualToString:@""])) {
		[titleLabel setText:[net _description]];
		currentNetwork = net;
	}
	for (NSString *chan in [[net _channels] allKeys]) {
		[self addChannel:chan toServer:net];
	}
}

- (void)showNetworkPopover:(UIGestureRecognizer *)gerk {
	[self presentNetworkPopover];
}

- (void)dismissNetworkPopover {
	[window animateOut];
	// never used.
	// may be needed later on.
}

- (void)presentNetworkPopover {
    if (!isFirstSetup) {
        [window setFrame:CGRectMake(0, 0, 320, 480)];
        [window reloadData];
        [window animateIn];
    }
}

- (void)editNetwork:(UIGestureRecognizer *)recog {
    if (isFirstSetup) return;
	if (recog.state == UIGestureRecognizerStateBegan) {
		RCNetwork *net = [[RCNetworkManager sharedNetworkManager] networkWithDescription:[(UILabel *)[recog view] text]];
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"What do you want to do for %@", [currentNetwork _description]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Edit", ([net isConnected] ? @"Disconnect" : @"Connect"), nil];
		[sheet showInView:self];
		[sheet release];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		// delete.
	//	currentIndex--;
		[currentPanel removeFromSuperview];
		currentPanel = nil;
		[scrollBar layoutChannels:nil];
		titleLabel.text = nil;
		[[RCNetworkManager sharedNetworkManager] removeNet:currentNetwork];
		currentNetwork = nil;
	}
	else if (buttonIndex == 1) {
		RCNetwork *net = currentNetwork;
		UIViewController *rc = [((RCAppDelegate *)[[UIApplication sharedApplication] delegate]) navigationController];
		RCAddNetworkController *ctrlr = [[RCAddNetworkController alloc] initWithNetwork:net];
		UINavigationController *ctrl = [[UINavigationController alloc] initWithRootViewController:ctrlr];
		[ctrl setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
		[rc presentModalViewController:ctrl animated:YES];
		[ctrlr release];
		[ctrl release];

		// edit.
	}
	else if (buttonIndex == 2) {
		if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Disconnect"]) [currentNetwork disconnect];
		else {
			[currentNetwork connect];
            [self channelSelected:[[currentNetwork channelWithChannelName:@"IRC"] bubble]];
		}
		//connect
	}
	else if (buttonIndex == 4) {
		// cancel.
		// kbye
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	isShowing = NO;
	switch (buttonIndex) {
		case 1: {
			[currentNetwork removeChannel:[currentNetwork channelWithChannelName:[[questionabubble titleLabel] text]]];		
			break;
		}
		case 0:
			break;
	}
}

- (RCChannelBubble *)channelBubbleWithChannelName:(NSString *)name {
	CGSize size = [name sizeWithFont:[UIFont boldSystemFontOfSize:14]];
	RCChannelBubble *bubble = [[RCChannelBubble alloc] initWithFrame:CGRectMake(0, 0, size.width+=14, 18)];
	[bubble addTarget:self action:@selector(channelSelected:) forControlEvents:UIControlEventTouchUpInside];
	[bubble setTitle:name forState:UIControlStateNormal];
	return bubble;
}

- (void)tearDownForChannelList:(RCChannelBubble *)bubble {
	if (![[[currentPanel channel] bubble] isEqual:bubble]) {
		[self channelSelected:bubble];
	}
	RCChannel *chan = [[currentNetwork _channels] objectForKey:[[bubble titleLabel] text]];
	memberPanel.delegate = chan;
	memberPanel.dataSource = chan;
	memberPanel.frame = [self frameForMemberPanel];
	chan.usersPanel = memberPanel;
	[currentPanel removeFromSuperview];
	[self addSubview:memberPanel];
}

- (void)selectNetwork:(RCNetwork *)net {
	currentNetwork = net;
	titleLabel.text = [net _description];
	[scrollBar layoutChannels:[net _bubbles]];
    [self channelSelected:[[net channelWithChannelName:@"IRC"] bubble]];
}

static RCChannelBubble *questionabubble = nil;

- (void)channelWantsSuicide:(RCChannelBubble *)bubble {
	if (!isShowing) {
		isShowing = YES;
		questionabubble = bubble;
		[self performSelectorOnMainThread:@selector(doSuicideConfirmationAlert:) withObject:bubble waitUntilDone:YES];
	}
}

- (void)doSuicideConfirmationAlert:(RCChannelBubble *)questionAble {
	RCPrettyAlertView *alert = [[RCPrettyAlertView alloc] initWithTitle:@"Are you sure?" message:[NSString stringWithFormat:@"Are you sure you want to delete %@", [questionAble titleLabel].text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
	[alert show];
	[alert release];
	
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)channelSelected:(RCChannelBubble *)bubble {
	if (memberPanel.delegate != nil) {
		if (currentPanel != nil) 
			 [[[currentPanel channel] bubble] _setSelected:NO];
		[memberPanel removeFromSuperview];
		memberPanel.delegate = nil;
		memberPanel.dataSource = nil;
		currentPanel = nil;
	}
	if (currentPanel != nil) if ([[[currentPanel channel] bubble] isEqual:bubble]) return;
	[[[currentPanel channel] bubble] _setSelected:NO];
	[bubble _setSelected:YES];
	RCChannel *chan = [currentNetwork channelWithChannelName:bubble.titleLabel.text]; // unneeded. <.<
	if (chan) {
		if ([currentPanel isFirstResponder])
			[[chan panel] becomeFirstResponderNoAnimate];
		if (currentPanel) {
			[currentPanel removeFromSuperview];
		}
		[[chan panel] setFrame:(currentPanel ? [currentPanel frame] : [self frameForChatTable])];
        [[chan panel] didPresentView];
		[self insertSubview:[chan panel] belowSubview:scrollBar];
		currentPanel = [chan panel];
		// if this fails, UIApplication->statusBarOrientation
	}
	else {
		NSLog(@"WTF THE CHANNEL EXISTS, BUT THE RCCHANNELL DOESN'T. FR0ST FIX IT");
	}
}

+ (id)sharedNavigator {
	if (!_sharedNavigator) _sharedNavigator = [[self alloc] init];
	return _sharedNavigator;
}

- (void)drawRect:(CGRect)rect {
	@autoreleasepool {
		if (_isLandscape) {
			UIImage *bg = [UIImage imageNamed:@"0_bg"];
			[bg drawInRect:CGRectMake(0, 32, 480, 300)];
		}
		else {
			UIImage *bg = [UIImage imageNamed:@"0_bg"];
			[bg drawInRect:CGRectMake(0, 45, 320, 426)];
		}
	}
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)oi {
	_isLandscape = (UIInterfaceOrientationIsLandscape(oi));
	[scrollBar drawBG];
	[self setNeedsDisplay];
	if (currentPanel) {
		[currentPanel setFrame:[self frameForChatTable]];
	}
	if (_isLandscape) {
		bar.frame = CGRectMake(0, 0, 480, 32);
		bar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"0_navbar_landscape"]];
		scrollBar.frame = CGRectMake(240, 0, 233, 33); // 233, for the hell of it.
		[scrollBar clearBG];
		for (CALayer *lv in [scrollBar.layer sublayers]) {
			if ([lv isKindOfClass:[RCShadowLayer class]]) {
				[lv setFrame:CGRectMake((bar.frame.size.width/2)*-1, lv.frame.origin.y, 480, lv.frame.size.height)];
				break;
			}
		}
	}
	else {
		bar.frame = CGRectMake(0, 0, 320, 45);
		bar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"0_navbar"]];
		scrollBar.frame = CGRectMake(0, 45, 320, 32);
		for (CALayer *lv in [scrollBar.layer sublayers]) {
			if ([lv isKindOfClass:[RCShadowLayer class]]) {
				[lv setFrame:CGRectMake(0, lv.frame.origin.y, 320, lv.frame.size.height)];
			}
		}
	}
	[plus setFrame:[self frameForPlusButton]];
	[listr setFrame:[self frameForListButton]];
	[titleLabel setFrame:CGRectMake(60, 0, [self widthForTitleLabel], bar.frame.size.height)];
	[memberPanel setFrame:[self frameForMemberPanel]];
	[window correctAndRotateToInterfaceOrientation:oi];
}

- (CGFloat)widthForTitleLabel {
	if (_isLandscape) 
		return 140;
	return 200;
}

- (CGFloat)heightForNetworkBar {
	if (_isLandscape)
		return 33;
	return 45;
}

- (CGFloat)widthForNetworkBar {
	if (_isLandscape)
		return 120;
	return 320;
}

- (CGRect)frameForChatTable {
	if (_isLandscape)
		return CGRectMake(0, 32, 480, 227);
	return CGRectMake(0, 77, 320, 344);
}

- (CGRect)frameForMemberPanel {
	if (_isLandscape)
		return CGRectMake(0, 33, 480, 267);
	return CGRectMake(0, 77, 320, 383);
}

- (CGRect)frameForListButton {
	if (_isLandscape) 
		return CGRectMake(3, 2, 40, 30);
    return CGRectMake(5, 5, 40, 35);
}
- (CGRect)frameForPlusButton {
	if (_isLandscape)
		return CGRectMake(197, 2, 40, 30);
    return CGRectMake(275, 5, 40, 35);
}

- (void)dealloc {
	[bar release];
	[super dealloc];
}

@end
