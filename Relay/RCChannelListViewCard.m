//
//  RCChannelListViewCard.m
//  Relay
//
//  Created by Max Shavrick on 6/29/13.
//

#import "RCChannelListViewCard.h"
#import "RCChatController.h"
#import "RCOperation.h"

@implementation RCChannelListViewCard
@synthesize currentNetwork;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		queue = nil;
		searchTerm = nil;
		[navigationBar setMaxSize:18];
		[navigationBar setNeedsDisplay];
		channelDatas = nil;
		CALayer *cv = [[CALayer alloc] init];
		[cv setContents:(id)[UIImage imageNamed:@"0_nvs"].CGImage];
		[cv setFrame:CGRectMake(0, -46, 320, 46)];
		[self.layer addSublayer:cv];
		[cv release]; 
		channels = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, frame.size.width, frame.size.height-44)];
		[channels setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		[channels setBackgroundColor:UIColorFromRGB(0xDDE0E5)];
		[channels setShowsVerticalScrollIndicator:YES];
		[channels setDelegate:self];
		[channels setDataSource:self];
		[self addSubview:channels];
		[channels release];
		UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		[searchBar setDelegate:self];
		[searchBar setShowsCancelButton:NO];
		[searchBar setUserInteractionEnabled:NO];
		[searchBar setAlpha:0.5];
		for (UIView *sv in [searchBar subviews]) {
			if ([sv isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
				[sv removeFromSuperview];
				break;
			}
		}
		// can probably use UIAppearence to do this.. :/
		[channels setTableHeaderView:searchBar];
		[searchBar release];
		[channels setContentOffset:CGPointMake(0, 44)];
	}
	return self;
}

