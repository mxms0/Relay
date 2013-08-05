//
//  RCChatsListViewCard.m
//  Relay
//
//  Created by Max Shavrick on 6/18/13.
//

#import "RCChatsListViewCard.h"
#import "RCChatController.h"
#import "RCNetworkCell.h"
#import "RCNetworkHeaderButton.h"

@implementation RCChatsListViewCard

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		navigationBar = [[RCChatNavigationBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
		[self addSubview:navigationBar];
		[navigationBar release];
		[self setOpaque:YES];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:@"us.mxms.relay.reload" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeNetwork:) name:@"us.mxms.relay.del" object:nil];
		UIButton *adn = [[UIButton alloc] initWithFrame:CGRectMake(-20, 0, 84, 84)];
		[adn setImage:[UIImage imageNamed:@"0_adn"] forState:UIControlStateNormal];
		[adn setImage:[UIImage imageNamed:@"0_adn_pres"] forState:UIControlStateHighlighted];
		[adn addTarget:[RCChatController sharedController] action:@selector(showNetworkAddViewController) forControlEvents:UIControlEventTouchUpInside];
		_reloading = NO;
		datas = [[RCSpecialTableView alloc] initWithFrame:CGRectMake(0, 44, 320, frame.size.height-44) style:UITableViewStylePlain];
		[datas setDelegate:self];
		[datas setDataSource:self];
		[datas setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		[datas setBackgroundColor:[UIColor clearColor]];
		[datas setTableFooterView:adn];
		[adn release];
		[self addSubview:datas];
		[datas release];
		[self setOpaque:YES];
		RCBarButtonItem *st = [[RCBarButtonItem alloc] initWithFrame:CGRectMake(1, 0, 50, 45)];
		[st addTarget:[RCChatController sharedController] action:@selector(showNetworkListOptions) forControlEvents:UIControlEventTouchUpInside];
		[st setImage:[UIImage imageNamed:@"0_stb"] forState:UIControlStateNormal];
		[navigationBar addSubview:st];
		[st release];
		// i know, one day i'll actually implement settings. :p
		// sorry guys.
    }
    return self;
}

- (void)scrollToTop {
	[datas setContentOffset:CGPointMake(0, 100) animated:YES];
}

- (void)drawRect:(CGRect)rect {
	[UIColorFromRGB(0x29324A) set];
	UIRectFill(rect);
}

- (void)removeNetwork:(NSNotification *)_net {
	RCNetwork *net = [[RCNetworkManager sharedNetworkManager] networkWithDescription:[_net object]];
	[[RCNetworkManager sharedNetworkManager] removeNet:net];
	_reloading = YES;
	[datas reloadData];
	_reloading = NO;
	[datas reloadData];
}

- (void)cellWasPanned:(UIPanGestureRecognizer *)lp {
	//MARK;
	RCNetworkCell *cell = (RCNetworkCell *)[lp view];
	switch ([lp state]) {
		case UIGestureRecognizerStateBegan: {
			[[cell superview] bringSubviewToFront:cell];
			[datas setScrollEnabled:NO];
			for (UIGestureRecognizer *gz in [[lp view] gestureRecognizers]) {
				if ([gz isKindOfClass:[UILongPressGestureRecognizer class]]) {
					[gz setEnabled:NO];
					break;
				}
			}
			break;
		}
		case UIGestureRecognizerStateChanged:
			if (canDrag) {
				// find subview.
				CGPoint tr = [lp translationInView:self];
				BOOL goingDown = (tr.y > 0);
				CGPoint cr = CGPointMake([cell center].x, cell.center.y + tr.y);
				[cell setCenter:cr];
				[lp setTranslation:CGPointZero inView:self];
				for (RCNetworkCell *aCell in [datas subviews]) {
					if ([aCell isKindOfClass:[RCNetworkCell class]]) {
						if (![[cell channel] isEqualToString:[aCell channel]]) {
							if (CGRectIntersectsRect(cell.frame, aCell.frame)) {
								if ((cell.frame.origin.y < aCell.frame.origin.y) && !goingDown) {
									aCell.frame = CGRectMake(0, aCell.frame.origin.y - aCell.frame.size.height, aCell.frame.size.width, aCell.frame.size.height);
								}
								else {
									aCell.frame = CGRectMake(0, aCell.frame.origin.y + aCell.frame.size.height, aCell.frame.size.width, aCell.frame.size.height);
								}
								break;
							}
						}
					}
				}
			}
			break;
		case UIGestureRecognizerStatePossible:
			break;
		default:
			for (UIGestureRecognizer *gz in [[lp view] gestureRecognizers]) {
				if ([gz isKindOfClass:[UILongPressGestureRecognizer class]]) {
					[gz setEnabled:YES];
					break;
				}
			}
			[datas setScrollEnabled:YES];
//			if (canDrag)
//				[cell setFrame:CGRectMake(0, cell.frame.origin.y + 5, cell.frame.size.width - 10, cell.frame.size.height - 10)];
			canDrag = NO;
			break;
	}
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
	return YES;
}

- (void)cellWasHeld:(UILongPressGestureRecognizer *)lgp {
	if (!canDrag) {
		if (holdTimer) return;
		holdTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(targetBeginLongPress:) userInfo:[lgp view] repeats:NO];
	}
}

- (void)targetBeginLongPress:(NSTimer *)timer {
	if (!canDrag) {
		holdTimer = nil;
	//	RCNetworkCell *cell = [timer userInfo];
	//	[cell setFrame:CGRectMake(-5, cell.frame.origin.y - 5, cell.frame.size.width+10, cell.frame.size.height+10)];
		canDrag = YES;
	}
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

- (RCNetworkCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *ident = @"0_fcell";
	RCNetworkCell *cell = (RCNetworkCell *)[tableView dequeueReusableCellWithIdentifier:ident];
	if (!cell) {
		cell = [[[RCNetworkCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident] autorelease];
		UIPanGestureRecognizer *lpress = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasPanned:)];
		[cell addGestureRecognizer:lpress];
		[lpress setDelegate:self];
		[lpress release];
		UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(cellWasHeld:)];
		[longPress setCancelsTouchesInView:NO];
		[longPress setDelegate:self];
		[cell addGestureRecognizer:longPress];
		[longPress release];
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
	RCNetworkCell *cc = (RCNetworkCell *)[tableView cellForRowAtIndexPath:indexPath];
	[cc setWhite:YES];
	[cc setNeedsDisplay];
	RCNetwork *net = [[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.section];
	[[RCChatController sharedController] selectChannel:[cc channel] fromNetwork:net];
	[tableView reloadData];
}

- (void)headerTapped:(RCNetworkHeaderButton *)hb {
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
