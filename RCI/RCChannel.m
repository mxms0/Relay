//
//  RCChannel.m
//  Relay
//
//  Created by Max Shavrick on 1/23/12.
//

#import "RCChannel.h"
#import "RCNetwork.h"

#define M_COLOR 20
@implementation RCChannel

@synthesize channelName=_channelName, joined=_joined, fullUserList, network=_network;

NSString *RCUserRank(NSString *user, RCNetwork *network) {
	if (![network prefixes]) {
		return nil;
	}
	for (id karr in [[network prefixes] allKeys]) {
		NSArray *arr = [[network prefixes] objectForKey:karr];
		if ([arr count] == 2) {
			if ([[arr objectAtIndex:1] characterAtIndex:0] == [user characterAtIndex:0]) {
				return [arr objectAtIndex:1];
			}
		}
	}
	return nil;
}

NSInteger RCUserIntegerRank(NSString *prefix, RCNetwork *network) {
	if (![network prefixes]) {
		return -1;
	}
	for (int i = 0; i < [[[network prefixes] allKeys] count]; i++) {
		NSArray *ary = [[network prefixes] objectForKey:[[[network prefixes] allKeys] objectAtIndex:i]];
		if ([ary count] == 2) {
			if ([[ary objectAtIndex:1] characterAtIndex:0] == [prefix characterAtIndex:0]) {
				return i;
			}
		}
	}
	return -1;
}

BOOL RCIsRankHigher(NSString *rank, NSString *rank2, RCNetwork* network) {
	return (RCRankToNumber([rank characterAtIndex:0], network) < RCRankToNumber([rank2 characterAtIndex:0], network));
}

NSString *RCNickWithoutRank(NSString *nick, RCNetwork *self) {
	return [nick substringFromIndex:[RCUserRank(nick, self) length]];
}

void RCRefreshTable(NSString *ord, NSString *nnr, NSArray *current, RCChannel *self) {
	NSString *currentRank = @"";
	NSInteger max = 999;
	for (NSString *rank in current) {
		NSInteger nm = RCRankToNumber([rank characterAtIndex:0], [self network]);
		if (max > nm) {
			max = nm;
			currentRank = rank;
		}
	}
	if (![ord isEqualToString:currentRank]) {
		[self setUserLeft:nnr];
		[self setUserJoinedForFixingPurposesOnly:[currentRank stringByAppendingString:nnr] cnt:0];
	}
}

NSInteger RCRankToNumber(unichar rank, RCNetwork *network) {
	for (NSArray *arr in [[network prefixes] allValues]) {
		if ([arr count] == 2) {
			if ([[arr objectAtIndex:1] characterAtIndex:0] == rank) {
				return [[arr objectAtIndex:0] intValue];
			}
		}
	}
	return 999;
}

NSInteger RCRankSort(id u1, id u2, RCNetwork *network) {
	u1 = [u1 lowercaseString];
	u2 = [u2 lowercaseString];
	NSString *ra = RCUserRank(u1, network);
	NSString *rb = RCUserRank(u2, network);
	unichar r1 = [ra characterAtIndex:0];
	unichar r2 = [rb characterAtIndex:0];
	NSInteger r1n = RCRankToNumber(r1, network);
	NSInteger r2n = RCRankToNumber(r2, network);
	if (r1n < r2n)
		return NSOrderedAscending;
	else if (r1n > r2n)
		return NSOrderedDescending;
	else {
		return [[u1 substringFromIndex:[ra length]] compare:[u2 substringFromIndex:[rb length]]];
	}
}

char RCUserHash(NSString *from) {
	int uhash = 0;
	@synchronized([[UIApplication sharedApplication] delegate]) {
		uhash = ([from hash] % (M_COLOR-2)) + 2;
	}
	return uhash % 0xFF;
}

