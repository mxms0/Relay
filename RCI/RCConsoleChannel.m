//
//  RCConsoleChannel.m
//  Relay
//
//  Created by Max Shavrick on 3/2/12.
//

#import "RCConsoleChannel.h"
#import "RCNetwork.h"
#import "NSString+IRCStringSupport.h"

@implementation RCConsoleChannel

- (id)initWithChannelName:(NSString *)_name {
	if ((self = [super initWithChannelName:_name])) {
		joined = YES;
	}
	return self;
}

- (BOOL)joined {
	return YES;
}

- (void)storePassword {
}

- (void)retrievePassword {
}

- (void)setSuccessfullyJoined:(BOOL)success {
	joined = YES;
}

- (void)userWouldLikeToPartakeInThisConversation:(NSString *)message {
	@autoreleasepool {
		if ([message hasPrefix:@"/"]) {
			[self parseAndHandleSlashCommand:[message substringFromIndex:1]];
			return;
		}
		else {
			[(RCNetwork *)delegate sendMessage:message];
			[self recievedMessage:message from:@"" time:nil type:RCMessageTypeNormalE];
		}
	}
}

- (void)recievedMessage:(RCMessage *)_message from:(NSString *)from time:(NSString *)time_ type:(RCMessageType)type {
	if ([_message respondsToSelector:@selector(numeric)]) {
		int numeric = [[_message numeric] intValue];
		switch (numeric) {
			case 004:
				[super recievedMessage:_message->message from:@"" time:time_ type:type];
				return;
		}
	}
	[super recievedMessage:_message from:from time:time_ type:type];
}

@end
