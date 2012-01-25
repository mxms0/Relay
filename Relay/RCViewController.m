//
//  RCViewController.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCViewController.h"

@implementation RCViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - TABLE_VIEW SHIT

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
		NSLog(@"nffff %@", [[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:section] channels]);
	return [[[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:section] channels] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return [[[RCNetworkManager sharedNetworkManager] networks] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	RCTableCell *_c = [tableView dequeueReusableCellWithIdentifier:@"0_CELL_0"];
	if (_c == nil) {
		_c = [[[RCTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"0_CELL_0"] autorelease];
		_c.selectionStyle = UITableViewCellSelectionStyleGray;
	}
	RCNetwork *net = [[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.section];
	_c.textLabel.text = [[[net channels] objectAtIndex:indexPath.row] channelName];

//	_c.textLabel.text = [[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.section] sDescription];
//	_c.detailTextLabel.text = ([[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.row] connectionStatus]);
	return _c;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
//	RCNetwork *net = [[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.section];
//	if ([net isConnected]) [net disconnect];
//	else [net connect];
	
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	RCTableHeaderView *header = [[RCTableHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 25)];
	[header setNetwork:[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:section]];
	return [header autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60.0;
}

#pragma mark - VIEW SHIT

- (void)viewDidLoad {
	[[NSNotificationCenter defaultCenter] addObserver:[self tableView] selector:@selector(reloadData) name:RELOAD_KEY object:nil];
    [super viewDidLoad];
	self.title = @"Relay";
	[[self view] setBackgroundColor:[UIColor blackColor]];
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	(void)[RCNetworkManager sharedNetworkManager];
	[RCNetworkManager ircNetworkWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:
										  @"_m", USER_KEY, 
										  @"_m", NICK_KEY,
										  @"0_m_hai", NAME_KEY,
										  @"privateircftw", S_PASS_KEY,
										  @"", N_PASS_KEY,
										  @"feer", DESCRIPTION_KEY,
										  @"fr.ac3xx.com", SERVR_ADDR_KEY,
										  @"6667", PORT_KEY,
										  [NSNumber numberWithBool:0], SSL_KEY,
										  [NSNumber numberWithBool:1], COL_KEY,
										  [NSArray arrayWithObjects:@"#chat", @"#tttt", nil], CHANNELS_KEY,
										  nil]];
	for (RCNetwork *net in [[RCNetworkManager sharedNetworkManager] networks])
		if ([net COL]) [net connect];
	NSLog(@"Nets. %@", [[RCNetworkManager sharedNetworkManager] networks]);
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	NSLog(@"[%s%d]", (char *)_cmd, animated);
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	NSLog(@"[%s%d]", (char *)_cmd, animated);
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	NSLog(@"[%s%d]", (char *)_cmd, animated);
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	NSLog(@"[%s%d]", (char *)_cmd, animated);
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

@end
