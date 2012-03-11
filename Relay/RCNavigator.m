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
@synthesize currentPanel;
static id _sharedNavigator = nil;

- (id)init {
	CGSize screenWidth = [[UIScreen mainScreen] applicationFrame].size;
	return [self initWithFrame:CGRectMake(0, 0, screenWidth.width, screenWidth.height)];
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		isFirstSetup = -1;
		stupidLabel = [[UILabel alloc] initWithFrame:CGRectMake(-90, 10, 85, 20)];
		stupidLabel.font = [UIFont systemFontOfSize:11];
		stupidLabel.backgroundColor = [UIColor clearColor];
		stupidLabel.text = @"Pull for new network";
		netCount = 0;
		draggingNets = NO;
		draggingChans = NO;
		rooms = [[NSMutableArray alloc] init];
		bar = [[RCNavigationBar alloc] initWithFrame:CGRectMake(30, 0, frame.size.width-60, 45)];
		bar.tag = 100;
		[bar addSubview:stupidLabel];
		[stupidLabel release];
		scrollBar = [[RCChannelScrollView alloc] initWithFrame:CGRectMake(0, 45, 320, 32)];
		scrollBar.tag = 200;
		scrollBar.delegate = self;
		[self addSubview:scrollBar];
		[scrollBar release];
		[bar setContentSize:CGSizeMake(bar.frame.size.width, 45)];
		[bar setPagingEnabled:YES];
		[bar setScrollEnabled:YES];
		[bar setShowsVerticalScrollIndicator:NO];
		[bar setShowsHorizontalScrollIndicator:NO];
		[bar setBounces:YES];
		[bar setDelegate:self];
		[self addSubview:bar];
		[bar release];
    }
	_sharedNavigator = self;
    return _sharedNavigator;
}

- (void)addNetwork:(RCNetwork *)net	{
	if (!net) {
		NSLog(@"Dear haxor, an argument goes here.");
		return;
	}
	if (isFirstSetup == -1) isFirstSetup = ([net isKindOfClass:[RCWelcomeNetwork class]] ? 1 : 0);
	if (isFirstSetup == 2) {
		netCount = 0;
		[[[RCNetworkManager sharedNetworkManager] networks] removeObjectAtIndex:0];
		[[[bar subviews] objectAtIndex:netCount+1] removeFromSuperview];
		[scrollBar layoutChannels:nil];
		isFirstSetup = 0;
		[rooms removeObjectAtIndex:0];
	}
	if (isFirstSetup == 1) {
		// new network coming through, remove setup she-yite
		// useless comment above. means nothing at all.
		// do not remove it. evar.
		// if you do, this program will fail to compile.
		isFirstSetup = 2;
	}

	netCount++;
	[net setIndex:netCount-1];
	RCTitleLabel *_label = [[RCTitleLabel alloc] initWithFrame:CGRectMake(netCount*260-bar.frame.size.width, 0, bar.frame.size.width, bar.frame.size.height)];
	[_label setBackgroundColor:[UIColor clearColor]];
	[_label setHidden:NO];
	[_label setText:[net _description]];
	[_label setFont:[UIFont boldSystemFontOfSize:25]];
	[bar addSubview:_label];
	[_label release];
	[bar setContentSize:CGSizeMake((netCount*260) + 0.5, 45)];
	
	NSMutableArray *tmp = [[NSMutableArray alloc] init];
	for (NSString *chan in [net channels]) {
		RCChannelBubble *bubble = [self channelBubbleWithChannelName:chan];
		[[[net _channels] objectForKey:chan] setBubble:bubble];
		[tmp addObject:bubble];
		[bubble release];
	}
	[rooms addObject:tmp];
	if (netCount == 1) {
		[self channelSelected:[[[net _channels] objectForKey:@"IRC"] bubble]];
		[self scrollViewDidEndDecelerating:nil];
	}
	[tmp release];
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
	[[[useNet _channels] objectForKey:room] setBubble:bubble];
	[[rooms objectAtIndex:index] addObject:bubble];
	[bubble release];
	[scrollBar layoutChannels:[rooms objectAtIndex:index]];
}

