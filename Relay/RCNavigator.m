//
//  RCNavigator.m
//  Relay
//
//  Created by Max Shavrick on 2/25/12.
//

#import "RCNavigator.h"
#import "RCNetworkManager.h"
#import "RCAddNetworkController.h"
#import "RCLargeNavigator.h"

@implementation RCNavigator
@synthesize currentPanel, memberPanel, _isLandscape, titleLabel, currentNetwork, cover, nWindow;
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
		nWindow = [[RCPopoverWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
		memberPanel = [[RCUserListPanel alloc] initWithFrame:CGRectMake(0, 77, 320, 383)];
		memberPanel.backgroundColor = [UIColor clearColor];
		memberPanel.separatorStyle = UITableViewCellSeparatorStyleNone;
		bar = [[RCNavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 45)];
        [bar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"0_navbar"]]];
		bar.tag = 100;
		titleLabel = [[RCTitleLabel alloc] initWithFrame:CGRectMake(47, 0, 225, bar.frame.size.height)];
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setHidden:NO];
		[titleLabel setFont:[UIFont boldSystemFontOfSize:25]];
		UITapGestureRecognizer *dble = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNetworkPopover:)];
		[dble setNumberOfTapsRequired:1];
		[titleLabel addGestureRecognizer:dble];
		[dble release];
		[bar addSubview:titleLabel];
		[titleLabel release];
		scrollBar = [[RCChannelScrollView alloc] initWithFrame:CGRectMake(0, 45, 320, 44)];
		scrollBar.tag = 200;
		[self addSubview:scrollBar];
		[scrollBar release];
		[self addSubview:bar];
        plus = [[RCBarButton alloc] initWithFrame:[self frameForPlusButton]];
        listr = [[RCBarButton alloc] initWithFrame:[self frameForListButton]];
		plus.exclusiveTouch = YES;
		listr.exclusiveTouch = YES;
        [plus setTitle:@"+" forState:UIControlStateNormal];
		[plus setImage:[UIImage imageNamed:@"0_plusbtn"] forState:UIControlStateNormal];
		[plus setImage:[UIImage imageNamed:@"0_plusbtn_pressed"] forState:UIControlStateHighlighted];
		[listr setImage:[UIImage imageNamed:@"0_listrbtn"] forState:UIControlStateNormal];
		[listr setImage:[UIImage imageNamed:@"0_listrbtn_pressed"] forState:UIControlStateHighlighted];
        [bar addSubview:plus];
        [plus addTarget:self action:@selector(presentAddNetworkController) forControlEvents:UIControlEventTouchUpInside];
		[listr addTarget:self action:@selector(editNetwork) forControlEvents:UIControlEventTouchUpInside];
        [bar addSubview:listr];
        [plus release];
        [listr release];
		[bar release];
		[self bringSubviewToFront:scrollBar];
    }
	_sharedNavigator = self;
    return _sharedNavigator;
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
		RCChannelBubble *bubble = [self channelBubbleWithChannel:[net channelWithChannelName:chan]];
		[[net _bubbles] insertObject:bubble atIndex:([[net _bubbles] count])];
	}
	if (currentNetwork)
		if ([[net description] isEqualToString:[currentNetwork description]])
			[scrollBar layoutChannels:[currentNetwork _bubbles]];
}

