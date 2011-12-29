//
//  RCViewController.m
//  Relay
//
//  Created by Max Shavrick on 12/23/11.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import "RCViewController.h"


@implementation RCViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[[RCNetworkManager sharedNetworkManager] networks] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIButton *view = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 45)];
	[view addTarget:self action:@selector(headerPushed:) forControlEvents:UIControlEventTouchUpInside];
	UILabel *_description = [[UILabel alloc] initWithFrame:CGRectMake(5, -2, view.frame.size.width/3, 25)];
	_description.text = [[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:section] sDescription];
	[_description setBackgroundColor:[UIColor clearColor]];
	[view addSubview:_description];
	[_description release];
	UILabel *_status = [[UILabel alloc] initWithFrame:CGRectMake(view.frame.size.width-155, -2, 150, 25)];
	[_status setTextAlignment:UITextAlignmentRight];
	_status.text = [[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:section] connectionStatus];
	[_status setBackgroundColor:[UIColor clearColor]];
	[view addSubview:_status];
	[_status release];
	[view setBackgroundColor:[UIColor orangeColor]];
	return [view autorelease];
}

- (void)headerPushed:(UIButton *)btn {
	for (RCNetwork *net in [[RCNetworkManager sharedNetworkManager] networks]) {

	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	if ([((RCNetwork *)[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.row]) isConnected])
		[((RCNetwork *)[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.row]) disconnect];
	else [((RCNetwork *)[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.row]) connect];
	[tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"0CELL";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier] autorelease];
	}
	cell.textLabel.text = [[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.row] sDescription];
	cell.detailTextLabel.text = [[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.row] connectionStatus];
	return cell;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
	[[RCNetworkManager sharedNetworkManager] unpack];
    [super viewDidLoad];

	[[NSNotificationCenter defaultCenter] addObserver:self.tableView selector:@selector(reloadData) name:@"RELOAD_NETWORKS" object:nil];
	[self.view setBackgroundColor:[UIColor whiteColor]];
	self.title = @"Relay";
	[self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewConnection)] autorelease]];
//	[[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:0] joinRoom:@"#hai"];
//	RCNetwork *net = [RCNetwork createNetworkWithAddress:@"fr.ac3xx.com" port:6667 wantsSSL:NO description:@"moonlight" withUsername:@"TestBot" andNickname:@"TestBot" realName:@"TestBot" serverPassword:@"privateircftw" nickServPass:nil];
//	[net connect];
	NSLog(@"ya. %@", [[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:0] channels]);
}

- (void)addRoom:(NSString *)room {
//	[rooms addObject:room];
	[self.tableView reloadData];
}

- (void)addNewConnection {
	RCAddNetworkViewController *vc = [[RCAddNetworkViewController alloc] initWithStyle:UITableViewStyleGrouped];
	UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
	nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentModalViewController:nav animated:YES];
	[vc release];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end