- (id)initWithChannelName:(NSString *)_chan {
	if ((self = [super init])) {
		self.channelName = _chan;
		userRanksAdv = [[NSMutableDictionary alloc] init];
		fullUserList = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)setShouldHoldUserListUpdates:(BOOL)hld {
//	if (holdUserListUpdates == hld) return;
//	holdUserListUpdates = hld;
//	if (hld) {
//		fakeUserList = [[NSMutableArray alloc] init];
//	}
//	else {
//		[fullUserList addObjectsFromArray:fakeUserList];
//		[fakeUserList release];
//		fakeUserList = nil;
//		dispatch_async(dispatch_get_main_queue(), ^{
//			[usersPanel reloadData];
//		});
//	}
}

- (void)dealloc {
	self.channelName = nil;
	[self setPassword:nil];
	[userRanksAdv release];
	[fakeUserList release];
	[fullUserList release];
	[super dealloc];
}

- (id)description {
	return [NSString stringWithFormat:@"<%@ %@>", [super description], self.channelName];
}

- (BOOL)performHighlightCheck:(NSString **)message {
	BOOL is_highlight = NO;
	for (NSString *uname in [fullUserList sortedArrayUsingComparator:^ NSComparisonResult(id obj1, id obj2) {
		if ([obj1 length] > [obj2 length]) return NSOrderedAscending;
		else if ([obj1 length] < [obj2 length]) return NSOrderedDescending;
		return NSOrderedSame;
	}]) {
		NSString *cmp = *message;
		if (!cmp) return NO;
		NSString *rank = RCUserRank(uname, [self network]);
		NSString *nameOrRank = [uname substringFromIndex:[rank length]];
		int hhash = ([nameOrRank isEqualToString:[[self network] nickname]]) ? 1 : RCUserHash(nameOrRank);
		
		NSString *patternuno = [NSString stringWithFormat:@"(^|\\s)([^A-Za-z0-9#]*)(\\Q%@\\E)([^A-Za-z0-9]*)($|\\s)", nameOrRank];
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patternuno options:NSRegularExpressionCaseInsensitive error:nil];
		NSString *val = [regex stringByReplacingMatchesInString:cmp options:0 range:NSMakeRange(0, [cmp length]) withTemplate:[NSString stringWithFormat:@"$1$2%c%02d$3%c$4$5", RCIRCAttributeInternalNickname, hhash, RCIRCAttributeInternalNickname]];
		if (val) *message = val;
		NSString *patterndos = [NSString stringWithFormat:@"(^|\\s)([^A-Za-z0-9#]*)(\\Q%@\\E)([^A-Za-z0-9]*)($|\\s)", nameOrRank];
		if ([[NSRegularExpression regularExpressionWithPattern:patterndos options:NSRegularExpressionCaseInsensitive error:nil] numberOfMatchesInString:cmp options:0 range:NSMakeRange(0, [cmp length])]) {
			is_highlight = (hhash == 1) ? 1 : is_highlight;
		}
	}
	return is_highlight;
}

- (void)changeNick:(NSString *)old toNick:(NSString *)new_ {
	if (new_) {
		NSString *full_old = [self nickAndRankForNick:old];
		NSString *old_rank = RCUserRank(full_old, [self network]);
		if (old && full_old) {
			if (!old_rank) old_rank = @"";
			[self setUserLeft:old];
			[self receivedMessage:[NSString stringWithFormat:@"%c\u2022 %@%c is now known as %c%@%c", RCIRCAttributeBold, old, RCIRCAttributeBold, RCIRCAttributeBold, new_, RCIRCAttributeBold] from:@"" time:nil type:RCMessageTypeNormal];
			[self setUserJoinedForFixingPurposesOnly:[old_rank stringByAppendingString:new_] cnt:0];
		}
	}
}

- (void)receivedMessage:(RCMessage *)message {
	// forwarding this up isn't terrible
	// may need exceptions here in the future to stop etc
	[self.network.channelDelegate channel:self receivedMessage:message];
}

- (void)receivedMessage:(RCMessage *)_message from:(NSString *)from time:(NSString *)time_ type:(RCMessageType)type {
	[self.network.channelDelegate channel:self receivedMessage:_message];
}

- (BOOL)isUserInChannel:(NSString *)user {
	if (!user || [user isEqualToString:@""]) return NO;
	NSString *rnka = RCUserRank(user, [self network]);
	user = [user substringFromIndex:[rnka length]];
	@synchronized(fullUserList) {
		for (NSString *nickn in fullUserList) {
			NSString *rnk = RCUserRank(nickn, [self network]);
			NSString *rln = [nickn substringFromIndex:[rnk length]];
			if ([rln isEqualToString:user]) {
				return YES;
			}
		}
	}
	return NO;
}

