//
//  RCChatsListViewCard.m
//  Relay
//
//  Created by Max Shavrick on 6/18/13.
//

#import "RCChatsListViewCard.h"
#import "RCChatController.h"
#import "RCChannelCell.h"
#import "RCNetworkHeaderButton.h"

@implementation RCChatsListViewCard
@synthesize isRearranging;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		navigationBar = [[RCChatNavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		[self addSubview:navigationBar];
		navigationBar.layer.zPosition = 100000;
		[navigationBar release];
		[self setOpaque:YES];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"us.mxms.relay.reload" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeNetwork:) name:@"us.mxms.relay.del" object:nil];
		_reloading = NO;
		datas = [[RCSpecialTableView alloc] initWithFrame:CGRectMake(0, 44, 320, frame.size.height-44) style:UITableViewStylePlain];
		[datas setDelegate:self];
		[datas setDataSource:self];
		[datas setRearrangeDelegate:self];
		[datas setShouldImmobilizeFirstCell:YES];
		[datas setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		[datas setBackgroundColor:[UIColor clearColor]];
		[self addSubview:datas];
		[datas release];
		[self setOpaque:YES];
		RCBarButtonItem *st = [[RCBarButtonItem alloc] initWithFrame:CGRectMake(0, 1, 50, 45)];
		[st addTarget:[RCChatController sharedController] action:@selector(showNetworkListOptions) forControlEvents:UIControlEventTouchUpInside];
		[st setImage:[UIImage imageNamed:@"settingsbutton"] forState:UIControlStateNormal];
		[navigationBar addSubview:st];
		[st release];
		RCBarButtonItem *add = [[RCBarButtonItem alloc] initWithFrame:CGRectMake(0, 1, 50, 45)];
		[add addTarget:[RCChatController sharedController] action:@selector(showNetworkAddViewController) forControlEvents:UIControlEventTouchUpInside];
		[add setImage:[UIImage imageNamed:@"newnetworkbutton"] forState:UIControlStateNormal];
		[navigationBar addSubview:add];
		[add release];
    }
    return self;
}

- (void)scrollToTop {
	[datas setContentOffset:CGPointMake(0, 100) animated:YES];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[UIColorFromRGB(0x353538) set];
	UIRectFill(rect);
}

- (void)removeNetwork:(NSNotification *)_net {
	RCNetwork *net = [[RCNetworkManager sharedNetworkManager] networkWithDescription:[_net object]];
	[[RCNetworkManager sharedNetworkManager] removeNet:net];
	[self reloadData];
}

- (void)tableView:(UITableView *)tableView movedCellFromIndex:(NSIndexPath *)idx toIndex:(NSIndexPath *)newIdx {
	RCNetwork *net = [[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:idx.section];
	[net moveChannelAtIndex:idx.row toIndex:newIdx.row];
}

- (BOOL)tableView:(UITableView *)tableView canDragCell:(UITableViewCell *)cell {
	RCChannelCell *nCell = (RCChannelCell *)cell;
	return !([[nCell channel] isEqualToString:@"\x01IRC"]);
}

- (void)tableView:(UITableView *)tableView cellDidBeginDragging:(UITableViewCell *)cell {
	isRearranging = YES;
	[UIView animateWithDuration:0.1 animations:^ {
		[cell setAlpha:0.7];
	}];
}

- (void)tableView:(UITableView *)tableView cellDidFinishDragging:(UITableViewCell *)cell {
	isRearranging = NO;
	[UIView animateWithDuration:0.1 animations:^ {
		[cell setAlpha:1.0];
	}];
}

- (void)reloadData {
	_reloading = YES;
	[datas reloadData];
	_reloading = NO;
	[datas reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (_reloading) return 0;
	RCNetwork *net = [[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:section];
	return (net.expanded ? [[net _channels] count] : 0);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (_reloading) return 0;
	return [[[RCNetworkManager sharedNetworkManager] networks] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 35;
}

- (RCChannelCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *ident = @"0_fcell";
	RCChannelCell *cell = (RCChannelCell *)[tableView dequeueReusableCellWithIdentifier:ident];
	if (!cell) {
		cell = [[[RCChannelCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident] autorelease];
	}
	if ([[[RCNetworkManager sharedNetworkManager] networks] count] == 0) {
		[tableView reloadData];
		return cell;
	}
	RCNetwork *net = [[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.section];
	RCChannel *indexChannel = [[net _channels] objectAtIndex:indexPath.row];
	[indexChannel setCellRepresentation:cell];
	[cell setChannel:[indexChannel channelName]];
	[cell setWhite:NO];
	[cell setNewMessageCount:[indexChannel newMessageCount]];
	[cell setHasHighlights:[indexChannel hasHighlights]];
	RCChannel *chan = [[[RCChatController sharedController] currentPanel] channel];
	if ([[net uUID] isEqual:[[chan delegate] uUID]]) {
		if ([cell.channel isEqualToString:[chan channelName]]) {
			[cell setWhite:YES];
		}
	}
	[cell setNeedsDisplay];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if ([[[RCNetworkManager sharedNetworkManager] networks] count] < 1) {
		[tableView reloadData];
		return nil;
	}
	RCNetworkHeaderButton *bts = [[RCNetworkHeaderButton alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	RCNetwork *use = [[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:section];
	[bts setSection:section];
	[bts setNetwork:use];
	[bts setBackgroundColor:[UIColor clearColor]];
	[bts addTarget:self action:@selector(headerTapped:) forControlEvents:UIControlEventTouchUpInside];
	BOOL shouldGlow_ = NO;
	for (RCChannel *chan in [use _channels]) {
		if ([chan newMessageCount] > 0) {
			shouldGlow_ = YES;
			break;
		}
	}
	[bts setShowsGlow:shouldGlow_];
	return [bts autorelease];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	RCChannelCell *cc = (RCChannelCell *)[tableView cellForRowAtIndexPath:indexPath];
	[cc setWhite:YES];
	[cc setNeedsDisplay];
	RCNetwork *net = [[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.section];
	[[RCChatController sharedController] selectChannel:[cc channel] fromNetwork:net];
	[tableView reloadData];
}

- (void)headerTapped:(RCNetworkHeaderButton *)hb {
	if ([datas isRearranging]) return;
	if (rearrangingHeaders) return;
	if ([[hb net] expanded]) {
		[hb setSelected:NO];
		[[hb net] setExpanded:NO];
		NSMutableArray *adds = [[NSMutableArray alloc] init];
		for (int i = 0; i < [[[hb net] _channels] count]; i++) {
			[adds addObject:[NSIndexPath indexPathForRow:i inSection:[hb section]]];
		}
		[datas beginUpdates];
		[datas deleteRowsAtIndexPaths:adds withRowAnimation:UITableViewRowAnimationTop];
		[datas endUpdates];
		[adds release];
	}
	else {
		[hb setSelected:YES];
		[[hb net] setExpanded:YES];
		NSMutableArray *adds = [[NSMutableArray alloc] init];
		for (int i = 0; i < [[[hb net] _channels] count]; i++) {
			[adds addObject:[NSIndexPath indexPathForRow:i inSection:[hb section]]];
		}
		[datas beginUpdates];
		[datas insertRowsAtIndexPaths:adds withRowAnimation:UITableViewRowAnimationTop];
		[datas endUpdates];
		[adds release];
	}
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
