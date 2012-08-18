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
#import <MediaPlayer/MediaPlayer.h>
#import "RCChatView.h"
#import "NSString+IRCStringSupport.h"

@implementation RCChannel

@synthesize channelName, joinOnConnect, panel, topic, bubble, usersPanel, password;

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
	if ([user hasPrefix:@"!"]) return @"&";
	return nil;
}

NSInteger rankToNumber(unichar rank);

BOOL RCIsRankHigher(NSString *rank, NSString *rank2) {
    return (rankToNumber([rank characterAtIndex:0]) < rankToNumber([rank2 characterAtIndex:0]));
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

NSString *RCSterilizeModes(NSString *modes) {
	return [[[modes stringByReplacingOccurrencesOfString:@"i" withString:@""] stringByReplacingOccurrencesOfString:@"w" withString:@""] stringByReplacingOccurrencesOfString:@"s" withString:@""];
}

NSInteger rankToNumber(unichar rank)
{
    switch (rank) {
        case '~':
            return 0;
            break;
        case '!':
        case '&':
            return 1;
            break;
        case '@':
            return 2;
            break;
        case '%':
            return 3;
            break;
        case '+':
            return 4;
            break;
        default:
            return 999;
            break;
    }
}

NSInteger sortRank(id u1, id u2);
NSInteger sortRank(id u1, id u2) {
    u1 = [u1 lowercaseString];
    u2 = [u2 lowercaseString];
    NSString* ra = RCUserRank(u1);
    NSString* rb = RCUserRank(u2);
    unichar r1 = [ra characterAtIndex:0];
    unichar r2 = [rb characterAtIndex:0];
    NSInteger r1n = rankToNumber(r1);
    NSInteger r2n = rankToNumber(r2);
    if (r1n < r2n)
        return NSOrderedAscending;
    else if (r1n > r2n)
        return NSOrderedDescending;
    else {
        return [[u1 substringFromIndex:[ra length]] compare:[u2 substringFromIndex:[rb length]]];
    }
}

UIImage *RCImageForRank(NSString *rank) {
	if (rank == nil || [rank isEqualToString:@""]) return [UIImage imageNamed:@"0_regulares"];
    NSLog(@"Rank r [%@]", rank);
    if ([rank isEqualToString:@"!"]) {
        rank = @"&";
    }
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
    joined = NO;
    fullUserList = [[NSMutableArray alloc] init];
    panel = [[RCChatPanel alloc] initWithStyle:UITableViewStylePlain andChannel:self];
}

- (id)initWithChannelName:(NSString *)_chan {
	if ((self = [super init])) {
        if (dispatch_get_main_queue() == dispatch_get_current_queue()) {
            [self initialize_me:_chan];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^(void){
                [self initialize_me:_chan];
            });
        }
	}
	return self;
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
		c = [[RCUserTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"0_usercell"];
	}
	if (indexPath.row == 0) {
		c.textLabel.text = @"Nickname List";
		c.imageView.image = [UIImage imageNamed:@"0_mListr"];
		c.detailTextLabel.text = [NSString stringWithFormat:@" - %d users online", [fullUserList count]];
	}
	else {
		c.detailTextLabel.text = @"";
        NSString *el = [fullUserList objectAtIndex:indexPath.row-1];
        NSString *rank = RCUserRank(el);
		c.textLabel.text = [el substringFromIndex:[rank length]];
		c.imageView.image = RCImageForRanks(rank, [delegate userModes]);
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
		if ([[[RCNavigator sharedNavigator] currentNetwork] isEqual:delegate]) {
			[[RCNavigator sharedNavigator] channelSelected:[[delegate channelWithChannelName:c.textLabel.text] bubble]];
		}
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

- (void)recievedKick:(NSString *)kick from:(NSString *)from reason:(NSString *)rsn {
	
}

- (void)recievedMessage:(NSString *)message from:(NSString *)from type:(RCMessageType)type {
#if LOGALL
	NSLog(@"%s:%d", (char *)_cmd, type);
#endif
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	message = [message stringByReplacingOccurrencesOfString:@"\t" withString:@""];
	NSString *msg = @"";
	NSString *time = @"";
	time = [[RCDateManager sharedInstance] currentDateAsString];
	if ([time hasSuffix:@" "])
		time = [time substringToIndex:time.length-1];
	switch (type) {
		case RCMessageTypeKick:
            [self setUserLeft:message];
            msg = @"== KICK == fixme";
			break;
		case RCMessageTypeBan:
            [self setUserLeft:message];
			msg = [[NSString stringWithFormat:@"%c[%@]%c %@ sets mode +b %@",RCIRCAttributeBold, time, RCIRCAttributeBold, from, message] retain];
			break;
		case RCMessageTypePart:
            [self setUserLeft:from];
			if (![message isEqualToString:@""]) {
				msg = [[NSString stringWithFormat:@"%c[%@]%c %@ left the channel. (%@)", RCIRCAttributeBold, time, RCIRCAttributeBold, from, message] retain];
			}
			else {
				msg = [[NSString stringWithFormat:@"%c[%@]%c %@ left the channel.", RCIRCAttributeBold, time, RCIRCAttributeBold, from] retain];
			}
			break;
		case RCMessageTypeJoin:
            [self setUserJoined:from];
			msg = [[NSString stringWithFormat:@"%c[%@]%c %@ joined the channel.", RCIRCAttributeBold, time, RCIRCAttributeBold, from] retain];
			break;
		case RCMessageTypeEvent:
            self.topic = @"";
			msg = [[NSString stringWithFormat:@"%c[%@]%c %@", RCIRCAttributeBold, time, RCIRCAttributeBold, message] retain];
			break;
		case RCMessageTypeTopic:
            if ([topic isEqualToString:message]) return;
            self.topic = message;
			msg = [message retain];
			break;
		case RCMessageTypeQuit:
            if ([self isUserInChannel:from]) {
                [self setUserLeft:from];
                if (![message isEqualToString:@""]) {
                    msg = [[NSString stringWithFormat:@"%c[%@]%c %@ left IRC. (%@)", RCIRCAttributeBold, time, RCIRCAttributeBold, from, message] retain];
                }
                else {
                    msg = [[NSString stringWithFormat:@"%c[%@]%c %@ left IRC.", RCIRCAttributeBold, time, RCIRCAttributeBold, from] retain];
                }
            } else {
                return;
            }
			break;
		case RCMessageTypeMode:
            msg = @"== TYPE: MODE < fixme! ==";
			break;
		case RCMessageTypeError:
            msg = @"== TYPE: ERROR < fixme! ==";
			break;
		case RCMessageTypeAction:
			msg = [[NSString stringWithFormat:@"%c[%@] \u2022 %@%c %@", RCIRCAttributeBold, time, from, RCIRCAttributeBold, message] retain];
			break;
		case RCMessageTypeNormal:
			if (![from isEqualToString:@""]) {
				msg = [[NSString stringWithFormat:@"%c[%@] %@:%c %@", RCIRCAttributeBold, time, from, RCIRCAttributeBold, message] retain];
			}
			else {
				msg = @"";
				type = RCMessageTypeNormalE;
			}
			break;
		case RCMessageTypeNotice:
			msg = [[NSString stringWithFormat:@"%c[%@] -%@-%c %@", RCIRCAttributeBold, time, from, RCIRCAttributeBold, message] retain];
			break;
		case RCMessageTypeNormalE:
			msg = [[NSString stringWithFormat:@"%c[%@]%c %@", RCIRCAttributeBold, time, RCIRCAttributeBold, message] retain];
			break;
        default:
            msg = @"unk_event";
            break;
	}
	BOOL isHighlight = NO;
	if ((type == RCMessageTypeNormal || type == RCMessageTypeAction || type == RCMessageTypeNotice) && ![from isEqualToStringNoCase:[delegate useNick]]) isHighlight = ([message rangeOfString:[delegate useNick] options:NSCaseInsensitiveSearch].location != NSNotFound);
	[panel postMessage:msg withType:type highlight:isHighlight isMine:([from isEqualToString:[delegate useNick]])];
	[self shouldPost:isHighlight withMessage:msg];
	[msg release];
	[p drain];
}

- (void)peopleParticipateInConversationsNotPartake:(id)hai wtfWasIThinking:(BOOL)thinking {
	NSLog(@"i"); // what the fuck
}

- (BOOL)isUserInChannel:(NSString*)user {
    return ([fullUserList containsObject:user] || [fullUserList containsObject:[user substringFromIndex:MIN([user length], 1)]]);
}

- (void)shouldPost:(BOOL)isHighlight withMessage:(NSString *)msg {
	BOOL iAmCurrent = NO;
	if ([[RCNavigator sharedNavigator] currentPanel]) 
		iAmCurrent = [[[[RCNavigator sharedNavigator] currentPanel] channel] isEqual:self];
	if (isHighlight) {
		if ([[RCNetworkManager sharedNetworkManager] isBG]) {
			UILocalNotification *nc = [[UILocalNotification alloc] init];
			[nc setFireDate:[NSDate date]];
			[nc setAlertBody:[msg stringByStrippingIRCMetadata]];
            [nc setSoundName:UILocalNotificationDefaultSoundName];
			[[UIApplication sharedApplication] scheduleLocalNotification:nc];
			[nc release];
		}
	}
}

- (NSString *)userWithPrefix:(NSString *)prefix pastUser:(NSString *)user {
	for (NSString *aUser in fullUserList) {
		if ([[aUser lowercaseString] hasPrefix:[prefix lowercaseString]] && ![[aUser lowercaseString] isEqualToString:[user lowercaseString]])
			return aUser;
	}
	return nil;
}

- (NSString *)nickAndRankForNick:(NSString *)nick {
    for (NSString* nickrank in fullUserList) {
        if ([nickrank hasSuffix:nick]) {
            NSInteger ln = [RCUserRank(nickrank) length];
            NSLog(@"OMG OMG OMG maybe. RL = %d [%@|%@|%@]", ln, nick, nickrank, [nickrank substringFromIndex:ln] );
            if ([[nickrank substringFromIndex:ln] isEqualToString:nick]) {
                return nickrank;
            }
        }
    }
    return nil;
}

- (void)setUserJoined:(NSString *)_joined {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(setUserJoined:) withObject:_joined waitUntilDone:YES];
        return;
    }
    @synchronized(self) {
#if LOGALL
        NSLog(@"_joined: %@", _joined);
#endif
        if (![_joined isEqualToString:@""] && ![_joined isEqualToString:@" "] && ![_joined isEqualToString:@"\r\n"] && ![self isUserInChannel:_joined] && _joined) {
            NSUInteger newIndex = [fullUserList indexOfObject:_joined inSortedRange:(NSRange){0, [fullUserList count]} options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(id obj1, id obj2) {
                return sortRank(obj1, obj2);
            }];
            [fullUserList insertObject:_joined atIndex:newIndex];
            [usersPanel insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:newIndex+1 inSection:0], nil] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }
}
- (void)setUserLeft:(NSString *)left {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(setUserLeft:) withObject:left waitUntilDone:YES];
        return;
    }
    left = [self nickAndRankForNick:left];
	@synchronized(self) {
#if LOGALL
		NSLog(@"left: %@", left);
#endif
		if (![left isEqualToString:@""] && ![left isEqualToString:@" "] && ![left isEqualToString:@"\r\n"] && [self isUserInChannel:left] && left) {
			NSInteger newIndex = [fullUserList indexOfObject:left];
			if (newIndex != NSNotFound) {
				[fullUserList removeObjectAtIndex:newIndex];
				[usersPanel deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:newIndex+1 inSection:0], nil] withRowAnimation:UITableViewRowAnimationRight];
			}
		}
	}
}

