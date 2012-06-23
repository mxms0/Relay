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
@synthesize currentPanel, memberPanel, _isLandscape, titleLabel;
static id _sharedNavigator = nil;

- (id)init {
	return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_rcViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
		if ([_rcViewController isKindOfClass:[UINavigationController class]])
			_rcViewController = [_rcViewController topViewController];
		isFirstSetup = -1;
		_isLandscape = NO;
		window = [[RCPopoverWindow alloc] initWithFrame:CGRectMake(0, 0, 320, 460)];
		memberPanel = [[RCUserListPanel alloc] initWithFrame:CGRectMake(0, 77, 320, 383)];
		memberPanel.backgroundColor = [UIColor clearColor];
		memberPanel.separatorStyle = UITableViewCellSeparatorStyleNone;
		leftGroup = [[RCBarGroup alloc] initWithFrame:CGRectMake(10, 7, 15, 29)];
		[self addSubview:leftGroup];
		[leftGroup release];
		rightGroup = [[RCBarGroup alloc] initWithFrame:CGRectMake(290, 7, 15, 29)];
		[self addSubview:rightGroup];
		[rightGroup release];
		bar = [[RCNavigationBar alloc] initWithFrame:CGRectMake(60, 0, 200, 45)];
		bar.tag = 100;
		titleLabel = [[RCTitleLabel alloc] initWithFrame:CGRectMake(0, 0, bar.frame.size.width, bar.frame.size.height)];
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
		[bar release];
    }
	_sharedNavigator = self;
    return _sharedNavigator;
}

- (void)addNetwork:(RCNetwork *)net	{
	if (!net) {
		NSLog(@"Dear haxor, an argument goes here. %s", __PRETTY_FUNCTION__);
		return;
	}
	if (isFirstSetup == -1) isFirstSetup = ([net isKindOfClass:[RCWelcomeNetwork class]] ? 1 : 0);
	if (isFirstSetup == 2) {
	//	[[[RCNetworkManager sharedNetworkManager] networks] removeObjectAtIndex:0];
	//	[[[bar subviews] objectAtIndex:netCount+1] removeFromSuperview];
	//	[scrollBar layoutChannels:nil];
	//	isFirstSetup = 0;
	//	[currentPanel removeFromSuperview];
	//	currentPanel = nil;
	//	[NSTimer scheduledTimerWithTimeInterval:120 target:[RCNetworkManager sharedNetworkManager] selector:@selector(saveChannelData:) userInfo:nil repeats:YES];
	//	isFirstSetup = -1;
	}
	if (isFirstSetup == 1) {
		// new network coming through, remove setup she-yite
		// useless comment above. means nothing at all.
		// do not remove it. evar.
		// if you do, this program will fail to compile.
		isFirstSetup = 2;
	}
	for (NSString *chan in [[net _channels] allKeys]) {
		if (![chan isEqualToString:@""] && ![chan isEqualToString:@" "]) {
			RCChannelBubble *bubble = [self channelBubbleWithChannelName:chan];
			[[net _bubbles] insertObject:bubble atIndex:([[net _bubbles] count])];
			[bubble release];
			[[[net _channels] objectForKey:chan] setBubble:bubble];
		}
	}
//	if (netCount == 1) {
//		[self channelSelected:[[[net _channels] objectForKey:@"IRC"] bubble]];
//	}
	if (titleLabel.text == nil || ([titleLabel.text isEqualToString:@""])) {
		[titleLabel setText:[net _description]];
		[scrollBar layoutChannels:[net _bubbles]];
		currentNetwork = net;
	}
}

- (void)showNetworkPopover:(UIGestureRecognizer *)gerk {
	if (_isShowingList) {
		[self dismissNetworkPopover];
	}
	else {
		[self presentNetworkPopover];
	}
}

- (void)dismissNetworkPopover {
	
}

- (void)presentNetworkPopover {
	[window animateIn];
	
}

static UILabel *active = nil;

