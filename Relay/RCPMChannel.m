//
//  RCPMChannel.m
//  Relay
//
//  Created by Max Shavrick on 3/24/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCPMChannel.h"
#import "RCNetworkManager.h"
#import "RCNavigator.h"

@implementation RCPMChannel

- (void)shouldPost:(BOOL)isHighlight withMessage:(NSString *)msg {
	BOOL iAmCurrent = NO;
	if ([[RCNavigator sharedNavigator] currentPanel])
		iAmCurrent = [[[[RCNavigator sharedNavigator] currentPanel] channel] isEqual:self];
	if (!iAmCurrent) [bubble setMentioned:YES];
	if ([[RCNetworkManager sharedNetworkManager] isBG]) {
		UILocalNotification *nc = [[UILocalNotification alloc] init];
		[nc setFireDate:[NSDate date]];
		[nc setAlertBody:msg];
		[[UIApplication sharedApplication] scheduleLocalNotification:nc];
		[nc release];
	}
}

@end
