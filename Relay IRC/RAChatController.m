//
//  RAChatController.m
//  Relay IRC
//
//  Created by Max Shavrick on 7/22/15.
//  Copyright (c) 2015 Mxms. All rights reserved.
//

#import "RAChatController.h"
#import "RANavigationBar.h"
#import "RCChannel.h"
#import "RCNetwork.h"

@implementation RAChatController

+ (instancetype)sharedInstance {
	static id instance = nil;
	static dispatch_once_t token;
	
	dispatch_once(&token, ^ {
		instance = [[self alloc] init];
	});
	return instance;
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

- (void)network:(RCNetwork *)network connectionFailed:(RCConnectionFailure)fail {
	
}

- (void)layoutInterfaceWithViewController:(UINavigationController *)vc {
	[(RANavigationBar *)[vc navigationBar] setTapDelegate:self];
}

- (void)navigationBarButtonWasPressed:(RANavigationBarButton *)btn {
	// bring down RANetworkSelectionView
}

@end
