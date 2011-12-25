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
	return [[[RCNetworkManager sharedNetworkManager] networks] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *identifier = @"0CELL";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	}
//	cell.textLabel.text = [rooms objectAtIndex:indexPath.row];
	return cell;
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	[[RCNetworkManager sharedNetworkManager] unpack];
	
	[self.view setBackgroundColor:[UIColor whiteColor]];
	self.title = @"Relay";
	[self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewConnection)] autorelease]];
	
	RCSocket *sock = [[RCSocket alloc] init];
	[sock setServer:@"irc.evilpengu.in"];
	[sock setPort:6667];
	[sock setWantsSSL:NO];
//	[sock setServPass:@"privateircftw"];
	if ([sock connect]) {
		//fdsfsd
	}
	// Do any additional setup after loading the view, typically from a nib.
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