- (void)removeChannel:(RCChannel *)room toServerAtIndex:(int)index {
	NSMutableArray *currentBubbles = [rooms objectAtIndex:index];
	for (RCChannelBubble *chan in currentBubbles) {
		if ([[chan titleLabel].text isEqual:[room channelName]]) {
			[currentBubbles removeObject:chan];
			break;
		}
	}
	[scrollBar layoutChannels:currentBubbles];
}

- (RCChannelBubble *)channelBubbleWithChannelName:(NSString *)name {
	CGSize size = [name sizeWithFont:[UIFont boldSystemFontOfSize:14]];
	RCChannelBubble *bubble = [[RCChannelBubble alloc] initWithFrame:CGRectMake(0, 0, size.width+=20, 18)];
	[bubble addTarget:self action:@selector(channelSelected:) forControlEvents:UIControlEventTouchUpInside];
	[bubble setTitle:name forState:UIControlStateNormal];
	return bubble;
}

static RCChannelBubble *questionabubble = nil;

- (void)channelWantsSuicide:(RCChannelBubble *)bubble {
	questionabubble = bubble;
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:[NSString stringWithFormat:@"Are you sure you want to delete %@", [bubble titleLabel].text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 1: {
			RCNetwork *net = [[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:currentIndex];
			RCChannel *chan = [[net _channels] objectForKey:[[questionabubble titleLabel] text]];
			if ([[chan panel] isEqual:currentPanel]) {
				[currentPanel removeFromSuperview];
			}
			[net removeChannel:chan];
			break;
		}
		case 0:
			break;
	}
}

- (void)_channelWantsSuicide:(RCChannelBubble *)bubble {
	
}

- (void)channelSelected:(RCChannelBubble *)bubble {
	if (currentPanel) if ([[[currentPanel channel] bubble] isEqual:bubble]) return;
	[[[currentPanel channel] bubble] _setSelected:NO];
	[bubble _setSelected:YES];
	RCNetwork *net = [[RCNetworkManager sharedNetworkManager] networkWithDescription:[[[bar subviews] objectAtIndex:currentIndex+1] text]];
	RCChannel *chan = [[net _channels] objectForKey:bubble.titleLabel.text];

	if (chan) {
		if (currentPanel) {
			[currentPanel removeFromSuperview];
		}
		[[chan panel] setFrame:CGRectMake(0, 77, 320, 384)];
		[self addSubview:[chan panel]];
		currentPanel = [chan panel];
	}
}

+ (id)sharedNavigator {
	if (!_sharedNavigator) _sharedNavigator = [[self alloc] init];
	return _sharedNavigator;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if (!scrollView) {
		if ([rooms count] > 0) [scrollBar layoutChannels:[rooms objectAtIndex:0]];
		return;
	}
	if (scrollView.tag == 100) {
		unsigned int netLoc;
		if (scrollView.contentOffset.x != 0) netLoc = scrollView.contentOffset.x/260;
		else netLoc = 0;
		if (netLoc != currentIndex) currentIndex = netLoc;
		else return;
		[scrollBar layoutChannels:[rooms objectAtIndex:netLoc]];
	}
	else {
		// in case ineed this later.. it's available.
	}
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollView.tag == 100) {
		if (scrollView.contentOffset.x <= -100.00) {
			draggingNets = YES;
			stupidLabel.text = @"Releaseeeeee";
		}
		else {
			draggingNets = NO;
			stupidLabel.text = @"Pullllllll";
		}
	}
	
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (scrollView.tag == 100) {
		if (scrollView.contentOffset.x <= -100.00) {
			if (draggingNets) {
				UIViewController *rc = [[[UIApplication sharedApplication] delegate] navigationController];
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
		UIImage *tb = [UIImage imageNamed:@"0_navbar"];
		[tb drawInRect:CGRectMake(0, 0, 320, 45)];
		UIImage *bg = [UIImage imageNamed:@"0_bg"];
		[bg drawInRect:CGRectMake(0, 45, 320, 426)];
	}
}


- (void)dealloc {
	[bar release];
	[rooms release];
	[super dealloc];
}

@end
