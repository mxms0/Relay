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
		datas = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, 320, 504) style:UITableViewStylePlain];
		[datas setDelegate:self];
		[datas setDataSource:self];
		[datas setBackgroundColor:[UIColor clearColor]];
		[self.view addSubview:datas];
		[datas release];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *ident = @"0_fcell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident];
	}
	return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	RCNetworkHeaderButton *bts = [[RCNetworkHeaderButton alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
	[bts setSection:section];
	[bts setNetwork:[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:section]];
	[bts setBackgroundColor:[UIColor clearColor]];
	return [bts autorelease];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