- (void)removeChannel:(RCChannel *)chan fromServer:(RCNetwork *)net {
	for (RCChannelBubble *bb in [net _bubbles]) {
		if ([[[chan channelName] lowercaseString] isEqualToString:[[[bb titleLabel] text] lowercaseString]]) {
			if ([bb isSelected]) {
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
	if (isFirstSetup) {
		[listr setEnabled:NO];
	}
	else {
		[listr setEnabled:YES];
	}
	if (titleLabel.text == nil || ([titleLabel.text isEqualToString:@""])) {
		[titleLabel setText:[net _description]];
		currentNetwork = net;
	}
	for (RCChannel *chan in [net _channels]) {
		[self addChannel:[chan channelName] toServer:net];
	}
}

- (void)showNetworkPopover:(UIGestureRecognizer *)gerk {
	[self presentNetworkPopover];
}

- (void)dismissNetworkPopover {
	[nWindow animateOut];
	// never used.
	// may be needed later on.
}

- (void)presentNetworkPopover {
    if (!isFirstSetup) {
        [nWindow setFrame:CGRectMake(0, 0, (_isLandscape ? 480 : 320), (_isLandscape ? 320 : 480))];
        [nWindow reloadData];
		[self addSubview:nWindow];
		[self bringSubviewToFront:nWindow];
        [nWindow animateIn];
		if (currentPanel) {
			[nWindow setShouldRePresentKeyboardOnDismiss:[currentPanel isFirstResponder]];
			[currentPanel resignFirstResponder];
		}
    }
}

- (void)editNetwork {
    if (isFirstSetup) return;
	RCPrettyActionSheet *sheet = [[RCPrettyActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"What do you want to do for %@?", [currentNetwork _description]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Edit", ([currentNetwork isTryingToConnectOrConnected] ? @"Disconnect" : @"Connect"), nil];
	[sheet showInView:self];
	[sheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		// delete.
	//	currentIndex--;
		[currentPanel removeFromSuperview];
		currentPanel = nil;
		[scrollBar layoutChannels:nil];
		titleLabel.text = nil;
        CGSize available = CGSizeMake([self widthForTitleLabel]-[self frameForListButton].size.width-[self frameForPlusButton].size.width-30.0f, [self heightForNetworkBar]);
        CGSize really_av = [titleLabel sizeThatFits:available];
        titleLabel.frame = CGRectMake(0,0,really_av.width, really_av.height);
        ((UIView*)titleLabel).center = CGPointMake([self widthForNetworkBar]/2.0f,[self heightForNetworkBar]/2.0f);
        [titleLabel layoutSubviews];
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
    switch ([alertView tag]) {
        case 13371:
            switch (buttonIndex) {
                case 1: {
                    [currentNetwork removeChannel:[currentNetwork channelWithChannelName:[[questionabubble titleLabel] text]]];		
                    break;
                }
                case 0:
                    break;
            }
            break;
        case 13372:
            switch (buttonIndex) {
                case 1: {
                    [[questionabubble channel] setJoined:YES withArgument:@""];		
                    break;
                }
                case 0:
                    break;
            }
            break;
            
        default:
            break;
    }
}

- (RCChannelBubble *)channelBubbleWithChannel:(RCChannel *)chan {
    if ([chan bubble]) {
        return [chan bubble];
    }
	CGSize size = [[chan channelName] sizeWithFont:[UIFont boldSystemFontOfSize:14]];
	RCChannelBubble *bubble = [[RCChannelBubble alloc] initWithFrame:CGRectMake(0, 0, size.width+=14, 32) andChan:chan];
	[bubble addTarget:self action:@selector(channelSelected:) forControlEvents:UIControlEventTouchUpInside];
	[bubble setTitle:[chan channelName] forState:UIControlStateNormal];
    [chan setBubble:bubble];
	return [bubble autorelease];
}

- (void)tearDownForChannelList:(RCChannelBubble *)bubble {
	if (![[[currentPanel channel] bubble] isEqual:bubble]) {
		[self channelSelected:bubble];
	}
	RCChannel *chan = [currentNetwork channelWithChannelName:[[bubble titleLabel] text]];
	memberPanel.delegate = chan;
	memberPanel.dataSource = chan;
	memberPanel.frame = [self frameForMemberPanel];
	chan.usersPanel = memberPanel;
	[currentPanel removeFromSuperview];
	currentPanel = nil;
	[self insertSubview:memberPanel atIndex:0];
}

- (void)selectNetwork:(RCNetwork *)net {
	@synchronized(self) {
		if (currentPanel) {
			[currentPanel removeFromSuperview];
			currentPanel = nil;
		}
		currentNetwork = net;
		[titleLabel setText:[net _description]];
		if (_isLandscape) {
			titleLabel.frame = CGRectMake(45, 0, 150, bar.frame.size.height);
		}
		else {
			titleLabel.frame = CGRectMake(47, 0, 225, bar.frame.size.height);
		}
		[scrollBar layoutChannels:[net _bubbles]];
		[self channelSelected:[[net currentChannel] bubble]];
		[self scrollToBubble:[[net currentChannel] bubble]];
	}
}

static RCChannelBubble *questionabubble = nil;

- (void)channelWantsSuicide:(RCChannelBubble *)bubble {
	if (!isShowing) {
		isShowing = YES;
		questionabubble = bubble;
		[self performSelectorOnMainThread:@selector(doSuicideConfirmationAlert:) withObject:bubble waitUntilDone:YES];
	}
}

- (void)scrollToBubble:(RCChannelBubble *)bubble {
    if (!(bubble && [bubble superview])) {
        return;
    }
    CGPoint point = bubble.frame.origin;
    point.y = 0;
    CGFloat slide = MIN(point.x, MAX(0, ((UIScrollView *)[bubble superview]).contentSize.width-[bubble superview].frame.size.width));
    point.x = slide;
    [(UIScrollView *)[bubble superview] setContentOffset:point animated:YES];
}

- (void)doSuicideConfirmationAlert:(RCChannelBubble *)questionAble {
	RCPrettyAlertView *alert = [[RCPrettyAlertView alloc] initWithTitle:@"Are you sure?" message:[NSString stringWithFormat:@"Are you sure you want to delete %@?", [questionAble titleLabel].text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
	[alert setTag:13371];
	[alert show];
	[alert release];
}

- (BOOL)canBecomeFirstResponder {
	return YES;
}

- (void)displayOptionsForChannel:(RCChannelBubble *)bbz {
	if (cover != nil) return;
	CGRect adj = CGRectMake(bbz.frame.origin.x-scrollBar.contentOffset.x, 0, bbz.frame.size.width, bbz.frame.size.height);
	self.cover = [[RCCoverView alloc] initWithFrame:[self frameForOptionsCover] andChannel:[bbz channel]];
	int fixy = 10;
	if (_isLandscape) fixy = 5;
	[cover setArrowPosition:CGPointMake((adj.origin.x+adj.size.width)-(bbz.frame.size.width/2)-6, scrollBar.frame.size.height+scrollBar.frame.origin.y-fixy)];
	[self insertSubview:cover atIndex:0];
	[self bringSubviewToFront:cover];
	[cover show];
	[cover release];
}

- (CGRect)frameForOptionsCover {
	if (_isLandscape)
		return CGRectMake(0, 0, 480, 320);
	else return CGRectMake(0, 0, 320, 480);
}

- (void)channelSelected:(RCChannelBubble *)bubble {
	if (memberPanel.delegate != nil) {
		if (currentPanel != nil) 
			 [[[currentPanel channel] bubble] _setSelected:NO];
		[memberPanel removeFromSuperview];
		[((RCChannel *)[memberPanel dataSource]) setUsersPanel:nil];
		memberPanel.delegate = nil;
		memberPanel.dataSource = nil;
		currentPanel = nil;
	}
	if (currentPanel) {
		if ([[[currentPanel channel] bubble] isEqual:bubble]) {
			if (![[bubble channel] isKindOfClass:[RCConsoleChannel class]] && ![[bubble channel] isKindOfClass:[RCWelcomeChannel class]])
				[self displayOptionsForChannel:bubble];
			return;
		}
	}
	for (RCChannel *chan in [currentNetwork _channels]) {
		[[chan bubble] _setSelected:NO];
	}
	[currentNetwork setCurrentChannel:[bubble channel]];
	[bubble _setSelected:YES];
	if (!currentNetwork) NSLog(@"NO CURRENT NETWORK");
	RCChannel *chan = [bubble channel];
	[[[bubble channel] panel] setFrame:[self frameForChatTable]];
	if (currentPanel) {
		[currentPanel removeFromSuperview];
		if ([currentPanel isFirstResponder])
			[[chan panel] becomeFirstResponderNoAnimate];
		// does not work perhaps due to adding to superview or someshit idfkx. meh btw cleaned up the logic here. :) 
	}
	[[chan panel] didPresentView];
	[self insertSubview:[chan panel] belowSubview:bar];
	currentPanel = [chan panel];
	// if this fails, UIApplication->statusBarOrientation
}

+ (id)sharedNavigator {
	if (!_sharedNavigator) {
		CGRect ff = [[UIScreen mainScreen] applicationFrame];
		if (ff.size.height > 480) {
			_sharedNavigator = [[RCLargeNavigator alloc] init];
		}
		else _sharedNavigator = [[self alloc] init];
	}
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

- (void)refreshTitleBar:(RCNetwork *)net {
	[self selectNetwork:net];
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)oi {
	[nWindow animateOut];
	[cover hide];
	_isLandscape = (UIInterfaceOrientationIsLandscape(oi));
	[self setNeedsDisplay];
	if (currentPanel) {
		[currentPanel setFrame:[self frameForChatTable]];
	}
	if (_isLandscape) {
		bar.frame = CGRectMake(0, 0, 480, 32);
		bar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"0_navbar_landscape"]];
		scrollBar.frame = CGRectMake(240, 0, 240, 33);
		titleLabel.frame = CGRectMake(45, 0, 150, bar.frame.size.height);
	}
	else {
		bar.frame = CGRectMake(0, 0, 320, 45);
		bar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"0_navbar"]];
		scrollBar.frame = CGRectMake(0, 45, 320, 44);
		titleLabel.frame = CGRectMake(47, 0, 225, bar.frame.size.height);
	}
	[[currentPanel mainView] scrollToBottom];
	[plus setFrame:[self frameForPlusButton]];
	[listr setFrame:[self frameForListButton]];
	[scrollBar setContentSize:(CGSize)(scrollBar.frame.size)];
	[scrollBar setNeedsDisplay];
	[scrollBar layoutChannels:[currentNetwork _bubbles]];
	[memberPanel setFrame:[self frameForMemberPanel]];
	[nWindow correctAndRotateToInterfaceOrientation:oi];
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
		return 240;
	return 320;
}

- (CGRect)frameForChatTable {
	if (_isLandscape)
		return CGRectMake(0, 32, 480, 227);
	return CGRectMake(0, bar.frame.size.height+scrollBar.frame.size.height, 320, 332);
}

- (CGRect)frameForMemberPanel {
	if (_isLandscape)
		return CGRectMake(0, 32, 480, 268);
	return CGRectMake(0, bar.frame.size.height+scrollBar.frame.size.height, 320, 371);
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

- (CGRect)frameForInputField:(BOOL)activ {
	if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
		return CGRectMake(0, (activ ? 66 : 227), 480, 40);
	}
	return CGRectMake(0, (activ ? 115 : 333), 320, 40);
}

- (void)dealloc {
	[bar release];
	[super dealloc];
}

@end
