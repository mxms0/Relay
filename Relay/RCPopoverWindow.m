//
//  RCPopoverWindow.m
//  Relay
//
//  Created by Max Shavrick on 6/18/12.
//

#import "RCPopoverWindow.h"
#import "RCNetworkManager.h"

@implementation RCPopoverWindow
@synthesize shouldRePresentKeyboardOnDismiss;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		networkTable = [[RCSpecialTableView alloc] initWithFrame:CGRectMake(33, 43, 253, 267) style:UITableViewStylePlain];
		networkTable.layer.cornerRadius = 14;
		networkTable.delegate = self;
		networkTable.backgroundColor = [UIColor clearColor];
		networkTable.separatorStyle = UITableViewCellSeparatorStyleNone;
		networkTable.dataSource = self;
		[networkTable setBackgroundColor:[UIColor clearColor]];
		[networkTable setBackgroundView:nil];
		[networkTable setShowsVerticalScrollIndicator:NO];
		_pImg = [[UIImageView alloc] initWithFrame:CGRectMake(26, 28, 268, 300)];
		[_pImg setImage:[UIImage imageNamed:@"0_popover"]];
		[self addSubview:_pImg];
		[_pImg release];
		[self addSubview:networkTable];
        [networkTable setScrollsToTop:NO];
		[networkTable release];
		self.hidden = YES;
		self.opaque = NO;
		self.alpha = 0;
		self.shouldRePresentKeyboardOnDismiss = NO;
		applicationDelegate = [UIApp delegate];
    }
    return self;
}

- (void)reloadData {
    [networkTable reloadData];
}

- (void)animateIn {
	self.hidden = NO;
	self.alpha = 0;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.25];
	self.alpha = 1;
	[UIView commitAnimations];	
}

- (void)animateOut {
	[UIView animateWithDuration:0.25 animations:^ {
		self.alpha = 0;	
	} completion:^(BOOL fin) {
		[self removeFromSuperview];
		self.hidden = YES;
		if (shouldRePresentKeyboardOnDismiss)
			[[[RCNavigator sharedNavigator] currentPanel] becomeFirstResponder];
		self.shouldRePresentKeyboardOnDismiss = NO;
	}];
}

- (void)correctAndRotateToInterfaceOrientation:(UIInterfaceOrientation)oi {
	BOOL animate = NO;
	if (!self.hidden) {
		animate = YES;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.25];
	}
	if (UIInterfaceOrientationIsLandscape(oi)) {
		[_pImg setImage:[UIImage imageNamed:@"0_popover_l"]];
		_pImg.frame = CGRectMake(-1, 29, 242, 234);
		networkTable.frame = CGRectMake(2, 38, 253, 300);
	}
	/* XXXX: FIX THESE NUMBERS WHEN SURENIX GETS TO IT */
	else {
		[_pImg setImage:[UIImage imageNamed:@"0_popover"]];
		[networkTable setFrame:CGRectMake(33, 43, 253, 300)];
		[_pImg setFrame:CGRectMake(26, 28, 268, 300)];
	}
	if (animate) {
		[UIView commitAnimations];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 1.2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	RCNetworkHeaderButton *btn = [[RCNetworkHeaderButton alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
	UILongPressGestureRecognizer *pp = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(headerLongPress:)];
	[btn addGestureRecognizer:pp];
	[pp release];
	[btn setSection:section];
	[btn setNetwork:[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:section]];
	[btn setBackgroundColor:[UIColor clearColor]];
	[btn addTarget:self action:@selector(headerTouched:) forControlEvents:UIControlEventTouchUpInside];
	return [btn autorelease];
}

- (void)headerLongPress:(UILongPressGestureRecognizer *)press {
	if ([press state] != UIGestureRecognizerStateBegan)
		return;
	RCNetworkHeaderButton *hb = (RCNetworkHeaderButton *)[press view];
	if ([[hb net] expanded]) {
		[[hb net] setExpanded:NO];
		NSMutableArray *adds = [[NSMutableArray alloc] init];
		for (int i = 0; i < [[[hb net] _channels] count]; i++) {
			[adds addObject:[NSIndexPath indexPathForRow:i inSection:[hb section]]];
		}
		[networkTable beginUpdates];
		[networkTable deleteRowsAtIndexPaths:adds withRowAnimation:UITableViewRowAnimationAutomatic];
		[networkTable endUpdates];
		[adds release];
	}
	else {
		[[hb net] setExpanded:YES];
		NSMutableArray *adds = [[NSMutableArray alloc] init];
		for (int i = 0; i < [[[hb net] _channels] count]; i++) {
			[adds addObject:[NSIndexPath indexPathForRow:i inSection:[hb section]]];
		}
		[networkTable beginUpdates];
		[networkTable insertRowsAtIndexPaths:adds withRowAnimation:UITableViewRowAnimationAutomatic];
		[networkTable endUpdates];
		[adds release];
	}
}

- (void)headerTouched:(RCNetworkHeaderButton *)headr {
	NSArray *nets = [[RCNetworkManager sharedNetworkManager] networks];
	for (RCNetwork *net in nets) {
		[net set_selected:NO];
	}
	[[headr net] set_selected:YES];
	[[RCNavigator sharedNavigator] selectNetwork:[headr net]];
	[self animateOut];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *ident = @"0_networkcell";
	RCNetworkCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
	if (!cell) {
		cell = [[[RCNetworkCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident] autorelease];
	}
	RCNetwork *net = [[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.section];
	[cell setChannel:[[[net _channels] objectAtIndex:indexPath.row] channelName]];
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	[cell setNeedsDisplay];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	RCNetwork *net = [[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.section];
	if (![[net _description] isEqualToString:[[[RCNavigator sharedNavigator] currentNetwork] _description]]) {
		[[RCNavigator sharedNavigator] selectNetwork:net];
	}
	RCNetworkCell *cc = (RCNetworkCell *)[tableView cellForRowAtIndexPath:indexPath];
	RCChannel *chan = [net channelWithChannelName:[cc channel]];
	[[RCNavigator sharedNavigator] channelSelected:[chan bubble]];
	[self animateOut];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	RCNetwork *net = [[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:section];
	return (net.expanded ? [[net _channels] count] : 0);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self animateOut];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[[RCNetworkManager sharedNetworkManager] networks] count];
}

@end
