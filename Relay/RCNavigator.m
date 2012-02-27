//
//  RCNavigator.m
//  Relay
//
//  Created by Max Shavrick on 2/25/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCNavigator.h"
#import "RCNetworkManager.h"

@implementation RCNavigator

static id _sharedNavigator = nil;

- (id)init {
	CGSize screenWidth = [[UIScreen mainScreen] applicationFrame].size;
	return [self initWithFrame:CGRectMake(0, 0, screenWidth.width, screenWidth.height)];
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		netCount = 0;
		rooms = [[NSMutableArray alloc] init];
		bar = [[RCNavigationBar alloc] initWithFrame:CGRectMake(30, 0, frame.size.width-60, 45)];
		scrollBar = [[RCChannelScrollView alloc] initWithFrame:CGRectMake(0, 45, 320, 32)];
		[self addSubview:scrollBar];
		[scrollBar release];
		[bar setContentSize:CGSizeMake(bar.frame.size.width, 45)];
		[bar setPagingEnabled:YES];
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
	if (!net) return;
	netCount++;
	[net setIndex:netCount-1];
	RCTitleLabel *_label = [[RCTitleLabel alloc] initWithFrame:CGRectMake(netCount*260-bar.frame.size.width, 0, bar.frame.size.width, bar.frame.size.height)];
	[_label setBackgroundColor:[UIColor clearColor]];
	[_label setHidden:NO];
	[_label setText:[net _description]];
	[_label setFont:[UIFont boldSystemFontOfSize:25]];
	[bar addSubview:_label];
	[_label release];
	[bar setContentSize:CGSizeMake(netCount*260, 45)];
	
	NSMutableArray *tmp = [[NSMutableArray alloc] init];
	for (NSString *chan in [net channels]) {
		RCChannelBubble *bubble = [self channelBubbleWithChannelName:chan];
		[[[net _channels] objectForKey:chan] setBubble:bubble];
		[tmp addObject:bubble];
		[bubble release];
	}
	[rooms addObject:tmp];
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
	NSLog(@"Meh. %@ %@", useNet, bubble);
	[[[useNet _channels] objectForKey:room] setBubble:bubble];
	[[rooms objectAtIndex:index] addObject:bubble];
	[bubble release];
	[scrollBar layoutChannels:[rooms objectAtIndex:index]];
}

- (RCChannelBubble *)channelBubbleWithChannelName:(NSString *)name {
	CGSize size = [name sizeWithFont:[UIFont boldSystemFontOfSize:14]];
	RCChannelBubble *bubble = [[RCChannelBubble alloc] initWithFrame:CGRectMake(0, 0, size.width+=20, 18)];
	[bubble addTarget:self action:@selector(channelSelected:) forControlEvents:UIControlEventTouchUpInside];
	[bubble setTitle:name forState:UIControlStateNormal];
	return bubble;
}

- (void)channelSelected:(RCChannelBubble *)bubble {
	RCNetwork *net = [[RCNetworkManager sharedNetworkManager] networkWithDescription:[[[bar subviews] objectAtIndex:currentIndex] text]];
	RCChannel *chan = [[net _channels] objectForKey:bubble.titleLabel.text];
	if (chan) {
		if (currentPanel) {
			if ([currentPanel isEqual:[chan panel]]) return;
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
	unsigned int netLoc;
	if (scrollView.contentOffset.x != 0) netLoc = scrollView.contentOffset.x/260;
	else netLoc = 0;
	if (netLoc != currentIndex) currentIndex = netLoc;
	else return;
	[scrollBar layoutChannels:[rooms objectAtIndex:(unsigned int)netLoc]];
	
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
