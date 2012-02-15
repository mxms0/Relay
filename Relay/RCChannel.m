//
//  RCChannel.m
//  Relay
//
//  Created by Max Shavrick on 1/23/12.
//

#import "RCChannel.h"
#import "RCNetwork.h"

@implementation RCChannel

@synthesize channelName, lastMessage, joinOnConnect, delegate;

- (id)init {
	if ((self = [super init])) {
		lastMessage = @"";
		users = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)dealloc {
	[channelName release];
	[lastMessage release];
	[users release];
	[super dealloc];
}

- (id)description {
	return [NSString stringWithFormat:@"[%@ %@]", [super description], channelName];
}

- (void)recievedMessage:(NSString *)message from:(NSString *)from type:(RCMessageType)type {
	NSLog(@"%@:%@", from, message);
	NSLog(@"%@:%@", [from dataUsingEncoding:NSUTF8StringEncoding], [message dataUsingEncoding:NSUTF8StringEncoding]);
	switch (type) {
		case RCMessageTypeAction:
			lastMessage = [[NSString stringWithFormat:@"\u2022 %@: %@", from, message] copy];
			break;
		case RCMessageTypeNormal:
			lastMessage = [[NSString stringWithFormat:@"%@: %@", from, message] copy];
			break;
		case RCMessageTypeNotice:
			break;
	}
	return;
}

- (void)setUserJoined:(NSString *)_joined {
	[users setObject:@"" forKey:_joined];
}
- (void)setUserLeft:(NSString *)left {
	[users removeObjectForKey:left];
}

- (void)setMode:(NSString *)modes forUser:(NSString *)user {
	
	[users setObject:[[users objectForKey:user] stringByAppendingString:modes] forKey:user];
}

- (void)setJoined:(BOOL)joind withArgument:(NSString *)arg1 {
	if (joined == joind) return;
	joined = joind;
	if (joined) {
		(void)[delegate sendMessage:[@"JOIN " stringByAppendingString:channelName]];
	}
	else {
		(void)[delegate sendMessage:[@"PART " stringByAppendingString:(arg1 ? arg1 : @"Leaving...")]];
	}
}

- (BOOL)joined {
	return joined;
}

- (void)recievedEvent:(RCEventType)type from:(NSString *)from message:(NSString *)msg {
	switch (type) {
		case RCEventTypeBan:
			// ooOoOOOooo!!!!!
			break;
		case RCEventTypeJoin:
			// haider!
			break;
		case RCEventTypeKick:
			// sux.
			break;
		case RCEventTypePart:
			// baibai || cyah.
			break;
	}
}

@end
