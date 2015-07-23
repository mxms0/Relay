//
//  RCChannel.m
//  Relay
//
//  Created by Max Shavrick on 1/23/12.
//

#import "RCChannel.h"
#import "RCNetwork.h"
#import "NSString+IRCStringSupport.h"

#define M_COLOR 20
@implementation RCChannel

@synthesize channelName, joinOnConnect, panel, usersPanel, password, temporaryJoinOnConnect, fullUserList, newMessageCount, cellRepresentation, hasHighlights, pool;

NSString *RCUserRank(NSString *user, RCNetwork *network) {
	if (![network prefix]) {
		return nil;
	}
	for (id karr in [[network prefix] allKeys]) {
		NSArray *arr = [[network prefix] objectForKey:karr];
		if ([arr count] == 2) {
			if ([[arr objectAtIndex:1] characterAtIndex:0] == [user characterAtIndex:0]) {
				return [arr objectAtIndex:1];
			}
		}
	}
	return nil;
}

int RCUserIntegerRank(NSString *prefix, RCNetwork *network) {
	if (![network prefix]) {
		return -1;
	}
	for (int i = 0; i < [[[network prefix] allKeys] count]; i++) {
		NSArray *ary = [[network prefix] objectForKey:[[[network prefix] allKeys] objectAtIndex:i]];
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
		NSInteger nm = RCRankToNumber([rank characterAtIndex:0], [self delegate]);
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
	for (NSArray *arr in [[network prefix] allValues]) {
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

- (void)initialize_me:(NSString *)chan {
	channelName = [chan retain];
	joinOnConnect = YES;
	cellRepresentation = nil;
	joined = NO;
	newMessageCount = 0;
	userRanksAdv = [NSMutableDictionary new];
	fullUserList = [[NSMutableArray alloc] init];
	pool = [[NSMutableArray alloc] init];
}

- (id)initWithChannelName:(NSString *)_chan {
	if ((self = [super init])) {
		// i don't feel too comfortable about all of this.
		if (![NSThread isMainThread]) {
			[self performSelectorOnMainThread:@selector(initialize_me:) withObject:_chan waitUntilDone:NO];
		//	NSLog(@"ERRROR CALLING FROM NOT MAIN THREAD");
		}
		else {
			[self initialize_me:_chan];
		}
		// this is awfully dangerous.
		/*
		 dispatch_sync(dispatch_get_main_queue(), ^(void) {
				[self initialize_me:_chan];
		 });
		 */
	}
	return self;
}

- (void)storePassword {
	if (!password || [password isEqualToString:@""]) return;
//	RCKeychainItem *item = [RCKeychainItem sharedKeychain];
//	[item setObject:password forKey:[NSString stringWithFormat:@"%@%@rpass", [delegate uUID], channelName]];
}

- (void)retrievePassword {
	if (![delegate uUID]) return;
//	RCKeychainItem *item = [RCKeychainItem sharedKeychain];
//	[self setPassword:[item objectForKey:[NSString stringWithFormat:@"%@%@rpass", [delegate uUID], channelName]]];
}

- (void)setShouldHoldUserListUpdates:(BOOL)hld {
	if (holdUserListUpdates == hld) return;
	holdUserListUpdates = hld;
	if (hld) {
		fakeUserList = [[NSMutableArray alloc] init];
	}
	else {
		[fullUserList addObjectsFromArray:fakeUserList];
		[fakeUserList release];
		fakeUserList = nil;
		dispatch_async(dispatch_get_main_queue(), ^{
			[usersPanel reloadData];
		});
	}
}

- (RCNetwork *)delegate {
	return delegate;
}

- (void)setDelegate:(RCNetwork *)_delegate {
	delegate = _delegate;
}

- (void)dealloc {
	@synchronized(self) {
		[self setChannelName:nil];
		[self setPassword:nil];
		[userRanksAdv release];
		[fakeUserList release];
		[fullUserList release];
		[channelName release];
		[panel release];
		[super dealloc];
	}
}

- (id)description {
	return channelName;
}

- (id)debugDescription {
	return [NSString stringWithFormat:@"<%@ %@>", [super description], channelName];
}

char RCUserHash(NSString *from) {
	int uhash = 0;
	@synchronized([[UIApplication sharedApplication] delegate]) {
		uhash = ([from hash] % (M_COLOR-2)) + 2;
	}
	return uhash % 0xFF;
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
		NSString *rank = RCUserRank(uname, [self delegate]);
		NSString *nameOrRank = [uname substringFromIndex:[rank length]];
		int hhash = ([nameOrRank isEqualToString:[[self delegate] useNick]]) ? 1 : RCUserHash(nameOrRank);
		
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
		NSString *old_rank = RCUserRank(full_old, [self delegate]);
		if (old && full_old) {
			if (!old_rank) old_rank = @"";
			[self setUserLeft:old];
			[self recievedMessage:[NSString stringWithFormat:@"%c\u2022 %@%c is now known as %c%@%c", RCIRCAttributeBold, old, RCIRCAttributeBold, RCIRCAttributeBold, new_, RCIRCAttributeBold] from:@"" time:nil type:RCMessageTypeNormalE2];
			[self setUserJoinedForFixingPurposesOnly:[old_rank stringByAppendingString:new_] cnt:0];
		}
	}
}

- (void)recievedMessage:(id)_message from:(NSString *)from time:(NSString *)time_ type:(RCMessageType)type {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
//	NSString *time = nil;
	NSString *message = nil;
	if ([_message isKindOfClass:[RCMessage class]]) {
//		time = ([[_message tags] objectForKey:@"time"] ?: [[RCDateManager sharedInstance] currentDateAsString]);
		message = [_message parameterAtIndex:1];
	}
	else {
		message = (NSString *)_message;
	}
	if (!time_) {
//		time = [[RCDateManager sharedInstance] currentDateAsString];
	}
	NSString *msg = @"";
	char uhash = ([from isEqualToString:[delegate useNick]]) ? 1 : RCUserHash(from);
	BOOL isHighlight = NO;
	switch (type) {
		case RCMessageTypeKick: {
			NSArray *components = (NSArray *)_message;
			NSString *kickReason = [components objectAtIndex:1];
			if (![kickReason isEqualToString:@""])
				kickReason = [NSString stringWithFormat:@" (%@)", kickReason];
			msg = [NSString stringWithFormat:@"%c%@%c has kicked %c%@%c%@", RCIRCAttributeBold, from, RCIRCAttributeBold, RCIRCAttributeBold, [components objectAtIndex:0], RCIRCAttributeBold, kickReason];
			from = @"";
			dispatch_sync(dispatch_get_main_queue(), ^ {
				[fullUserList removeAllObjects];
			});
			break;
		}
		case RCMessageTypeBan:
			msg = [NSString stringWithFormat:@"%c%@%c sets mode %c+b %@%c", RCIRCAttributeBold, from, RCIRCAttributeBold, RCIRCAttributeBold, message, RCIRCAttributeBold];
			break;
		case RCMessageTypePart:
			if (![self isUserInChannel:from]) {
				[p release];
				return;
			}
			if (![message isEqualToString:@""] && !!(msg)) {
				msg = [NSString stringWithFormat:@"%c%@%c left the channel. (%@)", RCIRCAttributeBold, from, RCIRCAttributeBold, message];
			}
			else {
				msg = [NSString stringWithFormat:@"%c%@%c left the channel.", RCIRCAttributeBold, from, RCIRCAttributeBold];
			}
			from = @"";
			break;
		case RCMessageTypeJoin:
			msg = [NSString stringWithFormat:@"%c%@%c joined the channel.", RCIRCAttributeBold, from, RCIRCAttributeBold];
			from = @"";
			break;
		case RCMessageTypeEvent:
			msg = [NSString stringWithFormat:@"%@%@", from, message];
			break;
		case RCMessageTypeTopic:
			if (from) msg = [[NSString stringWithFormat:@"%@ changed the topic to: %@", from, message] retain];
			else msg = [message copy];
			break;
		case RCMessageTypeQuit:
			if ([self isUserInChannel:from]) {
				[self setUserLeft:from];
				if (![message isEqualToString:@""]) {
					msg = [NSString stringWithFormat:@"%c%@%c left IRC. (%@)", RCIRCAttributeBold, from, RCIRCAttributeBold, message];
				}
				else {
					msg = [NSString stringWithFormat:@"%c%@%c left IRC.", RCIRCAttributeBold, from, RCIRCAttributeBold];
				}
				from = @"";
			}
			else {
				[p drain];
				return;
			}
			break;
		case RCMessageTypeMode:
			msg = [NSString stringWithFormat:@"%@ sets mode %c%@%c", from, RCIRCAttributeBold, message, RCIRCAttributeBold];
			break;
		case RCMessageTypeError:
			msg = message;
			break;
		case RCMessageTypeAction:
			isHighlight = [self performHighlightCheck:&message];
			msg = [NSString stringWithFormat:@"%c%02d\u2022 %@%c %@", RCIRCAttributeInternalNickname, uhash, from, RCIRCAttributeInternalNickname, message];
			from = @"";
			break;
		case RCMessageTypeNormal:
			if (from) {
				isHighlight = [self performHighlightCheck:&message];
				msg = [NSString stringWithFormat:@"%@", message];
			}
			else {
				type = RCMessageTypeNormalE;
			}
			break;
		case RCMessageTypeNotice:
			isHighlight = [self performHighlightCheck:&message];
			msg = [NSString stringWithFormat:@"-%c%02d%@%c-%@", RCIRCAttributeInternalNickname, uhash, from, RCIRCAttributeInternalNickname, message];
			from = @"";
			break;
		case RCMessageTypeNormalE:
			msg = message;
			break;
		case RCMessageTypeNormalE2:
			msg = message;
			break;
		default:
			msg = @"unk_event";
			break;
	}
	RCMessageConstruct *construct = [[RCMessageConstruct alloc] initWithMessage:msg];
	[construct setSender:from];
	[construct setColor:uhash];
	[construct formatWithHighlight:isHighlight];
	[pool addObject:construct];
	[construct release];
	
	if (type == RCMessageTypeNormal || type == RCMessageTypeNormalE || type == RCMessageTypeAction)
		[self shouldPost:isHighlight withMessage:[NSString stringWithFormat:@"%@: %@", from, [msg stringByStrippingIRCMetadata]]];
	[p drain];
}

- (BOOL)isUserInChannel:(NSString *)user {
	if (!user || [user isEqualToString:@""]) return NO;
	NSString *rnka = RCUserRank(user, [self delegate]);
	user = [user substringFromIndex:[rnka length]];
	@synchronized(fullUserList) {
		for (NSString *nickn in fullUserList) {
			NSString *rnk = RCUserRank(nickn, [self delegate]);
			NSString *rln = [nickn substringFromIndex:[rnk length]];
			if ([rln isEqualToString:user]) {
				return YES;
			}
		}
	}
	return NO;
}

- (void)shouldPost:(BOOL)isHighlight withMessage:(NSString *)msg {
//	if (isHighlight) {
//		if ([[RCNetworkManager sharedNetworkManager] isBG]) {
//			UILocalNotification *nc = [[UILocalNotification alloc] init];
//			[nc setFireDate:[NSDate date]];
//			[nc setAlertBody:[msg stringByStrippingIRCMetadata]];
//			[nc setSoundName:UILocalNotificationDefaultSoundName];
//			[nc setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[delegate uUID], RCCurrentNetKey, [self channelName], RCCurrentChanKey, nil]];
//			[[UIApplication sharedApplication] scheduleLocalNotification:nc];
//			[nc release];
//		}
//	}
//	if (![[[RCChatController sharedController] currentChannel] isEqual:self]) {
//		if (isHighlight) hasHighlights = YES;
//		newMessageCount++;
//		if ([[RCChatController sharedController] isShowingChatListView]) {
//			if (newMessageCount > 100) return;
//			// if it's at 100, it will stop drawing anything new anyways. since the 99+ thing. so k
//			[cellRepresentation setNewMessageCount:newMessageCount];
//			[cellRepresentation setHasHighlights:hasHighlights];
//			[cellRepresentation performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
//		}
//	}
}

- (NSMutableArray *)usersMatchingWord:(NSString *)word {
	NSMutableArray *usrs = [[NSMutableArray alloc] initWithCapacity:8]; // yea 8's great
	[fullUserList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSInteger ln = [RCUserRank(obj, [self delegate]) length];
		NSString *obj_ = [obj substringFromIndex:ln];
		if ([obj_ hasPrefixNoCase:word])
			[usrs addObject:obj_];
	}];
	return [usrs autorelease];
}

- (NSString *)nickAndRankForNick:(NSString *)nick {
	for (NSString *nickrank in fullUserList) {
		if (nick && [nickrank hasSuffix:nick]) {
			NSInteger ln = [RCUserRank(nickrank, [self delegate]) length];
			if ([[nickrank substringFromIndex:ln] isEqualToString:nick]) {
				return nickrank;
			}
		}
	}
	return nick;
}

- (void)setUserJoined:(NSString *)_joined {
	if (_joined && ![_joined isEqualToString:@""]) {
		if (holdUserListUpdates) [self setUserJoinedBatch:_joined cnt:0];
		else [self setUserJoined:_joined cnt:0];
	}
}

- (void)setUserJoinedBatch:(NSString *)_joined cnt:(int)cnt {
	if (cnt > 10) {
		if (![delegate prefix])
			[delegate setPrefix:[[NSDictionary new] autorelease]];
	}
	if (![delegate prefix]) {
		double delayInSeconds = 0.1;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^ {
			[self setUserJoinedBatch:_joined cnt:(cnt + 1)];
		});
		return;
	}
	@synchronized(fakeUserList) {
		if (_joined && ![_joined isEqualToString:@""] && ![self isUserInChannel:_joined]) {
			NSUInteger newIndex = [fakeUserList indexOfObject:_joined inSortedRange:(NSRange){0, [fakeUserList count]} options:NSBinarySearchingInsertionIndex usingComparator:^ NSComparisonResult(id obj1, id obj2) {
					return RCRankSort(obj1, obj2, [self delegate]);
			}];
			[fakeUserList insertObject:_joined atIndex:newIndex];
		}
	}
}

