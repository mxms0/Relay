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

	currentChannel = nil;
	
	[(RANavigationBar *)self.navigationController.navigationBar setTapDelegate:self];
	
	controller = [[RAChatController alloc] init];
	[controller setDelegate:self];
	
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
		[net setChannelCreationHandler:^(RCChannel *channel) {
			static NSString *RAChannelProxyAssociationKey = @"RAChannelProxyAssociationKey";
			RAChannelProxy *proxy = objc_getAssociatedObject(channel, RAChannelProxyAssociationKey);
			if (!proxy) {
				proxy = [[RAChannelProxy alloc] initWithChannel:channel];
				objc_setAssociatedObject(channel, RAChannelProxyAssociationKey, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
			}
		}];
		
		[net createConsoleChannel];
		[net connect];
		[[RANetworkManager sharedNetworkManager] addNetwork:net];
		[net release];
	}
	
	currentChannel = RAChannelProxyForChannel([[[RANetworkManager sharedNetworkManager] networks][2] consoleChannel]);
	NSLog(@"Fds %@", currentChannel);
	
	conversationView = [[RATableView alloc] init];
	[self.view addSubview:conversationView];
	conversationView.delegate = self;
	conversationView.dataSource = self;
//	conversationView.sectionHeaderHeight = RANetworkHeaderViewHeight;
	conversationView.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - 20);
	
	[conversationView performSelector:@selector(reloadData) withObject:nil afterDelay:2];
	
	
	NSLog(@"FDs %@", [[RANetworkManager sharedNetworkManager] networks]);
}

- (RAChannelProxy *)currentChannelProxy {
	return currentChannel;
}

- (void)chatControllerWantsUpdateUI:(RAChatController *)controller {
	
}

- (void)navigationBarButtonWasPressed:(RANavigationBarButton *)btn {
	// bring down RANetworkSelectionView
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[currentChannel messages] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"f"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"f"];
	}
	cell.textLabel.text = [[currentChannel messages] objectAtIndex:indexPath.row];
//	cell.textLabel.text = [channelMessages objectAtIndex:indexPath.row];
	
	return cell;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
