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
#import "RCScrollView.h"
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

NSString *RCSterilizeModes(NSString *modes) {
	return [[[modes stringByReplacingOccurrencesOfString:@"i" withString:@""] stringByReplacingOccurrencesOfString:@"w" withString:@""] stringByReplacingOccurrencesOfString:@"s" withString:@""];
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

- (void)initialize_me:(NSString*)chan
{
    channelName = [chan retain];
    joinOnConnect = YES;
    joined = NO;
    users = [[NSMutableDictionary alloc] init];
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
            msg = @"== KICK == fixme";
			break;
		case RCMessageTypeBan:
			msg = [[NSString stringWithFormat:@"%@ sets mode +b %@",from, message] retain];
			break;
		case RCMessageTypePart:
			if (![message isEqualToString:@""]) {
				msg = [[NSString stringWithFormat:@"%@ left the channel. (%@)", from, message] retain];
			}
			else {
				msg = [[NSString stringWithFormat:@"%@ left the channel.", from] retain];
			}
			break;
		case RCMessageTypeJoin:
			msg = [[NSString stringWithFormat:@"%@ joined the channel.", from] retain];
			break;
		case RCMessageTypeTopic:
            if ([topic isEqualToString:message]) return;
            self.topic = message;
			msg = [topic retain];
			break;
		case RCMessageTypeQuit:
            if ([self isUserInChannel:from]) {
                if (![message isEqualToString:@""]) {
                    msg = [[NSString stringWithFormat:@"%@ left IRC. (%@)", from, message] retain];
                }
                else {
                    msg = [[NSString stringWithFormat:@"%@ left IRC.", from] retain];
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
				msg = [message copy];
				type = RCMessageTypeNormalE;
			}
			break;
		case RCMessageTypeNotice:
			msg = [[NSString stringWithFormat:@"-%@- %@", from, message] retain];
			break;
		case RCMessageTypeNormalE:
            msg = @"== TYPE: EXC < fixme! ==";
			break;
        default:
            msg = @"unk_event";
            break;
	}
	BOOL isHighlight = NO;
	if (type != RCMessageTypeNormalE && type != RCMessageTypeNotice && type != RCMessageTypeTopic) isHighlight = ([message rangeOfString:[delegate useNick] options:NSCaseInsensitiveSearch].location != NSNotFound);
	[panel postMessage:msg withType:type highlight:isHighlight isMine:([from isEqualToString:[delegate useNick]])];
	[self shouldPost:isHighlight withMessage:msg];
	[msg release];
	[p drain];
}

- (void)peopleParticipateInConversationsNotPartake:(id)hai wtfWasIThinking:(BOOL)thinking {
	NSLog(@"i"); // what the fuck
}

- (BOOL)isUserInChannel:(NSString*)user
{
    return !!([users objectForKey:user]);
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

	}
}
- (void)setUserLeft:(NSString *)left {
	[users removeObjectForKey:left];
	if (usersPanel)	[usersPanel reloadData];
}

- (void)setMyselfParted {
	[users removeAllObjects];
	[self recievedMessage:@"Disconnected." from:@"" type:RCMessageTypeTopic];
	joined = NO;
}

- (void)subtractModes:(NSString *)md forUser:(NSString *)usr {
	
}

- (void)addModes:(NSString *)md forUser:(NSString *)usr {
	
}

- (void)setMode:(NSString *)modes forUser:(NSString *)user {
	// clean this up. :P
	// this is all going to the trash
	// there's absolutely no point.
	// if a user has +vao
	// only the server knows that/
	// so i will be told max has +a,
	// then he will lose +a, and it'll just say he's normal
	// so i need to refresh al users
	// so i guess i'll just re-index everytime.
	return;
	NSRange plus;
	NSRange minus;
	plus = [modes rangeOfString:@"+"];
	minus = [modes rangeOfString:@"-"];
	if (plus.location != NSNotFound && minus.location != NSNotFound) {
		// both.
	}
	else if (minus.location == NSNotFound) {
		// revert to + stuff
	}
	else {
		// only subtractions :((
	}
	// what you see above is crap. ignore it.
	modes = RCSterilizeModes(modes);
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
	if (usersPanel)	[usersPanel reloadData];
}

- (void)setJoined:(BOOL)joind withArgument:(NSString *)arg1 {
	if (joined == joind) {
		NSLog(@"State the same. Canceling request..");
		return;
	}
    NSLog(@"Meh %@", [self channelName]);
	if ([[self channelName] hasPrefix:@"#"]) {
		if (joind) {
			[delegate sendMessage:[@"JOIN " stringByAppendingString:channelName]];
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
	args = [msg substringWithRange:NSMakeRange([scanr scanLocation], msg.length-[scanr scanLocation])];
	NSString *realCmd = [NSString stringWithFormat:@"handleSlash%@:", [cmd uppercaseString]];
    SEL _pSEL = NSSelectorFromString(realCmd);
	if ([self respondsToSelector:_pSEL]) [self performSelector:_pSEL withObject:args];
	else {
		NSLog(@"PRINT TO CONSOLE NO HANDLER");
	}
	
	[scanr release];
}

- (void)handleSlashJOIN:(NSString *)join {
    [delegate addChannel:join join:YES];
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
/*
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
}*/

@end
