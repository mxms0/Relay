//
//  RCChannel.m
//  Relay
//
//  Created by Max Shavrick on 1/23/12.
//

#import "RCChannel.h"
#import "RCNetwork.h"

@implementation RCChannel

@synthesize channelName, joinOnConnect, delegate, panel, topic, bubble, usersPanel;

- (id)initWithChannelName:(NSString *)_chan {
	if ((self = [super init])) {
		channelName = [_chan retain];
		joinOnConnect = YES;
		joined = NO;
		shouldUpdate = YES;
		users = [[NSMutableDictionary alloc] init];
		panel = [[RCChatPanel alloc] initWithStyle:UITableViewStylePlain andChannel:self];
	}
	return self;
}

- (void)dealloc {
	[channelName release];
	[users release];
	[panel release];
	[super dealloc];
}

- (id)description {
	return [NSString stringWithFormat:@"[%@ %@]", [super description], channelName];
}

- (void)recievedMessage:(NSString *)message from:(NSString *)from type:(RCMessageType)type {

	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	message = [message stringByReplacingOccurrencesOfString:@"\t" withString:@""];
	RCMessageFlavor flavor;
	NSString *msg = @"";
	switch (type) {
		case RCMessageTypeAction:
			msg = [[NSString stringWithFormat:@"\u2022 %@ %@", from, message] copy];
			flavor = RCMessageTypeAction;
			break;
		case RCMessageTypeNormal:
			if (![from isEqualToString:@""]) {
				msg = [[NSString stringWithFormat:@"%@: %@", from, message] copy];
				flavor = RCMessageFlavorNormal;
			}
			else {
				msg = [message copy];
				flavor = RCMessageFlavorNormalE;
			}
			break;
		case RCMessageTypeNotice:
			flavor = RCMessageFlavorNotice;
			break;
	}
	BOOL isHighlight = NO;
	if (flavor != RCMessageFlavorNormalE) isHighlight =  ([message rangeOfString:[delegate useNick]].location != NSNotFound);
	[panel postMessage:msg withFlavor:flavor isHighlight:isHighlight isMine:([from isEqualToString:[delegate useNick]])];
	[self shouldPost:isHighlight];
	[msg release];
	[p drain];
	return;
}

- (void)shouldPost:(BOOL)isHighlight {
	if (![[[[RCNavigator sharedNavigator] currentPanel] channel] isEqual:self]) {
		if (isHighlight) {
			[bubble setMentioned:YES];
			return;
		}
		else {
			[bubble setHasNewMessage:YES];
		}
	}
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
	if (joined == joind) {
		NSLog(@"State the same. Canceling request..");
		return;
	}
	if ([[self channelName] hasPrefix:@"#"]) {
		if (joind) {
			NSLog(@"Joining..%@", channelName);
			[delegate sendMessage:[@"JOIN " stringByAppendingString:channelName]];
		}
		else {
			NSLog(@"Parting.. %@", channelName);
			[delegate sendMessage:[NSString stringWithFormat:@"PART %@ %@", channelName, (arg1 ? arg1 : @"Leaving...")]];
		}
	}
}

- (void)setSuccessfullyJoined:(BOOL)success {
	joined = success;
}

- (BOOL)joined {
	return joined;
}

- (void)userWouldLikeToPartakeInThisConversation:(NSString *)message {
	@autoreleasepool {
		if (message) {
			if ([message hasPrefix:@"/"]) {
				NSString *_tmp = [message substringFromIndex:1];
				NSScanner *scanner = [[NSScanner alloc] initWithString:_tmp];
				NSString *command = @"_";
				NSString *argument1 = command;
				NSString *argument2 = argument1;
				[scanner scanUpToString:@" " intoString:&command];
				[scanner scanUpToString:@" " intoString:&argument1];
				argument2 = [_tmp substringFromIndex:[scanner scanLocation]];
				if ([command isEqualToStringNoCase:@"privmsg"] || [command isEqualToStringNoCase:@"query"] || [command isEqualToStringNoCase:@"msg"]) {
					[delegate addChannel:argument1 join:YES];
				}
				if ([command isEqualToStringNoCase:@"topic"]) {
					if ([message isEqualToStringNoCase:@"/topic"]) {
						[panel postMessage:topic withFlavor:RCMessageFlavorTopic isHighlight:NO];
						return;
					}
				}
				[delegate sendMessage:[message substringFromIndex:1]];
			}
			else { 
				if ([delegate sendMessage:[@"PRIVMSG " stringByAppendingFormat:@"%@ :%@", channelName, message]]) {
					[self recievedMessage:message from:[delegate useNick] type:RCMessageTypeNormal];
				}
			}
		}
	}
}


- (void)recievedEvent:(RCEventType)type from:(NSString *)from message:(NSString *)msg {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	switch (type) {
		case RCEventTypeBan:
			// ooOoOOOooo!!!!!
			break;
		case RCEventTypeJoin:
			[self setUserJoined:from];
			[panel postMessage:[NSString stringWithFormat:@"%@ joined the room", from] withFlavor:RCMessageFlavorJoin isHighlight:NO];
			// haider!
			break;
		case RCEventTypeKick:
			// sux.
			break;
		case RCEventTypePart:
			[self setUserLeft:from];
			[panel postMessage:[NSString stringWithFormat:@"%@ left", from] withFlavor:RCMessageFlavorPart isHighlight:NO];
			// baibai || cyah.
			break;
		case RCEventTypeTopic:
			if (topic) if ([topic isEqualToString:msg]) return;
			if (!from || [from isEqualToString:@""]) 
				[panel postMessage:msg withFlavor:RCMessageFlavorTopic isHighlight:NO];
			else [panel postMessage:[NSString stringWithFormat:@"%@ changed the topic to %@", from, msg] withFlavor:RCMessageFlavorTopic isHighlight:NO];
			topic = [msg retain];
			break;
	}
	[pool drain];
}

@end