- (void)editNetwork:(UIGestureRecognizer *)recog {
	active = (UILabel *)recog.view;
	if (recog.state == UIGestureRecognizerStateBegan) {
		RCNetwork *net = [[RCNetworkManager sharedNetworkManager] networkWithDescription:[(UILabel *)[recog view] text]];
		UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"What do you want to do for %@", [(UILabel *)[recog view] text]] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles:@"Edit", ([net isConnected] ? @"Disconnect" : @"Connect"), nil];
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
		RCNetwork *removr = [[RCNetworkManager sharedNetworkManager] networkWithDescription:active.text];
		[[RCNetworkManager sharedNetworkManager] removeNet:removr];
		[[RCNetworkManager sharedNetworkManager] saveNetworks];
	//	if (netCount == 0) {
	//		[scrollBar layoutChannels:nil];
	//		[[RCNetworkManager sharedNetworkManager] setupWelcomeView];
	//	}
		// :(
	}
	else if (buttonIndex == 1) {
		RCNetwork *net = [[RCNetworkManager sharedNetworkManager] networkWithDescription:active.text];
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
		RCNetwork *net = [[RCNetworkManager sharedNetworkManager] networkWithDescription:titleLabel.text];
		if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Disconnect"]) [net disconnect];
		else {
			[net performSelectorInBackground:@selector(_connect) withObject:nil];
		}
		//connect
	}
	else if (buttonIndex == 4) {
		// cancel.
		// kbye
	}
	active = nil;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	isShowing = NO;
	switch (buttonIndex) {
		case 1: {
	//		RCNetwork *net = [[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:currentIndex];
	//		RCChannel *chan = [[net _channels] objectForKey:[[questionabubble titleLabel] text]];
	//		[[net _bubbles] removeObject:questionabubble];
	//		[scrollBar layoutChannels:[net _bubbles]];
	//		if ([[chan panel] isEqual:currentPanel]) {
	//			[currentPanel removeFromSuperview];
	//			currentPanel = nil;
	//		}
	//		[net removeChannel:chan];
			
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
//	RCNetwork *net = [[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:currentIndex];	
//	RCChannel *chan = [[net _channels] objectForKey:[[bubble titleLabel] text]];
//	memberPanel.delegate = chan;
//	memberPanel.dataSource = chan;
//	memberPanel.frame = [self frameForMemberPanel];
//	chan.usersPanel = memberPanel;
//	[currentPanel removeFromSuperview];
//	[self addSubview:memberPanel];
}

static RCChannelBubble *questionabubble = nil;
static BOOL isShowing = NO;

- (void)channelWantsSuicide:(RCChannelBubble *)bubble {
	if (!isShowing) {
		isShowing = YES;
		questionabubble = bubble;
		[self performSelectorOnMainThread:@selector(doSuicideConfirmationAlert:) withObject:bubble waitUntilDone:YES];
		
	}
}

- (void)doSuicideConfirmationAlert:(RCChannelBubble *)questionAble {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:[NSString stringWithFormat:@"Are you sure you want to delete %@", [questionAble titleLabel].text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
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
	RCNetwork *net = [[RCNetworkManager sharedNetworkManager] networkWithDescription:titleLabel.text];
	RCChannel *chan = [net channelWithChannelName:bubble.titleLabel.text];
	if (chan) {
		if ([currentPanel isFirstResponder])
			[[chan panel] becomeFirstResponderNoAnimate];
		if (currentPanel) {
			[currentPanel removeFromSuperview];
		}
		[[chan panel] setFrame:(currentPanel ? [currentPanel frame] : [self frameForChatTable])];
		[self addSubview:[chan panel]];
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
			UIImage *tb = [UIImage imageNamed:@"0_navbar_landscape"];
			[tb drawInRect:CGRectMake(0, 0, 480, 33)];
			UIImage *bg = [UIImage imageNamed:@"0_bg"];
			[bg drawInRect:CGRectMake(0, 33, 480, 300)];
		}
		else {
			UIImage *tb = [UIImage imageNamed:@"0_navbar"];
			[tb drawInRect:CGRectMake(0, 0, 320, 45)];
			UIImage *bg = [UIImage imageNamed:@"0_bg"];
			[bg drawInRect:CGRectMake(0, 45, 320, 426)];
		}
	}
}

- (void)rotateToLandscape {
	if (_isLandscape) return;
	_isLandscape = YES;
	if (bar.frame.size.height == 45) {
		bar.frame = CGRectMake(bar.frame.origin.x, bar.frame.origin.y, 120, 33);
		scrollBar.frame = CGRectMake(240, 0, 480-250, 33);
				scrollBar.backgroundColor = [UIColor clearColor];
		[scrollBar clearBG];
	}
	[self setNeedsDisplay];
	[leftGroup setFrame:[self frameForLeftBarGroup]];
	[rightGroup setFrame:[self frameForRightBarGroup]];
	if (currentPanel) {
		[currentPanel setFrame:[self frameForChatTable]];
		[[currentPanel tableView] reloadData];
	}
	[memberPanel setFrame:[self frameForMemberPanel]];
		[titleLabel setFrame:CGRectMake(0, 0, [self widthForNetworkBar], [self heightForNetworkBar])];
}

- (CGRect)frameForLeftBarGroup {
	if (_isLandscape) {
		return CGRectMake(2, 1, 15, 29);
	}
	return CGRectMake(10, 7, 15, 29);
}

- (CGRect)frameForRightBarGroup {
	if (_isLandscape) {
		return CGRectMake(220, 1, 15, 29);
	}
	return CGRectMake(290, 7, 15, 29);
}

- (CGFloat)heightForNetworkBar {
	if (_isLandscape)
		return 33;
	return 45;
}

- (CGFloat)widthForNetworkBar {
	if (_isLandscape)
		return 120;
	return 200;
}

- (CGRect)frameForChatTable {
	if (_isLandscape)
		return CGRectMake(0, 33, 480, 227);
	return CGRectMake(0, 77, 320, 344);
}

- (CGRect)frameForMemberPanel {
	if (_isLandscape)
		return CGRectMake(0, 33, 480, 267);
	return CGRectMake(0, 77, 320, 384);
}

- (void)rotateToPortrait {
	if (!_isLandscape) return;
	_isLandscape = NO;
	[scrollBar drawBG];
	[self setNeedsDisplay];
	[leftGroup setFrame:[self frameForLeftBarGroup]];
	[rightGroup setFrame:[self frameForRightBarGroup]];
	if (currentPanel) {
		[currentPanel setFrame:[self frameForChatTable]];
		[[currentPanel tableView] reloadData];
	}
	[self setNeedsDisplay];
	if (bar.frame.size.height == 33) {
		bar.frame = CGRectMake(bar.frame.origin.x, bar.frame.origin.y, 200, 45);
		scrollBar.frame = CGRectMake(0, 45, 320, 32);
	}
	[titleLabel setFrame:CGRectMake(0, 0, [self widthForNetworkBar], [self heightForNetworkBar])];
	[memberPanel setFrame:[self frameForMemberPanel]];
}

- (void)dealloc {
	[bar release];
	[super dealloc];
}

@end
