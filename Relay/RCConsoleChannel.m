//
//  RCConsoleChannel.m
//  Relay
//
//  Created by Max Shavrick on 2/26/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCConsoleChannel.h"

@implementation RCConsoleChannel

- (void)userWouldLikeToPartakeInThisConversation:(NSString *)message {
	[delegate sendMessage:message];
}

@end
