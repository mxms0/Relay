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
#import "RCNetwork.h"

@implementation RAChatController

- (RAChannelProxy *)proxyForChannel:(RCChannel *)channel {
	static char RAChannelProxyAssociationKey;
	RAChannelProxy *proxy = objc_getAssociatedObject(channel, &RAChannelProxyAssociationKey);
	if (!proxy) {
		proxy = [[RAChannelProxy alloc] initWithChannel:channel];
		objc_setAssociatedObject(channel, &RAChannelProxyAssociationKey, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return proxy;
}

- (void)channel:(RCChannel *)channel userJoined:(NSString *)user {
//	RAChannelProxy *proxy = [self proxyForChannel:channel];
	
}

- (void)channel:(RCChannel *)channel userParted:(NSString *)user message:(NSString *)message {
//	RAChannelProxy *proxy = [self proxyForChannel:channel];
	
}

- (void)channel:(RCChannel *)channel userKicked:(NSString *)user reason:(NSString *)message {
//	RAChannelProxy *proxy = [self proxyForChannel:channel];
}

- (void)channel:(RCChannel *)channel userBanned:(NSString *)user reason:(NSString *)reason {
//	RAChannelProxy *proxy = [self proxyForChannel:channel];
	
}

- (void)channel:(RCChannel *)channel userModeChanged:(NSString *)user modes:(int)modes {
	
}

- (void)channel:(RCChannel *)channel receivedMessage:(NSString *)message from:(NSString *)from time:(time_t)time {
	
}

- (void)networkConnected:(RCNetwork *)network {
	
}

- (void)networkDisconnected:(RCNetwork *)network {
	
}

- (void)network:(RCNetwork *)network serverSentLine:(RCLineType)lineType {
	
}

- (void)network:(RCNetwork *)network connectionFailed:(RCConnectionFailure)fail {
	
}

@end
