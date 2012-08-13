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

- (id)initWithChannelName:(NSString *)_name {
	if ((self = [super initWithChannelName:_name])) {
	}
	return self;
}

- (void)shouldPost:(BOOL)isHighlight withMessage:(NSString *)msg {
	BOOL iAmCurrent = NO;
	if ([[RCNavigator sharedNavigator] currentPanel])
		iAmCurrent = [[[[RCNavigator sharedNavigator] currentPanel] channel] isEqual:self];
	if (!iAmCurrent) [bubble setMentioned:YES];
	if ([[RCNetworkManager sharedNetworkManager] isBG]) {
        UILocalNotification *nc = [[UILocalNotification alloc] init];
        [nc setFireDate:[NSDate date]];
        [nc setAlertBody:msg];
        [nc setSoundName:UILocalNotificationDefaultSoundName];
		[[UIApplication sharedApplication] scheduleLocalNotification:nc];
		[nc release];
	}
}
- (BOOL)isUserInChannel:(NSString*)user
{
    return [user isEqualToString:channelName];
}

- (BOOL)isPrivate
{
    return YES;
}

@end
