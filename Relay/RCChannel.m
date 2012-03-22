//
//  RCChannel.m
//  Relay
//
//  Created by Max Shavrick on 1/23/12.
//

#import "RCChannel.h"
#import "RCNetwork.h"
#import "RCNetworkManager.h"
#import "RCNavigator.h"
#import "TestFlight.h"

@implementation RCChannel

@synthesize channelName, joinOnConnect, delegate, panel, topic, bubble, usersPanel;

NSString *RCMergeModes(NSString *arg1, NSString *arg2) {
	if (arg1 == nil || arg2 == nil) return nil;
	if ([arg1 isEqualToString:@""] || [arg2 isEqualToString:@""]) return nil;
	if ([arg1 isEqualToString:arg2]) return arg1;
	NSString *final = @"";
	if (([arg1 rangeOfString:@"~"].location != NSNotFound) || ([arg2 rangeOfString:@"~"].location != NSNotFound)) {
		final = [final stringByAppendingFormat:@"~"];
	}
	if (([arg1 rangeOfString:@"&"].location != NSNotFound) || ([arg2 rangeOfString:@"&"].location != NSNotFound)) {
		final = [final stringByAppendingFormat:@"&"];
	}
	if (([arg1 rangeOfString:@"@"].location != NSNotFound) || ([arg2 rangeOfString:@"@"].location != NSNotFound)) {
		final = [final stringByAppendingString:@"@"];
	}
	if (([arg1 rangeOfString:@"%"].location != NSNotFound) || ([arg2 rangeOfString:@"%"].location != NSNotFound)) {
		final = [final stringByAppendingString:@"%"];
	}
	if (([arg1 rangeOfString:@"+"].location != NSNotFound) || ([arg2 rangeOfString:@"+"].location != NSNotFound)) {
		final = [final stringByAppendingString:@"+"];
	}
	return final;
	
}

NSString *RCUserRank(NSString *user) {
	if ([user hasPrefix:@"@"]) return @"@";
	if ([user hasPrefix:@"+"]) return @"+";
	if ([user hasPrefix:@"%"]) return @"%";
	if ([user hasPrefix:@"~"]) return @"~";
	if ([user hasPrefix:@"&"]) return @"&";
	return nil;
}

BOOL RCIsRankHigher(NSString *rank, NSString *rank2) {
	if ([rank isEqualToString:@"~"]) {
		return NO;
	}
	else if ([rank isEqualToString:@"&"]) {
		return ![rank2 isEqualToString:@"~"];
	}
	else if ([rank isEqualToString:@"@"]) {
		return !([rank2 isEqualToString:@"~"] || [rank2 isEqualToString:@"&"]);
	}
	else if ([rank isEqualToString:@"%"]) {
		return [rank2 isEqualToString:@"+"];
	}
	else if ([rank isEqualToString:@"+"]) {
		return YES;
	}
	return NO;
}

UIImage *RCImageForRanks(NSString *ranks, NSString *possible) {
	if ([ranks isEqualToString:@""] || ranks == nil) return RCImageForRank(@"");
	if (!possible) return RCImageForRank([NSString stringWithFormat:@"%C", [ranks characterAtIndex:0]]);
	for (int i = 0; i < [possible length]; i++) {
		unichar rank = [possible characterAtIndex:i];
		NSString *nRank = [NSString stringWithFormat:@"%C", rank];
		if ([ranks rangeOfString:nRank].location != NSNotFound)
			return RCImageForRank(nRank);
	}
	return nil;
}

NSString *RCSymbolRepresentationForModes(NSString *modes) {
	return [[[[[modes stringByReplacingOccurrencesOfString:@"o" withString:@"@"] stringByReplacingOccurrencesOfString:@"h" withString:@"%"] stringByReplacingOccurrencesOfString:@"v" withString:@"+"] stringByReplacingOccurrencesOfString:@"a" withString:@"&"] stringByReplacingOccurrencesOfString:@"q" withString:@"~"];
}

UIImage *RCImageForRank(NSString *rank) {
	if (rank == nil || [rank isEqualToString:@""]) return [UIImage imageNamed:@"0_regulares"];
	if ([rank isEqualToString:@"@"] 
		|| [rank isEqualToString:@"~"] 
		|| [rank isEqualToString:@"&"] 
		|| [rank isEqualToString:@"%"]
		|| [rank isEqualToString:@"+"])
		return [UIImage imageNamed:[NSString stringWithFormat:@"0_%@_user", rank]];
	return nil;
}