- (void)setUserJoinedForFixingPurposesOnly:(NSString *)_joined cnt:(int)cnt_ {
	if (cnt_ > 10) {
		if (![delegate prefix])
			[delegate setPrefix:[[NSDictionary new] autorelease]];
	}
	if (![delegate prefix]) {
		double delayInSeconds = 0.1;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^ {
			[self setUserJoinedForFixingPurposesOnly:_joined cnt:cnt_+1];
		});
		return;
	}
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(setUserJoinedForFixingPurposesOnly:cnt:) withObject:_joined waitUntilDone:NO];
		return;
	}
	@synchronized(fullUserList) {
		if (_joined && ![_joined isEqualToString:@""] && ![self isUserInChannel:_joined]) {
			[usersPanel reloadData];
			NSUInteger newIndex = [fullUserList indexOfObject:_joined inSortedRange:(NSRange){0, [fullUserList count]} options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(id obj1, id obj2) {
				return RCRankSort(obj1, obj2, [self delegate]);
			}];
			[fullUserList insertObject:_joined atIndex:newIndex];
	//		[[RCChatController sharedController] reloadUserCount];
			[usersPanel reloadData];
		}
	}
}

- (void)setUserJoined:(NSString *)_joined cnt:(int)cnt_ {
	if (cnt_ > 10) {
		if (![delegate prefix])
			[delegate setPrefix:[[NSDictionary new] autorelease]];
	}
	if (![delegate prefix]) {
		double delayInSeconds = 0.1;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^ {
			[self setUserJoined:_joined cnt:cnt_+1];
		});
		return;
	}
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(setUserJoined:) withObject:_joined waitUntilDone:NO];
		return;
	}
	@synchronized(fullUserList) {
		if (_joined && ![_joined isEqualToString:@""] && ![self isUserInChannel:_joined]) {
			[usersPanel reloadData];
			NSUInteger newIndex = [fullUserList indexOfObject:_joined inSortedRange:(NSRange){0, [fullUserList count]} options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(id obj1, id obj2) {
				return RCRankSort(obj1, obj2, [self delegate]);
			}];
			[fullUserList insertObject:_joined atIndex:newIndex];
		//	[[RCChatController sharedController] reloadUserCount];
			[usersPanel reloadData];
			[self recievedMessage:nil from:_joined time:nil type:RCMessageTypeJoin];
		}
	}
}

