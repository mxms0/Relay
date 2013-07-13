//
//  RCChannel.m
//  Relay
//
//  Created by Max Shavrick on 1/23/12.
//

#import "RCChannel.h"
#import "RCNetwork.h"
#import "RCNetworkManager.h"
#import "TestFlight.h"
#import "NSString+IRCStringSupport.h"
#import "RCChannelManager.h"
#import "RCChatController.h"

#define M_COLOR 32
@implementation RCChannel

@synthesize channelName, joinOnConnect, panel, topic, usersPanel, password, temporaryJoinOnConnect, fullUserList, newMessageCount, cellRepresentation;

NSString *RCUserRank(NSString *user, RCNetwork *network) {
	if (![network prefix]) {
			return @"";
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

BOOL RCIsRankHigher(NSString *rank, NSString *rank2, RCNetwork* network) {
    return (rankToNumber([rank characterAtIndex:0], network) < rankToNumber([rank2 characterAtIndex:0], network));
}

NSInteger rankToNumber(unichar rank, RCNetwork *network) {
    for (NSArray *arr in [[network prefix] allValues]) {
        if ([arr count] == 2) {
            if ([[arr objectAtIndex:1] characterAtIndex:0] == rank) {
                return [[arr objectAtIndex:0] intValue];
            }
        }
    }
    return 999;
}

NSInteger sortRank(id u1, id u2, RCNetwork* network) {
    u1 = [u1 lowercaseString];
    u2 = [u2 lowercaseString];
    NSString *ra = RCUserRank(u1, network);
    NSString *rb = RCUserRank(u2, network);
    unichar r1 = [ra characterAtIndex:0];
    unichar r2 = [rb characterAtIndex:0];
    NSInteger r1n = rankToNumber(r1, network);
    NSInteger r2n = rankToNumber(r2, network);
    if (r1n < r2n)
        return NSOrderedAscending;
    else if (r1n > r2n)
        return NSOrderedDescending;
    else {
        return [[u1 substringFromIndex:[ra length]] compare:[u2 substringFromIndex:[rb length]]];
    }
}

UIImage *RCImageForRank(NSString *rank, RCNetwork* network) {
    NSString *realRank = RCUserRank(rank, network);
    NSInteger rankPosi = rankToNumber([realRank characterAtIndex:0], network);
    switch (rankPosi) {
        case 0:
            rank = @"~";
            break;
        case 1:
            rank = @"&";
            break;
        case 2:
            rank = @"@";
            break;
        case 3:
            rank = @"%";
            break;
        case 4:
            rank = @"+";
            break;
        default:
            rank = @"";
            break;
    }
    /*
     Uses numerical value for rank positions etc. => basically, works relying on PREFIX
     */
	if (rank == nil || [rank isEqualToString:@""]) return [UIImage imageNamed:@"0_regulares"];
	if ([rank isEqualToString:@"@"] 
		|| [rank isEqualToString:@"~"] 
		|| [rank isEqualToString:@"&"] 
		|| [rank isEqualToString:@"%"]
		|| [rank isEqualToString:@"+"])
		return [UIImage imageNamed:[NSString stringWithFormat:@"0_%@_user", rank]];
	return nil;
}

- (void)initialize_me:(NSString *)chan {
    channelName = [chan retain];
    joinOnConnect = YES;
	cellRepresentation = nil;
    joined = NO;
	newMessageCount = 0;
    userRanksAdv = [NSMutableDictionary new];
    fullUserList = [[NSMutableArray alloc] init];
    panel = [[RCChatPanel alloc] initWithChannel:self];
}

- (id)initWithChannelName:(NSString *)_chan {
	if ((self = [super init])) {
		if (dispatch_get_main_queue() == dispatch_get_current_queue()) {
			[self initialize_me:_chan];
		}
		else {
			dispatch_sync(dispatch_get_main_queue(), ^(void) {
				[self initialize_me:_chan];
			});
		}
	}
	return self;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [fullUserList count]+1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *c = (RCUserTableCell *)[tableView dequeueReusableCellWithIdentifier:@"0_usercell"];
	if (!c) {
		c = [[[RCUserTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"0_usercell"] autorelease];
	}
	if (indexPath.row == 0) {
		c.textLabel.text = @"Nickname List";
		c.imageView.image = [UIImage imageNamed:@"0_mListr"];
		c.detailTextLabel.text = [NSString stringWithFormat:@" - %d users online", [fullUserList count]];
	}
	else {
		c.detailTextLabel.text = @"";
        NSString *el = [fullUserList objectAtIndex:indexPath.row-1];
        NSString *rank = RCUserRank(el, [self delegate]);
		c.textLabel.text = [el substringFromIndex:[rank length]];
		c.imageView.image = RCImageForRank(rank, delegate);
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
		//	[[RCChatController sharedController] channelSelected:[[delegate channelWithChannelName:c.textLabel.text] bubble]];
	}
}

- (void)dealloc {
    @synchronized(self) {
        [channelName release];
        [panel release];
        [userRanksAdv release];
        [super dealloc];
    }
}

- (id)description {
	return [NSString stringWithFormat:@"[%@ %@]", [super description], channelName];
}

char user_hash(NSString *from) {
    int uhash = 0;
    @synchronized([[UIApplication sharedApplication] delegate]) {
        uhash = ([from hash] % (M_COLOR-2)) + 2;
	}
	return uhash % 0xFF;
}

BOOL RCHighlightCheck(RCChannel *self, NSString **message) {
	BOOL is_highlight = NO;
	NSMutableArray *fullUserList = self->fullUserList;
	for (NSString *uname in [fullUserList sortedArrayUsingComparator:^ NSComparisonResult(id obj1, id obj2) {
		if ([obj1 length] > [obj2 length]) return NSOrderedAscending;
		else if ([obj1 length] < [obj2 length]) return NSOrderedDescending;
		return NSOrderedSame;
	}]) {
		NSString *cmp = *message;
		NSString *rank = RCUserRank(uname, [self delegate]);
		NSString *nameOrRank = [uname substringFromIndex:[rank length]];
		int hhash = ([nameOrRank isEqualToString:[[self delegate] useNick]]) ? 1 : user_hash(nameOrRank);
		
		NSString *patternuno = [NSString stringWithFormat:@"(^|\\s)([^A-Za-z0-9#]*)(\\Q%@\\E)([^A-Za-z0-9]*)($|\\s)", nameOrRank];
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:patternuno options:NSRegularExpressionCaseInsensitive error:nil];
		NSString *val = [regex stringByReplacingMatchesInString:cmp options:0 range:NSMakeRange(0, [cmp length]) withTemplate:[NSString stringWithFormat:@"$1$2%c%02d$3%c$4$5", RCIRCAttributeInternalNickname, hhash, RCIRCAttributeInternalNicknameEnd]];
		if (val) *message = val;
		NSString *patterndos = [NSString stringWithFormat:@"(^|\\s)([^A-Za-z0-9]*)(\\Q%@\\E)([^A-Za-z0-9]*)($|\\s)", nameOrRank];
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
			[self recievedMessage:[NSString stringWithFormat:@"%c\u2022 %@%c is now known as %c%@%c", RCIRCAttributeBold, old, RCIRCAttributeBold, RCIRCAttributeBold, new_, RCIRCAttributeBold] from:@"" type:RCMessageTypeNormalE];
			[self setUserJoined:[old_rank stringByAppendingString:new_]];
		}
	}
}

- (void)recievedMessage:(NSString *)message from:(NSString *)from time:(NSString *)time type:(RCMessageType)type {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	NSRange rhacksorry = [message rangeOfString:@"\x12\x13"];
	if ([message rangeOfString:@"\x12\x13"].location != NSNotFound) {
		time = [message substringWithRange:NSMakeRange(rhacksorry.location, message.length-rhacksorry.location)];
		if ([time hasSuffix:@" "]) {
			time = [time recursivelyRemoveSuffix:@" "];
		}
		message = [message substringWithRange:NSMakeRange(0, rhacksorry.location)];
	}
	if (!time) {
		time = [[RCDateManager sharedInstance] currentDateAsString];
	}
	NSString *msg = @"";
    from = [from stringByReplacingOccurrencesOfString:@"\x04" withString:@""];
    from = [from stringByReplacingOccurrencesOfString:@"\x05" withString:@""];
    char uhash = (![from isEqualToString:[delegate useNick]]) ? user_hash(from) : 1;
    if ([message isKindOfClass:[NSString class]]) {
        message = [message stringByReplacingOccurrencesOfString:@"\x04" withString:@""];
        message = [message stringByReplacingOccurrencesOfString:@"\x05" withString:@""];
    }
    BOOL isHighlight = NO;
	switch (type) {
		case RCMessageTypeKick: {
			if (![message respondsToSelector:@selector(objectAtIndex:)]) {
				NSLog(@"SENDING THE WRONG TYPE.");
				return;
			}
            NSString *mesg = [(NSArray *)message objectAtIndex:1];
            NSString *whog = [(NSArray *)message objectAtIndex:0];
            if ([mesg isKindOfClass:[NSString class]]) {
                mesg = [mesg stringByReplacingOccurrencesOfString:@"\x04" withString:@""];
                mesg = [mesg stringByReplacingOccurrencesOfString:@"\x05" withString:@""];
            }
            if ([whog isKindOfClass:[NSString class]]) {
                whog = [whog stringByReplacingOccurrencesOfString:@"\x04" withString:@""];
                whog = [whog stringByReplacingOccurrencesOfString:@"\x05" withString:@""];
            }
            [self setUserLeft:whog];
            msg = [[NSString stringWithFormat:@"%@ %c%@%c has kicked %c%@%c%@", time, RCIRCAttributeBold, from, RCIRCAttributeBold, RCIRCAttributeBold, whog, RCIRCAttributeBold, (!mesg) ? @"" : [@" (" stringByAppendingFormat:@"%@)", mesg]] retain];
		}
            break;
		case RCMessageTypeBan:
            [self setUserLeft:message];
			msg = [[NSString stringWithFormat:@"%@ %c%@%c sets mode +b %@", time, RCIRCAttributeBold, from, RCIRCAttributeBold, message] retain];
			break;
		case RCMessageTypePart:
            [self setUserLeft:from];
			if (![message isEqualToString:@""]) {
				msg = [[NSString stringWithFormat:@"%@ %c%@ %c left the channel. (%@)", time, RCIRCAttributeBold, from, RCIRCAttributeBold, message] retain];
			}
			else {
				msg = [[NSString stringWithFormat:@"%@ %c%@%c left the channel.", time, RCIRCAttributeBold, from, RCIRCAttributeBold] retain];
			}
			break;
		case RCMessageTypeJoin:
			if (![from isEqualToString:[delegate useNick]]) {
				if (holdUserListUpdates) [self setUserJoinedBatch:from cnt:0];
				else [self setUserJoined:from];
			}
			msg = [[NSString stringWithFormat:@"%@ %c%@%c joined the channel.", time, RCIRCAttributeBold, from, RCIRCAttributeBold] retain];
			break;
		case RCMessageTypeEvent:
			msg = [[NSString stringWithFormat:@"%@ %c%@%c %@", time, RCIRCAttributeBold, from, RCIRCAttributeBold, message] retain];
			break;
		case RCMessageTypeTopic:
            self.topic = message;
			if (from) msg = [[NSString stringWithFormat:@"%c%@%c changed the topic to: %@", RCIRCAttributeBold, from, RCIRCAttributeBold, message] retain];
			else msg = [message retain];
			break;
		case RCMessageTypeQuit:
            if ([self isUserInChannel:from]) {
				[self setUserLeft:from];
				if (![message isEqualToString:@""]) {
					msg = [[NSString stringWithFormat:@"%@ %c%@%c left IRC. (%@)", time, RCIRCAttributeBold, from, RCIRCAttributeBold, message] retain];
				}
				else {
					msg = [[NSString stringWithFormat:@"%@ %c%@%c left IRC.", time, RCIRCAttributeBold, from, RCIRCAttributeBold] retain];
				}
			}
			else {
				[p drain];
				return;
			}
			break;
		case RCMessageTypeMode:
			msg = [[NSString stringWithFormat:@"%@%c %@%c sets mode %c%@%c", time, RCIRCAttributeBold, from, RCIRCAttributeBold, RCIRCAttributeBold, message,RCIRCAttributeBold] retain];
			break;
		case RCMessageTypeError:
			msg = [[NSString stringWithFormat:@"%@ %@", time, message] retain];
			break;
		case RCMessageTypeAction:
			isHighlight = RCHighlightCheck(self, &message);
			msg = [[NSString stringWithFormat:@"%@%c %c%02d\u2022 %@%c%c %@", time, RCIRCAttributeBold, RCIRCAttributeInternalNickname, uhash, from, RCIRCAttributeInternalNicknameEnd, RCIRCAttributeBold, message] retain];
			break;
		case RCMessageTypeNormal:
			if (![from isEqualToString:@""]) {
				isHighlight = RCHighlightCheck(self, &message);
				msg = [[NSString stringWithFormat:@"%@ %c%c%02d%@:%c%c %@", time, RCIRCAttributeBold, RCIRCAttributeInternalNickname, uhash, from, RCIRCAttributeInternalNicknameEnd, RCIRCAttributeBold, message] retain];
			}
			else {
				msg = [@"" retain];
				type = RCMessageTypeNormalE;
			}
			break;
		case RCMessageTypeNotice:
            if ([self isUserInChannel:from]) {
				isHighlight = RCHighlightCheck(self, &message);
                msg = [[NSString stringWithFormat:@"%@ %c-%c%02d%@%c-%c %@", time, RCIRCAttributeBold, RCIRCAttributeInternalNickname, uhash, from, RCIRCAttributeInternalNicknameEnd, RCIRCAttributeBold, message] retain];
            } else {
                [[[self delegate] consoleChannel] recievedMessage:[message retain] from:from type:RCMessageTypeNotice];
				// message maybe should be retained.
                [msg release];
                [p drain];
                return;
            }
			break;
		case RCMessageTypeNormalE:
			msg = [[NSString stringWithFormat:@"%@ %@", time, message] retain];
			break;
		case RCMessageTypeNormalE2:
			msg = [[NSString stringWithFormat:@"%@ %@", time, message] retain];
			break;
        default:
            msg = @"unk_event";
            break;
	}
	[panel postMessage:msg withType:type highlight:isHighlight isMine:([from isEqualToString:[delegate useNick]])];
	if (type == RCMessageTypeNormal || type == RCMessageTypeNormalE || type == RCMessageTypeAction)
		[self shouldPost:isHighlight withMessage:msg];
	[msg release];
	[p drain];
}

- (void)recievedMessage:(NSString *)message from:(NSString *)from type:(RCMessageType)type {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	// i know one will be allocated when passing this on.
	// but there are autoreleased variables here, i don't want to leak.
	// better safe than sorry.
	NSString *time = [[RCDateManager sharedInstance] currentDateAsString];
	if ([time hasSuffix:@" "])
		time = [time substringToIndex:time.length-1];
	[self recievedMessage:message from:from time:time type:type];
	[pool drain];
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
	if (isHighlight) {
		if ([[RCNetworkManager sharedNetworkManager] isBG]) {
			UILocalNotification *nc = [[UILocalNotification alloc] init];
			[nc setFireDate:[NSDate date]];
			[nc setAlertBody:[msg stringByStrippingIRCMetadata]];
            [nc setSoundName:UILocalNotificationDefaultSoundName];
			[nc setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[delegate uUID], RCCurrentNetKey, [self channelName], RCCurrentChanKey, nil]];
			[[UIApplication sharedApplication] scheduleLocalNotification:nc];
			[nc release];
		}
	}
	if (![[[[RCChatController sharedController] currentPanel] channel] isEqual:self]) {
		newMessageCount++;
		if ([[RCChatController sharedController] isShowingChatListView]) {
			if (newMessageCount > 101) return;
			// if it's at 100, it will stop drawing anything new anyways. since the 99+ thing. so k
			[cellRepresentation setNewMessageCount:newMessageCount];
			[cellRepresentation performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
		}
	}
}

- (NSMutableArray *)usersMatchingWord:(NSString *)word {
	NSMutableArray *usrs = [[NSMutableArray alloc] init];
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
		[self setUserJoined:_joined cnt:0];
	}
}

