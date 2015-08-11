//
//  RCConsoleChannel.m
//  Relay
//
//  Created by Max Shavrick on 3/2/12.
//

#import "RCConsoleChannel.h"
#import "RCNetwork.h"
#import "RCI.h"

@implementation RCConsoleChannel

- (id)initWithChannelName:(NSString *)_name {
	if ((self = [super initWithChannelName:_name])) {
		self.joined = YES;
	}
	return self;
}

- (BOOL)joined {
	return YES;
}

- (void)setSuccessfullyJoined:(BOOL)success {}

- (void)join {}

- (void)part {}

- (void)partWithMessage:(NSString *)message {}

//- (void)userWouldLikeToPartakeInThisConversation:(NSString *)message {
//	@autoreleasepool {
//		if ([message hasPrefix:@"/"]) {
//			[self parseAndHandleSlashCommand:[message substringFromIndex:1]];
//			return;
//		}
//		else {
//			[(RCNetwork *)delegate sendMessage:message];
//			[self recievedMessage:message from:@"" time:nil type:RCMessageTypeNormalEx];
//		}
//	}
//}

//- (void)receivedMessage:(RCMessage *)_message from:(NSString *)from time:(NSString *)time_ type:(RCMessageType)type {
//	if ([_message respondsToSelector:@selector(numeric)]) {
//		int numeric = [[_message numeric] intValue];
//		switch (numeric) {
//			case 004:
//				[super receivedMessage:_message.message from:@"" time:time_ type:type];
//				return;
//		}
//	}
//	[super receivedMessage:_message from:from time:time_ type:type];
//}

@end
