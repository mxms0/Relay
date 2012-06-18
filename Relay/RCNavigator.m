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
	CGSize screenWidth = [[UIScreen mainScreen] applicationFrame].size;
	return [self initWithFrame:CGRectMake(0, 0, screenWidth.width, screenWidth.height)];
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_rcViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
		if ([_rcViewController isKindOfClass:[UINavigationController class]])
			_rcViewController = [_rcViewController topViewController];
		isFirstSetup = -1;
		_isLandscape = NO;
		memberPanel = [[RCUserListPanel alloc] initWithFrame:CGRectMake(0, 77, 320, 383)];
		memberPanel.backgroundColor = [UIColor clearColor];
		memberPanel.separatorStyle = UITableViewCellSeparatorStyleNone;
		_notifications = [[NSMutableDictionary alloc] init];
		leftBubble = [[RCNewMessagesBubble alloc] initWithFrame:CGRectMake(30, 10, 28, 25)];
		rightBubble = [[RCNewMessagesBubble alloc] initWithFrame:CGRectMake(260, 10, 30, 25)];
		[self addSubview:leftBubble];
		[self addSubview:rightBubble];
		[leftBubble release];
		[rightBubble release];
		leftBubble.hidden = YES;
		rightBubble.hidden = YES;
		leftGroup = [[RCBarGroup alloc] initWithFrame:CGRectMake(10, 7, 15, 29)];
		[self addSubview:leftGroup];
		[leftGroup release];
		rightGroup = [[RCBarGroup alloc] initWithFrame:CGRectMake(290, 7, 15, 29)];
		[self addSubview:rightGroup];
		[rightGroup release];
		netCount = 0;
		draggingNets = NO;
		draggingChans = NO;
		bar = [[RCNavigationBar alloc] initWithFrame:CGRectMake(60, 0, 200, 45)];
		bar.tag = 100;
		stupidLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -50, bar.frame.size.width, bar.frame.size.height)];
		stupidLabel.font = [UIFont systemFontOfSize:11];
		stupidLabel.backgroundColor = [UIColor clearColor];
		stupidLabel.text = @"Pull for new network";
		stupidLabel.textAlignment = UITextAlignmentCenter;
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
		[dble setNumberOfTouchesRequired:1];
		[titleLabel addGestureRecognizer:dble];
		[dble release];
		[bar addSubview:titleLabel];
		[titleLabel release];
		[bar addSubview:stupidLabel];
		[stupidLabel release];
		scrollBar = [[RCChannelScrollView alloc] initWithFrame:CGRectMake(0, 45, 320, 32)];
		scrollBar.tag = 200;
		scrollBar.delegate = self;
		[self addSubview:scrollBar];
		[scrollBar release];
		[self addSubview:bar];
		[bar release];
    }
	_sharedNavigator = self;
    return _sharedNavigator;
}

- (void)pulseMofo:(NSTimer *)arg1 {
	if ((leftBubble.hidden) && (rightBubble.hidden)) return;
	NSLog(@"Pulse.");
	if (!leftBubble.hidden) [leftBubble pulse];
	if (!rightBubble.hidden) [rightBubble pulse];
}

- (void)addNetwork:(RCNetwork *)net	{
	if (!net) {
		NSLog(@"Dear haxor, an argument goes here. %s", __PRETTY_FUNCTION__);
		return;
	}
	if (isFirstSetup == -1) isFirstSetup = ([net isKindOfClass:[RCWelcomeNetwork class]] ? 1 : 0);
	if (isFirstSetup == 2) {
		[[[RCNetworkManager sharedNetworkManager] networks] removeObjectAtIndex:0];
		[[[bar subviews] objectAtIndex:netCount+1] removeFromSuperview];
		[scrollBar layoutChannels:nil];
		isFirstSetup = 0;
		[currentPanel removeFromSuperview];
		currentPanel = nil;
		[NSTimer scheduledTimerWithTimeInterval:120 target:[RCNetworkManager sharedNetworkManager] selector:@selector(saveChannelData:) userInfo:nil repeats:YES];
		isFirstSetup = -1;
	}
	if (isFirstSetup == 1) {
		// new network coming through, remove setup she-yite
		// useless comment above. means nothing at all.
		// do not remove it. evar.
		// if you do, this program will fail to compile.
		isFirstSetup = 2;
	}
	if (titleLabel.text == nil || ([titleLabel.text isEqualToString:@""]))
		[titleLabel setText:[net _description]];
	for (NSString *chan in [[net _channels] allKeys]) {
		if (![chan isEqualToString:@""] && ![chan isEqualToString:@" "]) {
			RCChannelBubble *bubble = [self channelBubbleWithChannelName:chan];
			[[net _bubbles] insertObject:bubble atIndex:([[net _bubbles] count])];
			[bubble release];
			[[[net _channels] objectForKey:chan] setBubble:bubble];
		}
	}
	if (netCount == 1) {
		[self channelSelected:[[[net _channels] objectForKey:@"IRC"] bubble]];
		[self scrollViewDidEndDecelerating:nil];
	}
}