- (void)setUserJoinedBatch:(NSString *)_joined cnt:(int)cnt {
	if (cnt > 10) {
		if (![[self delegate] prefix])
			[[self delegate] setPrefix:[NSDictionary new]];
	}
	if (![[self delegate] prefix]) {
		double delayInSeconds = 0.1;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
			[self setUserJoinedBatch:_joined cnt:cnt+1];
		});
		return;
	}
	@synchronized(fakeUserList) {
		if (![_joined isEqualToString:@""] && ![_joined isEqualToString:@" "] && ![_joined isEqualToString:@"\r\n"] && ![self isUserInChannel:_joined] && _joined) {
			NSUInteger newIndex = [fakeUserList indexOfObject:_joined inSortedRange:(NSRange){0, [fakeUserList count]} options:NSBinarySearchingInsertionIndex usingComparator:^ NSComparisonResult(id obj1, id obj2) {
					return sortRank(obj1, obj2, [self delegate]);
			}];
			[fakeUserList insertObject:_joined atIndex:newIndex];
		}
	}
}

- (void)setUserJoined:(NSString *)_joined cnt:(int)cnt_ {
	if (cnt_ > 10) {
		if (![[self delegate] prefix])
			[[self delegate] setPrefix:[NSDictionary new]];
	}
	if (![[self delegate] prefix]) {
		double delayInSeconds = 0.1;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
		dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
			[self setUserJoined:_joined cnt:cnt_+1];
		});
		return;
	}
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(setUserJoined:) withObject:_joined waitUntilDone:NO];
		return;
	}
	@synchronized(fullUserList) {
		if (![_joined isEqualToString:@""] && ![_joined isEqualToString:@" "] && ![_joined isEqualToString:@"\r\n"] && ![self isUserInChannel:_joined] && _joined) {
				[usersPanel reloadData];
				NSUInteger newIndex = [fullUserList indexOfObject:_joined inSortedRange:(NSRange){0, [fullUserList count]} options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(id obj1, id obj2) {
					return sortRank(obj1, obj2, [self delegate]);
				}];
				[fullUserList insertObject:_joined atIndex:newIndex];
				[[RCChatController sharedController] reloadUserCount];
				[usersPanel reloadData];
		}
	}
}
- (void)setUserLeft:(NSString *)left {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(setUserLeft:) withObject:left waitUntilDone:NO];
        return;
    }
    left = [self nickAndRankForNick:left];
	@synchronized(fullUserList) {
		if (![left isEqualToString:@""] && ![left isEqualToString:@" "] && ![left isEqualToString:@"\r\n"] && [self isUserInChannel:left] && left) {
			NSInteger newIndex = [fullUserList indexOfObject:left];
			if (newIndex != NSNotFound) {
				[fullUserList removeObjectAtIndex:newIndex];
				[[RCChatController sharedController] reloadUserCount];
				[usersPanel reloadData];
			}
		}
	}
}

