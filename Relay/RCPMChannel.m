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
#import "RCChannelScrollView.h"
#import "NSString+IRCStringSupport.h"

@implementation RCPMChannel

- (id)initWithChannelName:(NSString *)_name {
	if ((self = [super initWithChannelName:_name])) {
	}
	return self;
}

- (void)changeNick:(NSString*)old toNick:(NSString*)new_
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
        @synchronized(self)
        {
            if ([old isEqualToString:[self channelName]]) {
                if ([[self delegate] channelWithChannelName: new_]) {
                    id nself = [[self delegate] channelWithChannelName: new_];
                    [(RCChannelScrollView*)[[nself bubble] superview] layoutChannels:[[nself delegate] _bubbles]];
                    if ([[[[[RCNavigator sharedNavigator] currentNetwork] currentChannel] channelName] isEqualToString:[self channelName]]) {
                        [[RCNavigator sharedNavigator] scrollToBubble:[nself bubble]];
                        [[RCNavigator sharedNavigator] channelSelected:[nself bubble]];
                    }
                    [self recievedMessage:[NSString stringWithFormat:@"%c\u2022 %@%c is now known as %c%@%c", RCIRCAttributeBold, old, RCIRCAttributeBold, RCIRCAttributeBold, new_, RCIRCAttributeBold] from:@"" type:RCMessageTypeNormalE];
                    [nself recievedMessage:[NSString stringWithFormat:@"%c\u2022 %@%c is now known as %c%@%c", RCIRCAttributeBold, old, RCIRCAttributeBold, RCIRCAttributeBold, new_, RCIRCAttributeBold] from:@"" type:RCMessageTypeNormalE];
                    return;
                }
                [self setChannelName:new_];
                [[self bubble] setTitle:new_ forState:UIControlStateNormal];
                CGSize size = [new_ sizeWithFont:[UIFont boldSystemFontOfSize:14]];
                [[self bubble] setFrame:CGRectMake(0, 0, size.width+=14, 18)];
                [(RCChannelScrollView*)[[self bubble] superview] layoutChannels:[[self delegate] _bubbles]];
                if ([[[[[RCNavigator sharedNavigator] currentNetwork] currentChannel] channelName] isEqualToString:[self channelName]])
                    [[RCNavigator sharedNavigator] scrollToBubble:[self bubble]];
            }
            [self recievedMessage:[NSString stringWithFormat:@"%c\u2022 %@%c is now known as %c%@%c", RCIRCAttributeBold, old, RCIRCAttributeBold, RCIRCAttributeBold, new_, RCIRCAttributeBold] from:@"" type:RCMessageTypeNormalE];
        }
    });
}

- (void)shouldPost:(BOOL)isHighlight withMessage:(NSString *)msg {
    [self setUserJoined:[self channelName]];
    [self setUserJoined:[delegate useNick]];
	BOOL iAmCurrent = NO;
	if ([[RCNavigator sharedNavigator] currentPanel])
		iAmCurrent = [[[[RCNavigator sharedNavigator] currentPanel] channel] isEqual:self];
	if ([[RCNetworkManager sharedNetworkManager] isBG]) {
        UILocalNotification *nc = [[UILocalNotification alloc] init];
        [nc setFireDate:[NSDate date]];
        [nc setAlertBody:[msg stringByStrippingIRCMetadata]];
        [nc setSoundName:UILocalNotificationDefaultSoundName];
		[[UIApplication sharedApplication] scheduleLocalNotification:nc];
		[nc release];
	}
}

- (void)setJoined:(BOOL)joind withArgument:(NSString *)arg1
{
    return;
}

- (void)setSuccessfullyJoined:(BOOL)success
{
    return;
}

- (void)setJoined:(BOOL)joind
{
    return;
}

- (BOOL)joined
{
    return YES;
}

- (BOOL)isUserInChannel:(NSString*)user {
    return [user isEqualToString:channelName]||[user isEqualToString:[[self delegate] useNick]];
}

- (BOOL)isPrivate {
    return YES;
}

@end
