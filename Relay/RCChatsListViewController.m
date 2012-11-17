//
//  RCChatsListViewController.m
//  Relay
//
//  Created by Max Shavrick on 10/26/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChatsListViewController.h"

@implementation RCChatsListViewController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
	if ((self = [super initWithRootViewController:rootViewController])) {
		[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"0_bg"]]];
		datas = [[RCSpecialTableView alloc] initWithFrame:CGRectMake(0, 44, 320, rootViewController.view.frame.size.height-44) style:UITableViewStylePlain];
		[datas setDelegate:self];
		[datas setDataSource:self];
		[datas setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		[datas setBackgroundColor:[UIColor clearColor]];
		[self.view addSubview:datas];
		[datas release];
		[self.view setOpaque:YES];
		self.title = @"";
		[[NSNotificationCenter defaultCenter] addObserver:datas selector:@selector(reloadData) name:@"us.mxms.relay.reload" object:nil];
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	UIButton *renchthing = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 41, 31)];
	[renchthing addTarget:self action:@selector(showPreferences:) forControlEvents:UIControlEventTouchUpInside];
	[renchthing setImage:[UIImage imageNamed:@"0_prefs"] forState:UIControlStateNormal];
	[renchthing setImage:[UIImage imageNamed:@"0_prefs_p"] forState:UIControlStateHighlighted];
	UIBarButtonItem *bbs = [[UIBarButtonItem alloc] initWithCustomView:renchthing];
	[[[[self viewControllers]  objectAtIndex:0] navigationItem] setLeftBarButtonItem:bbs animated:NO];
	[bbs release];
	[renchthing release];
}

- (void)showPreferences:(id)unused {

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	RCNetwork *net = [[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:section];
	return (net.expanded ? [[net _channels] count] : 0);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[[RCNetworkManager sharedNetworkManager] networks] count];
}

- (RCNetworkCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *ident = @"0_fcell";
	RCNetworkCell *cell = (RCNetworkCell *)[tableView dequeueReusableCellWithIdentifier:ident];
	if (!cell) {
		cell = [[RCNetworkCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident];
	}
	RCNetwork *net = [[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.section];
	[cell setChannel:[[[net _channels] objectAtIndex:indexPath.row] channelName]];
	[cell setWhite:NO];
	RCChannel *chan = [[[RCChatController sharedController] currentPanel] channel];
	if ([[net _description] isEqual:[[chan delegate] _description]]) {
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
	if ([[[RCNetworkManager sharedNetworkManager] networks] count] < 1) return nil;
	RCNetworkHeaderButton *bts = [[RCNetworkHeaderButton alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	[bts setSection:section];
	[bts setNetwork:[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:section]];
	[bts setBackgroundColor:[UIColor clearColor]];
	[bts addTarget:self action:@selector(headerTapped:) forControlEvents:UIControlEventTouchUpInside];
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
		[[hb net] setExpanded:NO];
		NSMutableArray *adds = [[NSMutableArray alloc] init];
		for (int i = 0; i < [[[hb net] _channels] count]; i++) {
			[adds addObject:[NSIndexPath indexPathForRow:i inSection:[hb section]]];
		}
		[datas beginUpdates];
		[datas deleteRowsAtIndexPaths:adds withRowAnimation:UITableViewRowAnimationAutomatic];
		[datas endUpdates];
		[adds release];
	}
	else {
		[[hb net] setExpanded:YES];
		NSMutableArray *adds = [[NSMutableArray alloc] init];
		for (int i = 0; i < [[[hb net] _channels] count]; i++) {
			[adds addObject:[NSIndexPath indexPathForRow:i inSection:[hb section]]];
		}
		[datas beginUpdates];
		[datas insertRowsAtIndexPaths:adds withRowAnimation:UITableViewRowAnimationAutomatic];
		[datas endUpdates];
		[adds release];
	}
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