- (void)setMyselfParted {
	[fullUserList removeAllObjects];
	[self recievedMessage:@"You left the channel." from:@"" type:RCMessageTypeEvent];
	joined = NO;
}

- (void)clearAllMessages {
	[panel stringByEvaluatingJavaScriptFromString:@"clearMessages()"];
}

- (void)disconnected:(NSString *)msg {
	[fullUserList removeAllObjects];
	if ([msg isEqualToString:@"Disconnected."]) {
		[self recievedMessage:@"Disconnected." from:@"" type:RCMessageTypeEvent];
	}
	else {
		[self recievedMessage:[@"Disconnected: " stringByAppendingString:msg] from:@"" type:RCMessageTypeEvent];
	}
	joined = NO;
}

#define NICK_NO_RANK(nick,network) [nick substringFromIndex:[RCUserRank(nick,network) length]]
#define REFRESH_TABLE \
NSString *cur_rank = @"";\
int max = 999;\
for (NSString *rank in current) {\
	int nm = rankToNumber([rank characterAtIndex:0], [self delegate]);\
	if (max > nm) {\
		max = nm;\
		cur_rank = rank;\
	}\
}\
if (![or isEqualToString:cur_rank]) { \
	[self setUserLeft:nnr];\
	[self setUserJoined:[cur_rank stringByAppendingString:nnr]];\
}