- (void)setMyselfParted {
	[fullUserList removeAllObjects];
	[self recievedMessage:@"You left the channel." from:@"" type:RCMessageTypeEvent];
	joined = NO;
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

- (void)subtractModes:(NSString *)md forUser:(NSString *)usr {
	
}

- (void)addModes:(NSString *)md forUser:(NSString *)usr {
	
}

- (void)setMode:(NSString *)modes forUser:(NSString *)user {

}

- (void)setJoined:(BOOL)joind withArgument:(NSString *)arg1 {
	if (joined == joind) {
		NSLog(@"State the same. Canceling request..");
		return;
	}
    NSLog(@"Meh %@", [self channelName]);
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
	joined = success;
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

- (void)parseAndHandleSlashCommand:(NSString *)msg {    
    if ([msg hasPrefix:@"/"]) {
		if ([delegate sendMessage:[NSString stringWithFormat:@"PRIVMSG %@ :%@", channelName, msg]])
			[self recievedMessage:msg from:[delegate useNick] type:RCMessageTypeNormal];
		return;
	}
	NSScanner *scanr = [[NSScanner alloc] initWithString:msg];
	NSString *cmd = @"";
	NSString *args = cmd;
	[scanr scanUpToString:@" " intoString:&cmd];
	[scanr scanUpToString:@"" intoString:&args];
	NSString *realCmd = [NSString stringWithFormat:@"handleSlash%@:", [cmd uppercaseString]];
    SEL _pSEL = NSSelectorFromString(realCmd);
	if ([self respondsToSelector:_pSEL]) [self performSelector:_pSEL withObject:args];
	else {
		NSLog(@"PRINT TO CONSOLE NO HANDLER");
	}
	
	[scanr release];
}

- (void)handleSlashJOIN:(NSString *)join {
    for (NSString* piece in [join componentsSeparatedByString:@","]) {
        if ([piece isEqualToString:@" "]||[piece isEqualToString:@""]||!piece)
        {
            continue;
        }
        if (!([piece hasPrefix:@"#"])||([piece hasPrefix:@"&"])) {
            piece = [@"#" stringByAppendingString:piece];
        }
        [delegate addChannel:piece join:YES];
    }
}

- (BOOL)isPrivate
{
    return NO;
}

- (void)handleSlashPRIVMSG:(NSString *)privmsg {
	NSScanner *scan = [[NSScanner alloc] initWithString:privmsg];
	NSString *room = @"";
	NSString *msg = @"";
	[scan scanUpToString:@" " intoString:&room];
	[scan scanUpToString:@"" intoString:&msg];
	BOOL new = ([(RCNetwork *)delegate channelWithChannelName:room] == nil);
	if (new) [delegate addChannel:room join:YES];
	if (![msg isEqualToString:@""] && ![msg isEqualToString:@" "] && (msg != nil)) {
		if (![delegate sendMessage:[NSString stringWithFormat:@"PRIVMSG %@ :%@", room, msg]]) {
			[scan release];
			return;
		}
		else {
			RCChannel *chan = [delegate channelWithChannelName:room];
			[chan recievedMessage:msg from:[delegate useNick] type:RCMessageTypeNormal];
		}
	}
	[scan release];
}

- (NSString *)nowPlayingInfo {
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    if (!musicPlayer) return nil;
    MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
    if (!currentItem) {
        return nil;
	}
    NSString *finalStr = [NSString stringWithFormat:@"is listening to %@ by %@, from %@", [currentItem valueForProperty:MPMediaItemPropertyTitle], [currentItem valueForProperty:MPMediaItemPropertyArtist], [currentItem valueForProperty:MPMediaItemPropertyAlbumTitle]];
	return finalStr;
}

- (void)handleSlashIPOD:(NSString *)cmd {
	NSString *finalStr = @"is not currently listening to music.";
	if (![NSThread isMainThread]) {
		NSInvocation *vc = [[NSInvocation alloc] init];
		[vc setTarget:self];
		[vc setSelector:@selector(nowPlayingInfo)];
		NSString *rt;
		[vc getReturnValue:&rt];
		[vc performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];
		if (rt) finalStr = rt;
		[vc release];
	}
	else {
		NSString *meh = [self nowPlayingInfo];
		if (meh) finalStr = meh;
	}    
    [self handleSlashME:finalStr];
}

- (void)handleSlashME:(NSString *)cmd {
	if ([cmd hasPrefix:@" "]) cmd = [cmd substringFromIndex:1];
	NSString *msg = [NSString stringWithFormat:@"PRIVMSG %@ :%c%@ %@%c", channelName, 0x01, @"ACTION", cmd, 0x01];
	[delegate sendMessage:msg];
	[self recievedMessage:cmd from:[delegate useNick] type:RCMessageTypeAction];
}

@end