- (void)addCount:(int)mentions forIndex:(int)_index {
	int _c = [[_notifications objectForKey:[NSString stringWithFormat:@"%d", _index]] intValue];
	_c += mentions;
	[_notifications setObject:[NSString stringWithFormat:@"%d", _c] forKey:[NSString stringWithFormat:@"%d", _index]];
	[self resetBubbles];
}

- (void)removeCount:(int)c forIndex:(int)_index {
	int _c = [[_notifications objectForKey:[NSString stringWithFormat:@"%d", _index]] intValue];
	_c-=c;
	[_notifications setObject:[NSString stringWithFormat:@"%d", _c] forKey:[NSString stringWithFormat:@"%d", _index]];
	[self resetBubbles];
}

- (void)resetBubbles {
	[self performSelectorInBackground:@selector(_reallyResetBubbles) withObject:nil];
}

- (void)_reallyResetBubbles {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	int leftCount = 0;
	int rightCount = 0;
	if (currentIndex == 0) {
		for (int x = [[_notifications allKeys] count]-1; x > currentIndex; x--) {
			int z = [[_notifications objectForKey:[[_notifications allKeys] objectAtIndex:x]] intValue];
			rightCount += z;
		}
	}
	else if (currentIndex == [[_notifications allKeys] count]) {
		for (int i = 0; i < currentIndex; i++) {
			int z = [[_notifications objectForKey:[[_notifications allKeys] objectAtIndex:i]] intValue];
			leftCount += z;
		}		
	}
	else {
		BOOL revert = NO;
		for (int i = 0; i < [[_notifications allKeys] count]; i++) {
			if (i == currentIndex) {
				revert = YES;
				continue;
			}
			int y = [[_notifications objectForKey:[[_notifications allKeys] objectAtIndex:i]] intValue];
			if (revert)
				rightCount += y;
			else 
				leftCount += y;
		}		
	}
	if (leftCount != 0) {
		[[leftBubble titleLabel] setText:[NSString stringWithFormat:@"%d", leftCount]];
		if (leftCount > 99) {
			[leftBubble setFrame:CGRectMake(leftBubble.frame.origin.x, leftBubble.frame.origin.y, 37, 25)];	
		}
		else if (leftCount > 9) {
			[leftBubble setFrame:CGRectMake(leftBubble.frame.origin.x, leftBubble.frame.origin.y, 32, 25)];
		}
		else {
			[leftBubble setFrame:CGRectMake(leftBubble.frame.origin.x, leftBubble.frame.origin.y, 30, 25)];
		}
		[leftBubble realignTitleLabel];
		leftBubble.hidden = NO;
	}
	else {
		leftBubble.hidden = YES;
		leftBubble.titleLabel.text = @"";
	}
	if (rightCount != 0) {
		rightBubble.hidden = NO;
		rightBubble.titleLabel.text = [NSString stringWithFormat:@"%d", rightCount];
	}
	else {
		rightBubble.hidden = YES;
		rightBubble.titleLabel.text = @"";
	}
	
	[p drain];
}

