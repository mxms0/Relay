//
//  RAChannelProxy.m
//  Relay IRC
//
//  Created by Max Shavrick on 7/26/15.
//  Copyright (c) 2015 Mxms. All rights reserved.
//

#import "RAChannelProxy.h"
#import "RCChannel.h"

@implementation RAChannelProxy

- (instancetype)initWithChannel:(RCChannel *)channel {
	if ((self = [super init])) {
		messages = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)addMessage:(NSString *)message {
	@synchronized(messages) {
		[messages addObject:message];
	}
}

- (NSMutableArray<NSString *> *)messages {
	return messages;
}

@end
