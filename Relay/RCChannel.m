//
//  RCChannel.m
//  Relay
//
//  Created by Max Shavrick on 1/23/12.
//

#import "RCChannel.h"
#import "RCNetwork.h"

@implementation RCChannel

@synthesize channelName, lastMessage, joinOnConnect, delegate, panel, topic, bubble;

- (id)initWithChannelName:(NSString *)_chan {
	if ((self = [super init])) {
		channelName = [_chan retain];
		lastMessage = @"";
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
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	RCMessageFlavor flavor;
	switch (type) {
		case RCMessageTypeAction:
			lastMessage = [[NSString stringWithFormat:@"\u2022 %@ %@", from, message] copy];
			flavor = RCMessageTypeAction;
			break;
		case RCMessageTypeNormal:
			lastMessage = [[NSString stringWithFormat:@"%@: %@", from, message] copy];
			flavor = RCMessageFlavorNormal;
			break;
		case RCMessageTypeNotice:
			flavor = RCMessageFlavorNotice;
			break;
	}
	[panel postMessage:lastMessage withFlavor:flavor];
	[self updateMainTableIfNeccessary];
	[p drain];
	return;
}

- (void)updateMainTableIfNeccessary {
	if (!shouldUpdate) return;
	if (![NSThread isMainThread]) {
		[self performSelectorInBackground:_cmd withObject:NULL];
		return;
	}
	return;
	shouldUpdate = NO;
	return;
//	UIViewController *controller = [(RCAppDelegate *)[[UIApplication sharedApplication] delegate] navigationController];
//	NSLog(@"Meh. %@", controller.topViewController);
	
	shouldUpdate = YES;
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
	if ([[self channelName] hasPrefix:@"#"]) {
		if (joind) {
			NSLog(@"Joining..%@", channelName);
			[delegate sendMessage:[@"JOIN " stringByAppendingString:channelName]];
		}
		else {
			NSLog(@"Parting.. %@", channelName);
			[delegate sendMessage:[@"PART " stringByAppendingString:(arg1 ? arg1 : @"Leaving...")]];
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
			NSLog(@"Hai. %@ %@ %@", command, argument1, argument2);
			[delegate sendMessage:[message substringFromIndex:1]];
		}
		else { 
			if ([delegate sendMessage:[@"PRIVMSG " stringByAppendingFormat:@"%@ :%@", channelName, message]]) {
				[self recievedMessage:message from:[delegate nick] type:RCMessageTypeNormal];
			}
		}
	}
	
}

- (void)setTopic:(NSString *)_topic fromUser:(NSString *)usr {
	topic = [_topic retain];
	if (usr) {
		[self recievedEvent:RCEventTypeTopic from:usr message:_topic];
		return;
	}
	[self.panel.tableView reloadData];
}

- (void)recievedEvent:(RCEventType)type from:(NSString *)from message:(NSString *)msg {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
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
		case RCEventTypeTopic:
			[panel postMessage:[NSString stringWithFormat:@"%@ changed the topic to %@", from, msg] withFlavor:RCMessageFlavorAction];
			break;
	}
	[pool drain];
}

@end