- (NSMutableArray *)usersMatchingWord:(NSString *)word {
	NSMutableArray *usrs = [[NSMutableArray alloc] initWithCapacity:8]; // yea 8's great
	[fullUserList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSInteger ln = [RCUserRank(obj, [self network]) length];
		NSString *obj_ = [obj substringFromIndex:ln];
		if ([obj_ hasPrefixNoCase:word])
			[usrs addObject:obj_];
	}];
	return [usrs autorelease];
}

- (NSString *)nickAndRankForNick:(NSString *)nick {
	for (NSString *nickrank in fullUserList) {
		if (nick && [nickrank hasSuffix:nick]) {
			NSInteger ln = [RCUserRank(nickrank, [self network]) length];
			if ([[nickrank substringFromIndex:ln] isEqualToString:nick]) {
				return nickrank;
			}
		}
	}
	return nick;
}

- (void)setUserJoined:(NSString *)user {
	//	if (user && ![user isEqualToString:@""]) {
	//		if (holdUserListUpdates) [self setUserJoinedBatch:user cnt:0];
	//		else [self setUserJoined:user cnt:0];
	//	}
}
//
- (void)setUserJoinedBatch:(NSString *)user cnt:(int)cnt {
	//	if (cnt > 10) {
	//		if (![delegate prefixes])
	//			[delegate setPrefixes:[[NSDictionary new] autorelease]];
	//	}
	//	if (![delegate prefixes]) {
	//		double delayInSeconds = 0.1;
	//		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	//		dispatch_after(popTime, dispatch_get_main_queue(), ^ {
	//			[self setUserJoinedBatch:user cnt:(cnt + 1)];
	//		});
	//		return;
	//	}
	//	@synchronized(fakeUserList) {
	//		if (user && ![user isEqualToString:@""] && ![self isUserInChannel:user]) {
	//			NSUInteger newIndex = [fakeUserList indexOfObject:user inSortedRange:(NSRange){0, [fakeUserList count]} options:NSBinarySearchingInsertionIndex usingComparator:^ NSComparisonResult(id obj1, id obj2) {
	//					return RCRankSort(obj1, obj2, [self delegate]);
	//			}];
	//			[fakeUserList insertObject:user atIndex:newIndex];
	//		}
	//	}
}
//
- (void)setUserJoinedForFixingPurposesOnly:(NSString *)user cnt:(int)cnt_ {
	//	if (cnt_ > 10) {
	//		if (![delegate prefixes])
	//			[delegate setPrefixes:[[NSDictionary new] autorelease]];
	//	}
	//	if (![delegate prefixes]) {
	//		double delayInSeconds = 0.1;
	//		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	//		dispatch_after(popTime, dispatch_get_main_queue(), ^ {
	//			[self setUserJoinedForFixingPurposesOnly:user cnt:cnt_+1];
	//		});
	//		return;
	//	}
	//	if (![NSThread isMainThread]) {
	//		[self performSelectorOnMainThread:@selector(setUserJoinedForFixingPurposesOnly:cnt:) withObject:user waitUntilDone:NO];
	//		return;
	//	}
	//	@synchronized(fullUserList) {
	//		if (user && ![user isEqualToString:@""] && ![self isUserInChannel:user]) {
	//			[usersPanel reloadData];
	//			NSUInteger newIndex = [fullUserList indexOfObject:user inSortedRange:(NSRange){0, [fullUserList count]} options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(id obj1, id obj2) {
	//				return RCRankSort(obj1, obj2, [self delegate]);
	//			}];
	//			[fullUserList insertObject:user atIndex:newIndex];
	//	//		[[RCChatController sharedController] reloadUserCount];
	//			[usersPanel reloadData];
	//		}
	//	}
}
//
- (void)setUserJoined:(NSString *)user cnt:(int)cnt_ {
	//	if (cnt_ > 10) {
	//		if (![delegate prefixes])
	//			[delegate setPrefixes:[[NSDictionary new] autorelease]];
	//	}
	//	if (![delegate prefixes]) {
	//		double delayInSeconds = 0.1;
	//		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	//		dispatch_after(popTime, dispatch_get_main_queue(), ^ {
	//			[self setUserJoined:user cnt:cnt_+1];
	//		});
	//		return;
	//	}
	//	if (![NSThread isMainThread]) {
	//		[self performSelectorOnMainThread:@selector(setUserJoined:) withObject:user waitUntilDone:NO];
	//		return;
	//	}
	//	@synchronized(fullUserList) {
	//		if (user && ![user isEqualToString:@""] && ![self isUserInChannel:user]) {
	//			[usersPanel reloadData];
	//			NSUInteger newIndex = [fullUserList indexOfObject:user inSortedRange:(NSRange){0, [fullUserList count]} options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(id obj1, id obj2) {
	//				return RCRankSort(obj1, obj2, [self delegate]);
	//			}];
	//			[fullUserList insertObject:user atIndex:newIndex];
	//		//	[[RCChatController sharedController] reloadUserCount];
	//			[usersPanel reloadData];
	//			[self receivedMessage:nil from:user time:nil type:RCMessageTypeJoin];
	//		}
	//	}
}