- (void)kickUserAtIndex:(int)index {
	  [delegate sendMessage:[NSString stringWithFormat:@"KICK %@ %@", channelName, RCNickWithoutRank([fullUserList objectAtIndex:index], delegate)]];
}

- (void)banUserAtIndex:(int)index {
	[delegate sendMessage:[NSString stringWithFormat:@"MODE %@ +b %@", channelName, RCNickWithoutRank([fullUserList objectAtIndex:index], delegate)]];
}

- (void)setUserLeft:(NSString *)left {
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(setUserLeft:) withObject:left waitUntilDone:NO];
		return;
	}
	left = [self nickAndRankForNick:left];
	@synchronized(fullUserList) {
		if (left && ![left isEqualToString:@""]) {
			NSInteger newIndex = [fullUserList indexOfObject:left];
			if (newIndex != NSNotFound) {
				[fullUserList removeObjectAtIndex:newIndex];
			//	[[RCChatController sharedController] reloadUserCount];
				[usersPanel reloadData];
			}
		}
	}
}

- (void)setMyselfParted {
	[fullUserList removeAllObjects];
	[self recievedMessage:@"You left the channel." from:@"" time:nil type:RCMessageTypeEvent];
	joined = NO;
}

- (void)clearAllMessages {
	dispatch_async(dispatch_get_main_queue(), ^ {
		[pool removeAllObjects];
		[panel reloadData];
	});
}

