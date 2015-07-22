//
//  RAViewController.m
//  Relay IRC
//
//  Created by Max Shavrick on 7/20/15.
//  Copyright (c) 2015 Mxms. All rights reserved.
//

#import "RAViewController.h"
#import "RCNetwork.h"

@implementation RAViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	RCNetwork *network = [[RCNetwork alloc] init];
	[network setServer:@"irc.saurik.com"];
	[network setPort:6667];
	[network setUsername:@"Maximus"];
	[network setRealname:@"Maximus"];
	[network setNick:@"Maximus"];
	[network setDelegate:self];
	[network setChannelDelegate:self];
	[network connect];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)channel:(RCChannel *)channel userJoined:(NSString *)user {
	
}

- (void)channel:(RCChannel *)channel userParted:(NSString *)user {
	
}

- (void)channel:(RCChannel *)channel userKicked:(NSString *)user {
	
}

- (void)channel:(RCChannel *)channel userBanned:(NSString *)user {
	
}

- (void)channel:(RCChannel *)channel userModeChanged:(NSString *)user modes:(int)modes {
	
}

- (void)channel:(RCChannel *)channel receivedMessage:(RCMessage *)message from:(NSString *)from time:(time_t)time {
	
}

- (void)networkConnected:(RCNetwork *)network {
	
}

- (void)networkDisconnected:(RCNetwork *)network {
	
}

- (void)network:(RCNetwork *)network serverSentLine:(RCLineType)lineType {
	
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
