//
//  RCChannel.m
//  Relay
//
//  Created by Max Shavrick on 1/23/12.
//

#import "RCChannel.h"
#import "RCNetwork.h"
#import "RCNetworkManager.h"

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
		usersPanel = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 383) style:UITableViewStylePlain];
		usersPanel.delegate = self;
		usersPanel.dataSource = self;
	}
	return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[users allKeys] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *c = [tableView dequeueReusableCellWithIdentifier:@"0_usercell"];
	if (!c) {
		c = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"0_usercell"];
	}
	c.textLabel.text = [[users allKeys] objectAtIndex:indexPath.row];
	return c;
	
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
	if (flavor != RCMessageFlavorNormalE) isHighlight =  ([message rangeOfString:[delegate useNick] options:NSCaseInsensitiveSearch].location != NSNotFound);
	[panel postMessage:msg withFlavor:flavor highlight:(isHighlight ? [delegate useNick] : nil) isMine:([from isEqualToString:[delegate useNick]])];
	[self shouldPost:isHighlight withMessage:msg];
	[msg release];
	[p drain];
	return;
}

- (void)shouldPost:(BOOL)isHighlight withMessage:(NSString *)msg {
	BOOL iAmCurrent = [[[[RCNavigator sharedNavigator] currentPanel] channel] isEqual:self];
	if (isHighlight) {
		if (!iAmCurrent) [bubble setMentioned:YES];
		if ([[RCNetworkManager sharedNetworkManager] isBG]) {
			UILocalNotification *nc = [[UILocalNotification alloc] init];
			[nc setFireDate:[NSDate date]];
			[nc setAlertBody:msg];
			[[UIApplication sharedApplication] scheduleLocalNotification:nc];
			[nc release];
		}
	}
	else {
		if (!iAmCurrent) [bubble setHasNewMessage:YES];
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
					if ([command isEqualToStringNoCase:@"query"] || [command isEqualToStringNoCase:@"msg"]) {
						command = @"privmsg";
					}
				NSLog(@"Haidata. %@ %@ %@ %@", message, command, argument1, argument2);
				}
				else if ([command isEqualToStringNoCase:@"topic"]) {
					if ([message isEqualToStringNoCase:@"/topic"]) {
						[panel postMessage:topic withFlavor:RCMessageFlavorTopic highlight:nil];
						[scanner release];
						return;
					}
				}
				[scanner release];
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
			[panel postMessage:[NSString stringWithFormat:@"%@ joined the room", from] withFlavor:RCMessageFlavorJoin highlight:nil];
			// haider!
			break;
		case RCEventTypeKick:
			// sux.
			break;
		case RCEventTypePart:
			[self setUserLeft:from];
			[panel postMessage:[NSString stringWithFormat:@"%@ left", from] withFlavor:RCMessageFlavorPart highlight:nil];
			// baibai || cyah.
			break;
		case RCEventTypeTopic:
			if (topic) if ([topic isEqualToString:msg]) return;
			if (!from || [from isEqualToString:@""]) 
				[panel postMessage:msg withFlavor:RCMessageFlavorTopic highlight:nil];
			else [panel postMessage:[NSString stringWithFormat:@"%@ changed the topic to %@", from, msg] withFlavor:RCMessageFlavorTopic highlight:nil];
			topic = [msg retain];
			break;
	}
	[pool drain];
}

@end