- (void)disconnected:(NSString *)msg {
	[fullUserList removeAllObjects];
	if ([msg isEqualToString:@"Disconnected."]) {
		[self recievedMessage:@"Disconnected." from:@"" time:nil type:RCMessageTypeEvent];
	}
	else {
		[self recievedMessage:[@"Disconnected: " stringByAppendingString:msg] from:@"" time:nil type:RCMessageTypeEvent];
	}
	joined = NO;
}

#define SET_MODE \
partialLen = [modes substringWithRange:NSMakeRange(stptr, endptr-stptr)];\
for (int a = 0; a < [partialLen length]; a++) {\
	if (adding) {\
		NSString *rankf = [[[delegate prefix] objectForKey:[partialLen substringWithRange:NSMakeRange(a, 1)]] objectAtIndex:1];\
		if (rankf) {\
			NSString *full_user = [self nickAndRankForNick:[users objectAtIndex:modecnt]]; NSString* or = RCUserRank(full_user,[self delegate]);\
			NSString *nnr = RCNickWithoutRank(full_user, [self delegate]);\
			NSArray *current = [userRanksAdv objectForKey:nnr];\
			if (!current) current = [[NSArray new] autorelease];\
			current = [current arrayByAddingObject:rankf];\
			[userRanksAdv setObject:current forKey:nnr];\
			RCRefreshTable(or, nnr, current, self);\
		}\
	}\
	else if (subtracting) {\
		NSString *rankf = [[[delegate prefix] objectForKey:[partialLen substringWithRange:NSMakeRange(a, 1)]] objectAtIndex:1];\
		if (rankf) {\
			NSString *full_user = [self nickAndRankForNick:[users objectAtIndex:modecnt]];\
			NSString *or = RCUserRank(full_user, [self delegate]);\
			NSString *nnr = RCNickWithoutRank(full_user, [self delegate]);\
			NSMutableArray *current = [[[userRanksAdv objectForKey:nnr] mutableCopy] autorelease];\
			[current removeObject:rankf];\
			if (current) [userRanksAdv setObject:[[current copy] autorelease] forKey:nnr];\
			RCRefreshTable(or, nnr, current, self);\
		}\
	}\
	modecnt++;\
}\
// i promise i'll get rid of this one day.