- (id)initWithChannelName:(NSString *)_chan {
	if ((self = [super init])) {
		channelName = [_chan retain];
		joinOnConnect = YES;
		joined = NO;
		shouldUpdate = YES;
		users = [[NSMutableDictionary alloc] init];
		panel = [[RCChatPanel alloc] initWithStyle:UITableViewStylePlain andChannel:self];
		usersPanel = [[RCUserListPanel alloc] initWithFrame:CGRectMake(0, 77, 320, 383) style:UITableViewStylePlain];
		usersPanel.delegate = self;
		usersPanel.dataSource = self;
		usersPanel.separatorStyle = UITableViewCellSelectionStyleNone;
		usersPanel.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[users allKeys] count]+1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *c = (RCUserTableCell *)[tableView dequeueReusableCellWithIdentifier:@"0_usercell"];
	if (!c) {
		c = [[RCUserTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"0_usercell"];
	}
	if (indexPath.row == 0) {
		c.textLabel.text = @"Nickname List";
		c.imageView.image = [UIImage imageNamed:@"0_mListr"];
		c.detailTextLabel.text = [NSString stringWithFormat:@" - %d users online", [[users allKeys] count]];
	}
	else {
		c.detailTextLabel.text = @"";
		c.textLabel.text = [[users allKeys] objectAtIndex:indexPath.row-1];
		c.imageView.image = RCImageForRanks([users objectForKey:[[users allKeys] objectAtIndex:indexPath.row-1]], [delegate userModes]);
	}
	return c;
	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 22.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *c = [tableView cellForRowAtIndexPath:indexPath];
	if (indexPath.row == 0) return;
	else {
		[delegate addChannel:c.textLabel.text join:NO];
	}
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
			NSLog(@"ARGS. %@ %@", from, message);
			msg = [[NSString stringWithFormat:@"-%@- %@", from, message] copy];
			break;
	}
	BOOL isHighlight = NO;
	if (flavor != RCMessageFlavorNormalE && flavor != RCMessageFlavorNotice) isHighlight =  ([message rangeOfString:[delegate useNick] options:NSCaseInsensitiveSearch].location != NSNotFound);
	[panel postMessage:msg withFlavor:flavor highlight:isHighlight isMine:([from isEqualToString:[delegate useNick]])];
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

- (NSString *)userWithPrefix:(NSString *)prefix pastUser:(NSString *)user {
	for (NSString *aUser in [users allKeys]) {
		if ([[aUser lowercaseString] hasPrefix:[prefix lowercaseString]] && ![[aUser lowercaseString] isEqualToString:[user lowercaseString]])
			return aUser;
	}
	return nil;
}

- (void)setUserJoined:(NSString *)_joined {
	if (![_joined isEqualToString:@""] && ![_joined isEqualToString:@" "] && ![_joined isEqualToString:@"\r\n"]) {
		NSString *rank = @"";
		if (RCUserRank(_joined) != nil) {
			rank = [_joined substringToIndex:1];
			_joined = [_joined substringFromIndex:1];
		}
		[users setObject:rank forKey:_joined];
		[usersPanel reloadData];
	}
}
- (void)setUserLeft:(NSString *)left {
	[users removeObjectForKey:left];
	[usersPanel reloadData];
}

- (void)setMode:(NSString *)modes forUser:(NSString *)user {
	// clean this up. :P
	if (([user rangeOfString:@"+"].location != NSNotFound) && ([user rangeOfString:@"-"].location != NSNotFound)) {
		[TestFlight submitFeedback:[NSString stringWithFormat:@"Meh. %@ %@", user, modes]];
	//	NSRange plus = [user rangeOfString:@"+"];
	//	NSRange minus = [user rangeOfString:@"-"];
	//	if (plus.location > minus.location) {
	//		// + came before minus
	//		// aka, +ao-v
	//		// if that's possible..
	//	}
	}
	// what you see above is crap. ignore it.
	if ([modes hasPrefix:@"+"]) {
		modes = [modes substringFromIndex:1];
		modes = RCSymbolRepresentationForModes(modes);
		NSString *uModes = [users objectForKey:user];
		if (uModes == nil || [uModes isEqualToString:@""]) {
			[users setObject:modes forKey:user];
		}
		else {
			uModes = RCMergeModes(uModes, modes);
			if (uModes == nil) uModes = @"";
			[users setObject:uModes forKey:user];
		}
	}
	else if ([modes hasPrefix:@"-"]) {
		NSString *uModes = [users objectForKey:user];
		modes = [modes substringFromIndex:1];
		modes = RCSymbolRepresentationForModes(modes);
		if (!(uModes == nil || [uModes isEqualToString:@""])) {
			uModes = [uModes stringByReplacingOccurrencesOfString:modes withString:@""];
		}
		[users setObject:uModes forKey:user];
	}
	[usersPanel reloadData];
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
				}
				else if ([command isEqualToStringNoCase:@"topic"]) {
					if ([message isEqualToStringNoCase:@"/topic"]) {
						[panel postMessage:topic withFlavor:RCMessageFlavorTopic highlight:NO];
						[scanner release];
						return;
					}
				}
				[scanner release];
				[delegate sendMessage:[message substringFromIndex:1]];
			}
			else {
				NSString *send = [NSString stringWithFormat:@"PRIVMSG %@ :%@", channelName, message];
				if (send.length > 510) {
					int cmd = 8;
					int cLength = channelName.length + 4;
					int max = ((510 - cmd) - cLength);
					NSMutableString *tmp = [message mutableCopy];
					while ([tmp length] > 0) {
						NSString *msg = [tmp substringWithRange:NSMakeRange(0, (tmp.length > max ? max : tmp.length))];
						[tmp deleteCharactersInRange:NSMakeRange(0, (tmp.length > max ? max : tmp.length))];
						if ([delegate sendMessage:[NSString stringWithFormat:@"PRIVMSG %@ :%@",channelName, msg]]) {
							[self recievedMessage:msg from:[delegate useNick] type:RCMessageTypeNormal];
						}
					}
					[tmp autorelease];
				}
				else {
					if ([delegate sendMessage:send])
						[self recievedMessage:message from:[delegate useNick] type:RCMessageTypeNormal];
				}
			}
		}
	}
}