- (void)kickUserAtIndex:(int)index {
	[self.network sendMessage:[NSString stringWithFormat:@"KICK %@ %@", self.channelName, RCNickWithoutRank([fullUserList objectAtIndex:index], self.network)]];
}

- (void)banUserAtIndex:(int)index {
	[self.network sendMessage:[NSString stringWithFormat:@"MODE %@ +b %@", self.channelName, RCNickWithoutRank([fullUserList objectAtIndex:index], self.network)]];
}

- (void)setUserLeft:(NSString *)left {
//	if (![NSThread isMainThread]) {
//		[self performSelectorOnMainThread:@selector(setUserLeft:) withObject:left waitUntilDone:NO];
//		return;
//	}
//	left = [self nickAndRankForNick:left];
//	@synchronized(fullUserList) {
//		if (left && ![left isEqualToString:@""]) {
//			NSInteger newIndex = [fullUserList indexOfObject:left];
//			if (newIndex != NSNotFound) {
//				[fullUserList removeObjectAtIndex:newIndex];
//				//	[[RCChatController sharedController] reloadUserCount];
//				[usersPanel reloadData];
//			}
//		}
//	}
}

- (void)disconnected:(NSString *)msg {
	[fullUserList removeAllObjects];
	if ([msg isEqualToString:@"Disconnected."]) {
		[self receivedMessage:@"Disconnected." from:@"" time:nil type:RCMessageTypeEvent];
	}
	else {
		[self receivedMessage:[@"Disconnected: " stringByAppendingString:msg] from:@"" time:nil type:RCMessageTypeEvent];
	}
	self.joined = NO;
}

//#define SET_MODE \
//partialLen = [modes substringWithRange:NSMakeRange(stptr, endptr-stptr)];\
//for (int a = 0; a < [partialLen length]; a++) {\
//	if (adding) {\
//		NSString *rankf = [[[delegate prefixes] objectForKey:[partialLen substringWithRange:NSMakeRange(a, 1)]] objectAtIndex:1];\
//		if (rankf) {\
//			NSString *full_user = [self nickAndRankForNick:[users objectAtIndex:modecnt]]; NSString* or = RCUserRank(full_user,[self delegate]);\
//			NSString *nnr = RCNickWithoutRank(full_user, [self delegate]);\
//			NSArray *current = [userRanksAdv objectForKey:nnr];\
//			if (!current) current = [[NSArray new] autorelease];\
//			current = [current arrayByAddingObject:rankf];\
//			[userRanksAdv setObject:current forKey:nnr];\
//			RCRefreshTable(or, nnr, current, self);\
//		}\
//	}\
//	else if (subtracting) {\
//		NSString *rankf = [[[delegate prefixes] objectForKey:[partialLen substringWithRange:NSMakeRange(a, 1)]] objectAtIndex:1];\
//		if (rankf) {\
//			NSString *full_user = [self nickAndRankForNick:[users objectAtIndex:modecnt]];\
//			NSString *or = RCUserRank(full_user, [self delegate]);\
//			NSString *nnr = RCNickWithoutRank(full_user, [self delegate]);\
//			NSMutableArray *current = [[[userRanksAdv objectForKey:nnr] mutableCopy] autorelease];\
//			[current removeObject:rankf];\
//			if (current) [userRanksAdv setObject:[[current copy] autorelease] forKey:nnr];\
//			RCRefreshTable(or, nnr, current, self);\
//		}\
//	}\
//	modecnt++;\
//}\
//// i promise i'll get rid of this one day.
//
//- (void)setMode:(NSString *)modes forUser:(NSString *)user {
//	@synchronized(userRanksAdv) {
//		@try {
//			NSArray *users = [user componentsSeparatedByString:@" "];
//			BOOL adding = NO;
//			BOOL subtracting = NO;
//			int stptr = 0;
//			int endptr = 0;
//			int modecnt = 0;
//			NSString *partialLen = nil;
//			for (int i = 0; i < [modes length]; i++) {
//				switch ([modes characterAtIndex:i]) {
//					case '+':
//						SET_MODE;
//						adding = YES;
//						subtracting = NO;
//						stptr = i + 1;
//						endptr = stptr;
//						break;
//					case '-':
//						SET_MODE;
//						adding = NO;
//						subtracting = YES;
//						stptr = i + 1;
//						endptr = stptr;
//						break;
//					default:
//						endptr++;
//						break;
//				}
//			}
//			SET_MODE;
//		}
//		@catch (NSException *exception) {
//			NSLog(@"exc %@", exception);
//		}
//	}
//}