#define SET_MODE \
partialLen = [modes substringWithRange:NSMakeRange(stptr, endptr-stptr)];\
for (int a = 0; a < [partialLen length]; a++) {\
	if (adding) {\
		NSString *rankf = [[[delegate prefix] objectForKey:[partialLen substringWithRange:NSMakeRange(a, 1)]] objectAtIndex:1];\
		if (rankf) {\
			NSString *full_user = [self nickAndRankForNick:[users objectAtIndex:modecnt]]; NSString* or = RCUserRank(full_user,[self delegate]);\
			NSString *nnr = NICK_NO_RANK(full_user, [self delegate]);\
			NSArray *current = [userRanksAdv objectForKey:nnr];\
			if (!current) current = [[NSArray new] autorelease];\
			current = [current arrayByAddingObject:rankf];\
			[userRanksAdv setObject:current forKey:nnr];\
			REFRESH_TABLE;\
		}\
	}\
	else if (subtracting) {\
		NSString *rankf = [[[delegate prefix] objectForKey:[partialLen substringWithRange:NSMakeRange(a, 1)]] objectAtIndex:1];\
		if (rankf) {\
			NSString *full_user = [self nickAndRankForNick:[users objectAtIndex:modecnt]];NSString *or = RCUserRank(full_user, [self delegate]);\
			NSString *nnr = NICK_NO_RANK(full_user, [self delegate]);\
			NSMutableArray *current = [[[userRanksAdv objectForKey:nnr] mutableCopy] autorelease];\
			[current removeObject:rankf];\
			if (current) [userRanksAdv setObject:[[current copy] autorelease] forKey:nnr];\
			REFRESH_TABLE;\
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
						SET_MODE;;
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
	if (joined == joind) {
		NSLog(@"State the same. Canceling request..");
		return;
	}
	if (!joind) joined = joind;
	else [self setJoined:joind withArgument:@""];
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
			[delegate sendMessage:[NSString stringWithFormat:@"PART %@ %@", channelName, (arg1 ? arg1 : @"Leaving...")]];
		}
	}
}