- (void)setMode:(NSString *)modes forUser:(NSString *)user {
	@synchronized(userRanksAdv) {
		@try {
			NSArray *users = [user componentsSeparatedByString:@" "];
			BOOL adding = NO;
			BOOL subtracting = NO;
			int stptr = 0;
			int endptr = 0;
			int modecnt = 0;
			NSString *partialLen = nil;
			for (int i = 0; i < [modes length]; i++) {
				switch ([modes characterAtIndex:i]) {
					case '+':
						SET_MODE;
						adding = YES;
						subtracting = NO;
						stptr = i + 1;
						endptr = stptr;
						break;
					case '-':
						SET_MODE;
						adding = NO;
						subtracting = YES;
						stptr = i + 1;
						endptr = stptr;
						break;
					default:
						endptr++;
						break;
				}
			}
			SET_MODE;
		}
		@catch (NSException *exception) {
			NSLog(@"exc %@", exception);
		}
	}
}

- (void)setJoined:(BOOL)joind {
	[self setJoined:joind withArgument:@""];
}

- (void)setJoined:(BOOL)joind withArgument:(NSString *)arg1 {
	if (joined == joind) {
		NSLog(@"State the same. Canceling request..");
		return;
	}
	if ([[self channelName] hasPrefix:@"#"]) {
		if (joind) {
			if ([[self password] length] > 0) {
				[delegate sendMessage:[NSString stringWithFormat:@"JOIN %@ %@", channelName, password]];
			}
			else [delegate sendMessage:[@"JOIN " stringByAppendingString:channelName]];
		}
		else {
			[delegate sendMessage:[NSString stringWithFormat:@"PART %@ :%@", channelName, (arg1 ?: @"Leaving...")]];
		}
	}
	joined = joind;
	// this is fine and dandy, however i should unset it on the case that the actual
	// channel join fails.
}