- (void)recievedEvent:(RCEventType)type from:(NSString *)from message:(NSString *)msg {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	switch (type) {
		case RCEventTypeMode:
			[panel postMessage:[NSString stringWithFormat:@"%@ %@",from, msg] withFlavor:RCMessageFlavorTopic highlight:NO];
			break;
		case RCEventTypeQuit:
			if ([[users allKeys] containsObject:from]) {
				[self setUserLeft:from];
				[panel postMessage:[NSString stringWithFormat:@"%@ left IRC (%@)", from, msg] withFlavor:RCMessageFlavorPart highlight:NO];
			}
			break;
		case RCEventTypeBan:
			// ooOoOOOooo!!!!!
			break;
		case RCEventTypeJoin:
			[self setUserJoined:from];
			[panel postMessage:[NSString stringWithFormat:@"%@ joined the room", from] withFlavor:RCMessageFlavorJoin highlight:NO];
			// haider!
			break;
		case RCEventTypeKick:
			[panel postMessage:[NSString stringWithFormat:@"%@ (%@)", from, msg] withFlavor:RCMessageFlavorPart highlight:NO];
			// sux.
			break;
		case RCEventTypePart:
			[self setUserLeft:from];
			[panel postMessage:[NSString stringWithFormat:@"%@ left", from] withFlavor:RCMessageFlavorPart highlight:NO];
			// baibai || cyah.
			break;
		case RCEventTypeTopic:
			if (topic) if ([topic isEqualToString:msg]) {
				[pool drain];
				return;
			}
			if (!from || [from isEqualToString:@""]) 
				[panel postMessage:msg withFlavor:RCMessageFlavorTopic highlight:NO];
			else [panel postMessage:[NSString stringWithFormat:@"%@ changed the topic to %@", from, msg] withFlavor:RCMessageFlavorTopic highlight:NO];
			topic = [msg retain];
			break;
	}
	[pool drain];
}

@end