- (void)showNetworkPopover:(UIGestureRecognizer *)gerk {
	
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
		if (netCount == 0) {
			[scrollBar layoutChannels:nil];
			[[RCNetworkManager sharedNetworkManager] setupWelcomeView];
		}
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

- (void)addRoom:(NSString *)room toServerAtIndex:(int)index {
	RCNetwork *useNet;
	for (RCNetwork *net in [[RCNetworkManager sharedNetworkManager] networks]) {
		if ([net index] == index) {
			useNet = net;
			break;
		}
	}
	if (!useNet) return;
	RCChannelBubble *bubble = [self channelBubbleWithChannelName:room];
	[[useNet _bubbles] addObject:bubble];
	[bubble release];
	[[[useNet _channels] objectForKey:room] setBubble:bubble];
	[bubble _classify:useNet.index];
//	[scrollBar layoutChannels:[rooms objectAtIndex:index]];
}

- (void)removeChannel:(RCChannel *)room toServerAtIndex:(int)index {
//	NSMutableArray *currentBubbles = [rooms objectAtIndex:index];
//	for (RCChannelBubble *chan in currentBubbles) {
//		if ([[chan titleLabel].text isEqual:[room channelName]]) {
//			[currentBubbles removeObject:chan];
//			[memberPanel removeFromSuperview];
//			memberPanel.delegate = nil;
//			memberPanel.dataSource = nil;
//			currentPanel = nil;
//			break;
//		}
//	}
//	[scrollBar layoutChannels:currentBubbles];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	isShowing = NO;
	switch (buttonIndex) {
		case 1: {
			RCNetwork *net = [[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:currentIndex];
			RCChannel *chan = [[net _channels] objectForKey:[[questionabubble titleLabel] text]];
			[[net _bubbles] removeObject:questionabubble];
			[scrollBar layoutChannels:[net _bubbles]];
			if ([[chan panel] isEqual:currentPanel]) {
				[currentPanel removeFromSuperview];
				currentPanel = nil;
			}
			[net removeChannel:chan];
			
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
	RCNetwork *net = [[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:currentIndex];	
	RCChannel *chan = [[net _channels] objectForKey:[[bubble titleLabel] text]];
	memberPanel.delegate = chan;
	memberPanel.dataSource = chan;
	memberPanel.frame = [self frameForMemberPanel];
	chan.usersPanel = memberPanel;
	[currentPanel removeFromSuperview];
	[self addSubview:memberPanel];
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

- (void)_channelWantsSuicide:(RCChannelBubble *)bubble {
	
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
	NSLog(@"MEH %@", [net _bubbles]);
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if (!scrollView) {
		[scrollBar layoutChannels:[[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:0] _bubbles]];
	//	if ([rooms count] > 0) [scrollBar layoutChannels:[rooms objectAtIndex:0]];
		return;
	}
	if (scrollView.tag == 100) {
		if ([[scrollView subviews] count] > 1) {
			unsigned int netLoc;
			if (scrollView.contentOffset.x != 0) netLoc = scrollView.contentOffset.x/bar.frame.size.width;
			else netLoc = 0;
			if (netLoc != currentIndex) currentIndex = netLoc;
			else return;
			[scrollBar layoutChannels:[[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:currentIndex] _bubbles]];
			[stupidLabel setFrame:CGRectMake(currentIndex*200, stupidLabel.frame.origin.y, stupidLabel.frame.size.width, stupidLabel.frame.size.height)];
			[self resetBubbles];
		}
	}
	else {
		// in case ineed this later.. it's available.
	}

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView.tag == 100) {
		if (scrollView.contentOffset.y <= -50.00) {
			draggingNets = YES;
	//		stupidLabel.text = @"Release for new network";
		}
		else {
			draggingNets = NO;
	//		stupidLabel.text = @"Pull for netz";
		}
	}	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (scrollView.tag == 100) {
		if (scrollView.contentOffset.y <= -50.00) {
			if (draggingNets) {
				UIViewController *rc = [((RCAppDelegate *)[[UIApplication sharedApplication] delegate]) navigationController];
				RCAddNetworkController *ctrlr = [[RCAddNetworkController alloc] initWithNetwork:nil];
				UINavigationController *ctrl = [[UINavigationController alloc] initWithRootViewController:ctrlr];
				[ctrl setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
				[rc presentModalViewController:ctrl animated:YES];
				[ctrlr release];
				[ctrl release];
			}
		}
	}
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

- (void)reLayoutNetworkTitles {
	int i = 0;
	int _size = 30;
	if (_isLandscape)
		_size = 20;
	for (i = 0; i <= [[bar subviews] count]-1; i++) {
		RCTitleLabel *_label = [[bar subviews] objectAtIndex:i];
		if ([_label isKindOfClass:[RCTitleLabel class]]) {
			[_label setFrame:CGRectMake((i-1) * bar.frame.size.width, 0, [self widthForNetworkBar], [self heightForNetworkBar])];
			[_label setFont:[UIFont boldSystemFontOfSize:_size]];
		}
	}
	[bar setContentSize:CGSizeMake((i-1) * bar.frame.size.width, [self heightForNetworkBar] + 0.5)];
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
	[memberPanel setFrame:[self frameForMemberPanel]];
}

- (void)dealloc {
	[bar release];
	[_notifications release];
	[super dealloc];
}

@end