- (void)setSuccessfullyJoined:(BOOL)success {
	@synchronized(self) {
		if (success) {
			[self recievedMessage:nil from:[delegate useNick] time:nil type:RCMessageTypeJoin];
		}
		joined = success;
	}
}

- (BOOL)isEqual:(id)obj {
	if (![NSStringFromClass([self class]) isEqualToString:NSStringFromClass([obj class])]) {
		return NO;
	}
	if (![[delegate uUID] isEqualToString:[[obj delegate] uUID]]) {
		return NO;
	}
	if ([channelName isEqualToString:[obj channelName]]) {
		return YES;
	}
	return NO;
}

- (BOOL)joined {
	return joined;
}

- (void)userWouldLikeToPartakeInThisConversation:(NSString *)message {
	@autoreleasepool {
		if (message) {
			if ([message hasPrefix:@"/"]) {
				[self parseAndHandleSlashCommand:[message substringFromIndex:1]];
				return;
			}
			else {
				NSString *send = [NSString stringWithFormat:@"PRIVMSG %@ :%@", channelName, message];
				if (send.length > 510) {
					int cmd = 8;
					int cLength = (int)channelName.length + 4;
					int max = ((510 - cmd) - cLength);
					NSMutableString *tmp = [message mutableCopy];
					while ([tmp length] > 0) {
						NSString *msg = [tmp substringWithRange:NSMakeRange(0, (tmp.length > max ? max : tmp.length))];
						if ([tmp respondsToSelector:@selector(deleteCharactersInRange:)])
							[tmp deleteCharactersInRange:NSMakeRange(0, (tmp.length > max ? max : tmp.length))];
						else {
							tmp = [tmp mutableCopy];
							// This is silly. Please fix.
							continue;
						}
						if ([delegate sendMessage:[NSString stringWithFormat:@"PRIVMSG %@ :%@", channelName, msg]]) {
							[self recievedMessage:msg from:[delegate useNick] time:nil type:RCMessageTypeNormal];
						}
					}
					[tmp autorelease];
				}
				else {
					if ([delegate sendMessage:send])
						[self recievedMessage:message from:[delegate useNick] time:nil type:RCMessageTypeNormal];
				}
			}
		}
	}
}

- (void)parseAndHandleSlashCommand:(NSString *)msg {	
//	if ([msg hasPrefix:@"/"]) {
//		if ([delegate sendMessage:[NSString stringWithFormat:@"PRIVMSG %@ :%@", channelName, msg]])
//			[self recievedMessage:msg from:[delegate useNick] time:nil type:RCMessageTypeNormal];
//		return;
//	}
//	[[RCCommandEngine sharedInstance] handleCommand:msg fromNetwork:[self delegate] forChannel:self];
}

- (BOOL)isPrivate {
	return NO;
}

@end
