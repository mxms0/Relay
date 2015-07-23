//
//  RAChatController.m
//  Relay IRC
//
//  Created by Max Shavrick on 7/22/15.
//  Copyright (c) 2015 Mxms. All rights reserved.
//

#import "RAChatController.h"
#import "RANavigationBar.h"

@implementation RAChatController

+ (instancetype)sharedInstance {
	static id instance = nil;
	static dispatch_once_t token;
	
	dispatch_once(&token, ^ {
		instance = [[self alloc] init];
	});
	return instance;
}

- (void)layoutInterfaceWithViewController:(UINavigationController *)vc {
	[(RANavigationBar *)[vc navigationBar] setTapDelegate:self];
}

- (void)navigationBarButtonWasPressed:(RANavigationBarButton *)btn {
	// bring down RANetworkSelectionView
}

@end
