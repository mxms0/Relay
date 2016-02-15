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
#import "RAChannelProxy.h"
#import "RCDefaultMessageFormatter.h"
#import "RCNetwork.h"
#import <objc/runtime.h>

RAChannelProxy *RAChannelProxyForChannel(RCChannel *channel) {
	if (!channel) return nil;
	static NSString *RAChannelProxyAssociationKey = @"RAChannelProxyAssociationKey";
	RAChannelProxy *proxy = objc_getAssociatedObject(channel, RAChannelProxyAssociationKey);
	if (!proxy) {
		proxy = [[RAChannelProxy alloc] initWithChannel:channel];
		objc_setAssociatedObject(channel, RAChannelProxyAssociationKey, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return [[proxy retain] autorelease];
}

@implementation RAChatController

- (void)channel:(RCChannel *)channel userJoined:(NSString *)user {
//	RAChannelProxy *proxy = [self proxyForChannel:channel];
	
}

- (void)channel:(RCChannel *)channel userParted:(NSString *)user message:(NSString *)message {
//	RAChannelProxy *proxy = [self proxyForChannel:channel];
	
}

- (void)channel:(RCChannel *)channel userKicked:(NSString *)user kicker:(NSString *)kicker reason:(NSString *)message {
//	RAChannelProxy *proxy = [self proxyForChannel:channel];
}

- (void)channel:(RCChannel *)channel userBanned:(NSString *)user banner:(NSString *)banner {
//	RAChannelProxy *proxy = [self proxyForChannel:channel];
	
}

- (void)channel:(RCChannel *)channel userModeChanged:(NSString *)user modes:(int)modes {
	
}

- (void)channel:(RCChannel *)channel receivedMessage:(RCMessage *)message {
	RAChannelProxy *proxy = RAChannelProxyForChannel(channel);
	RCDefaultMessageFormatter *formatter = [[RCDefaultMessageFormatter alloc] initWithMessage:message];
	NSString *formatted = [formatter formattedMessage];
	[proxy addMessage:formatted];
	if ([[self.delegate currentChannelProxy] isEqual:proxy]) {
		[self.delegate chatControllerWantsUpdateUI:self];
	}
}

- (void)networkConnected:(RCNetwork *)network {
	NSLog(@"Connecetd %@", network);
	[network addChannel:@"#fds" join:YES];
}

- (void)networkDisconnected:(RCNetwork *)network {
	
}

- (void)network:(RCNetwork *)network serverSentLine:(RCLineType)lineType {
	
}

- (void)network:(RCNetwork *)network connectionFailed:(RCConnectionFailure)fail {
	
}

- (void)network:(RCNetwork *)network receivedNotice:(NSString *)notice user:(NSString *)user {
	RAChannelProxy *proxy = RAChannelProxyForChannel([network consoleChannel]);
	[proxy addMessage:notice];
}

@end