- (void)setSuccessfullyJoined:(BOOL)success {
	@synchronized(self) {
		joined = success;
		dispatch_async(dispatch_get_main_queue(), ^(void) {
			[self recievedMessage:nil from:[delegate useNick] type:RCMessageTypeJoin];
		});
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
					int cLength = channelName.length + 4;
					int max = ((510 - cmd) - cLength);
					NSMutableString *tmp = [message mutableCopy];
					while ([tmp length] > 0) {
						NSString *msg = [tmp substringWithRange:NSMakeRange(0, (tmp.length > max ? max : tmp.length))];
						if ([tmp respondsToSelector:@selector(deleteCharactersInRange:)])
							[tmp deleteCharactersInRange:NSMakeRange(0, (tmp.length > max ? max : tmp.length))];
						else {
							tmp = [tmp mutableCopy];
							// fuck me.
							continue;
						}
						if ([delegate sendMessage:[NSString stringWithFormat:@"PRIVMSG %@ :%@", channelName, msg]]) {
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

- (void)parseAndHandleSlashCommand:(NSString *)msg {    
    if ([msg hasPrefix:@"/"]) {
		if ([delegate sendMessage:[NSString stringWithFormat:@"PRIVMSG %@ :%@", channelName, msg]])
			[self recievedMessage:msg from:[delegate useNick] type:RCMessageTypeNormal];
		return;
	}
	[[RCCommandEngine sharedInstance] handleCommand:msg fromNetwork:[self delegate] forChannel:self];
}

- (BOOL)isPrivate {
    return NO;
}

@end