- (void)join {
	if ([self joined]) return;
//	if ([[self password] length] > 0) {
//		[self.network sendMessage:[NSString stringWithFormat:@"JOIN %@ %@", self.channelName, password]];
//	}
//	else
		[self.network sendMessage:[@"JOIN " stringByAppendingString:self.channelName]];
}

- (void)part {
	[self partWithMessage:@"Leaving..."];
}

- (void)partWithMessage:(NSString *)message {
	[fullUserList removeAllObjects];
//	[self receivedMessage:@"You left the channel." from:@"" time:nil type:RCMessageTypeEvent];
	self.joined = NO;
	[self.network sendMessage:[NSString stringWithFormat:@"PART %@ :%@", self.channelName, message]];
}

- (void)setSuccessfullyJoined:(BOOL)success {
	@synchronized(self) {
		if (success) {
			[self receivedMessage:nil from:[self.network nickname] time:nil type:RCMessageTypeJoin];
		}
		self.joined = success;
	}
}

- (BOOL)isEqual:(id)obj {
	if ([obj isKindOfClass:[RCChannel class]]) {
		return ([self.channelName isEqual:[obj channelName]] && [[self network] isEqual:[obj delegate]]);
	}
	return NO;
}

//- (void)userWouldLikeToPartakeInThisConversation:(NSString *)message {
//	@autoreleasepool {
//		if (message) {
//			if ([message hasPrefix:@"/"]) {
//				[self parseAndHandleSlashCommand:[message substringFromIndex:1]];
//				return;
//			}
//			else {
//				NSString *send = [NSString stringWithFormat:@"PRIVMSG %@ :%@", channelName, message];
//				if (send.length > 510) {
//					int cmd = 8;
//					int cLength = (int)channelName.length + 4;
//					int max = ((510 - cmd) - cLength);
//					NSMutableString *tmp = [message mutableCopy];
//					while ([tmp length] > 0) {
//						NSString *msg = [tmp substringWithRange:NSMakeRange(0, (tmp.length > max ? max : tmp.length))];
//						if ([tmp respondsToSelector:@selector(deleteCharactersInRange:)])
//							[tmp deleteCharactersInRange:NSMakeRange(0, (tmp.length > max ? max : tmp.length))];
//						else {
//							tmp = [tmp mutableCopy];
//							// This is silly. Please fix.
//							continue;
//						}
//						if ([delegate sendMessage:[NSString stringWithFormat:@"PRIVMSG %@ :%@", channelName, msg]]) {
//							[self recievedMessage:msg from:[delegate nickname] time:nil type:RCMessageTypeNormal];
//						}
//					}
//					[tmp autorelease];
//				}
//				else {
//					if ([delegate sendMessage:send])
//						[self recievedMessage:message from:[delegate nickname] time:nil type:RCMessageTypeNormal];
//				}
//			}
//		}
//	}
//}
//
//- (void)parseAndHandleSlashCommand:(NSString *)msg {
//	if ([msg hasPrefix:@"/"]) {
//		if ([delegate sendMessage:[NSString stringWithFormat:@"PRIVMSG %@ :%@", channelName, msg]])
//			[self recievedMessage:msg from:[delegate nickname] time:nil type:RCMessageTypeNormal];
//		return;
//	}
//	[[RCCommandEngine sharedInstance] handleCommand:msg fromNetwork:[self delegate] forChannel:self];
//}

- (BOOL)isPrivate {
	return NO;
}

@end
