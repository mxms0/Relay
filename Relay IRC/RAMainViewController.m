//
//  RAMainViewController.m
//  Relay IRC
//
//  Created by Max Shavrick on 7/20/15.
//  Copyright (c) 2015 Mxms. All rights reserved.
//

#import "RAMainViewController.h"
#import "RANetworkManager.h"
#import "RAChatController.h"
#import "RATableHeaderView.h"

static const CGFloat RANetworkHeaderViewHeight = 40.0f;

@implementation RAMainViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	[(RANavigationBar *)self.navigationController.navigationBar setTapDelegate:self];
	
	CALayer *statusBarFix = [CALayer layer];
	[statusBarFix setBackgroundColor:[[UIColor colorWithRed:49/255.0 green:67/255.0 blue:82/255.0 alpha:1.0] CGColor]];
	[statusBarFix setFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
	[self.view.layer addSublayer:statusBarFix];
	
	self.view.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
	
	NSArray *nets = @[
					  @"irc.saurik.com",
					  @"irc.freenode.org",
					  @"irc.rizon.net"
					  ];
	
	for (NSString *str in nets) {
		RCNetwork *net = [[RCNetwork alloc] init];
		[net setServer:str];
		[net setDelegate:controller];
		[net setChannelDelegate:controller];
		[net setPort:6667];
		[net setUsername:@"Maximus"];
		[net setNick:@"Maximus"];
		[net setRealname:@"Maximus"];
		[[RANetworkManager sharedNetworkManager] addNetwork:net];
		[net release];
	}
	
	networks = [[RATableView alloc] init];
	[self.view addSubview:networks];
	networks.delegate = self;
	networks.dataSource = self;
	networks.sectionHeaderHeight = RANetworkHeaderViewHeight;
	networks.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20);
	
	NSLog(@"FDs %@", [[RANetworkManager sharedNetworkManager] networks]);
}

- (void)navigationBarButtonWasPressed:(RANavigationBarButton *)btn {
	// bring down RANetworkSelectionView
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[[RANetworkManager sharedNetworkManager] networks] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[[[[RANetworkManager sharedNetworkManager] networks] objectAtIndex:section] channels] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	RCNetwork *network = [[[RANetworkManager sharedNetworkManager] networks] objectAtIndex:section];
	RATableHeaderView *header = [[RATableHeaderView alloc] init];
	header.textLabel.text = [network _description];
	header.detailTextLabel.text = [network server];
	return [header autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"f"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"f"];
	}

//	cell.textLabel.text = [channelMessages objectAtIndex:indexPath.row];
	
	return cell;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