- (void)scrollToTop {
	[channels setContentOffset:CGPointMake(0, 44) animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (updating) return 0;
	if (isSearching) return [searchArray count];
	if (!channelDatas) return 0;
	return [channelDatas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	RCChannelInfoTableViewCell *cc = (RCChannelInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"0_CSL"];
	if (!cc) {
		cc = [[[RCChannelInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"0_CSL"] autorelease];
	}
	if (!channelDatas) {
		[tableView reloadData];
		return cc;
	}
	NSArray *use = channelDatas;
	if (isSearching) use = searchArray;
	if ([use count] <= indexPath.row) {
		[tableView reloadData];
		return cc;
	}
	[cc setChannelInfo:[use objectAtIndex:indexPath.row]];
	[cc setBackgroundColor:[UIColor blackColor]];
	[cc setNeedsDisplay];
	return cc;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:YES animated:YES];
	searchArray = [[NSMutableArray alloc] init];
	[channels setFrame:CGRectMake(0, channels.frame.origin.y, 320, self.frame.size.height - (44 + 215))];
	isSearching = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar setShowsCancelButton:NO animated:YES];
	[searchBar resignFirstResponder];
	[searchBar setText:@""];
	[channels setFrame:CGRectMake(0, 44, self.frame.size.width, self.frame.size.height-44)];
	[searchArray release];
	searchArray = nil;
	isSearching = NO;
	[channels reloadData];
}

- (void)searchForKeyword:(RCOperation *)opera {
	NSString *keyword = searchTerm;
	for (int i = 0; i < [channelDatas count]; i++) {
		if (!opera.cancelled) {
			RCChannelInfo *ifs = [channelDatas objectAtIndex:i];
			if ([[ifs channel] rangeOfString:keyword options:NSCaseInsensitiveSearch].location != NSNotFound) {
				[searchArray addObject:ifs];
			}
		}
	}
	dispatch_async(dispatch_get_main_queue(), ^ {
		[channels reloadData];
	});
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if ([[searchBar text] isEqualToString:@""]) {
		// do something.
		isSearching = NO;
		[channels reloadData];
		return;
	}
	isSearching = YES;
	if (searchTerm) [searchTerm release];
	searchTerm = [[searchBar text] retain];
	[searchArray removeAllObjects];
	if (!queue) {
		queue = [[RCOperationQueue alloc] init];
		//		[queue setMaxConcurrentOperationCount:1];
		[queue setName:@"relay_search_queue"];
	}
	[queue cancelAllOperations];
	RCOperation *op = [[RCOperation alloc] init];
	[op setDelegate:self];
	[queue addOperation:op];
	[op release];
}

- (void)setUpdating:(BOOL)ud {
	updating = ud;
	dispatch_sync(dispatch_get_main_queue(), ^{
		if (!updating) {
			channelDatas = [[NSMutableArray alloc] initWithCapacity:count+1];
			for (int i = count; i > 0; i--) {
				NSArray *ary = [unsortedChannels objectForKey:[NSNumber numberWithInt:i]];
				if (ary) {
					[channelDatas addObjectsFromArray:ary];
				}
			}
			[unsortedChannels release];
			unsortedChannels = nil;
			if ([channelDatas count] == 0) {
				[self presentErrorNotificationAndDismiss];
			}
			else {
				[currentChannels release];
				currentChannels = nil;
				[channels reloadData];
				[[self navigationBar] setSubtitle:[NSString stringWithFormat:@"%d Channels", [channelDatas count]]];
				[[self navigationBar] setNeedsDisplay];
				[[channels tableHeaderView] setUserInteractionEnabled:YES];
				[[channels tableHeaderView] setAlpha:1];
			}
		}
	});
}

- (void)presentErrorNotificationAndDismiss {
	RCPrettyAlertView *alrt = [[RCPrettyAlertView alloc] initWithTitle:@"Error" message:@"There was an issue getting the channel list. Please try again in a minute." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
	[alrt show];
	[alrt release];
	[(RCCuteView *)[self superview] dismiss];
}

- (void)recievedChannel:(NSString *)chan withCount:(int)cc andTopic:(NSString *)topics {
	if (!updating) {
		updating = YES;
		currentChannels = [[NSMutableArray alloc] init];
		unsortedChannels = [[NSMutableDictionary alloc] init];
		for (RCChannel *chan in [currentNetwork _channels]) {
			[currentChannels addObject:[chan channelName]];
		}
		[self refreshSubtitleLabel];
	}
	RCChannelInfo *ifs = [[RCChannelInfo alloc] init];
	count++;
	[ifs setChannel:chan];
	BOOL containsChannel = NO;
	for (NSString *channel in currentChannels) {
		if ([chan isEqualToStringNoCase:channel]) {
			containsChannel = YES;
			break;
		}
	}
	if (containsChannel) {
		[ifs setIsAlreadyInChannel:YES];
		[currentChannels removeObject:chan];
	}
	else {
		[ifs setIsAlreadyInChannel:NO];
	}
	[ifs setUserCount:cc];
	if (![topics isEqualToString:@""])
		[ifs setTopic:[topics stringByStrippingIRCMetadata]];
	else
		[ifs setTopic:@"No topic set."];
	NSString *lcnt = [NSString stringWithFormat:@"%d Users", cc];
	CGFloat rsz = 0;
	dispatch_async(dispatch_get_main_queue(), ^{
		CGSize szf = [lcnt sizeWithFont:[UIFont systemFontOfSize:12] minFontSize:10 actualFontSize:(CGFloat *)&rsz forWidth:84 lineBreakMode:NSLineBreakByClipping];
		NSString *nam = chan;
		CGFloat azf = 0;
		[nam sizeWithFont:[UIFont boldSystemFontOfSize:16] minFontSize:8 actualFontSize:&azf forWidth:(320 - (szf.width + 40)) lineBreakMode:NSLineBreakByClipping];
		NSString *set = [NSString stringWithFormat:@"%@ %d Users", chan, cc];
		int lfr = [chan length];
		NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:set];
		UIFont *ft = [UIFont boldSystemFontOfSize:azf];
		[str addAttributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:ft, UIColorFromRGB(0x444647), nil] forKeys:[NSArray arrayWithObjects:NSFontAttributeName, NSForegroundColorAttributeName, nil]] range:NSMakeRange(0, lfr)];
		UIFont *sft = [UIFont systemFontOfSize:rsz];
		[str addAttributes:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:sft, UIColorFromRGB(0x797c7e), nil] forKeys:[NSArray arrayWithObjects:NSFontAttributeName, NSForegroundColorAttributeName, nil]] range:NSMakeRange(lfr, [set length] - lfr)];
		[ifs setAttributedString:str];
		[str release];
		NSNumber *key = [NSNumber numberWithInt:cc];
		NSMutableArray *ary = [unsortedChannels objectForKey:key];
		if (!ary) {
			ary = [NSMutableArray arrayWithObject:ifs];
		}
		else {
			[ary addObject:ifs];
			[ifs release]; // SHOULDNT FORGET THIS.
		}
		[unsortedChannels setObject:ary forKey:key];
	});
}

- (void)refreshSubtitleLabel {
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC/8);
	// NSEC_PER_ESC/12 looks so much nicer
	// probably a little too mean on the gpu tho :( ~Maximus
	dispatch_after(popTime, dispatch_get_main_queue(), ^{
		NSString *subtitle = nil;
		if (updating) {
			subtitle = [NSString stringWithFormat:@"Loading... %d public channels", count];
			[self refreshSubtitleLabel];
		}
		else {
			subtitle = [NSString stringWithFormat:@"%d Public Channels", count];
		}
		[self.navigationBar setSubtitle:subtitle];
		[self.navigationBar setNeedsDisplay];
	});
}

- (void)dealloc {
	[channelDatas release];
	[queue release];
	queue = nil;
	[searchTerm release];
	searchTerm = nil;
	[super dealloc];
}

@end
