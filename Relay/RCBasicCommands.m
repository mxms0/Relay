//
//  RCBasicCommands.m
//  Relay
//
//  Created by Max Shavrick on 10/15/12.
//

#import "RCBasicCommands.h"

@implementation RCBasicCommands

+ (void)load {
	RCCommandEngine *e = [RCCommandEngine sharedInstance];
	[e registerSelector:@selector(handleME:net:channel:) forCommands:@"me" usingClass:self];
	[e registerSelector:@selector(handleJOIN:net:channel:) forCommands:[NSArray arrayWithObjects:@"join", @"j", nil] usingClass:self];
	[e registerSelector:@selector(handlePART:net:channel:) forCommands:[NSArray arrayWithObjects:@"part", @"p", nil] usingClass:self];
	[e registerSelector:@selector(handleNP:net:channel:) forCommands:[NSArray arrayWithObjects:@"np", @"ipod", nil] usingClass:self];
	// yes, i realize np and ipod should be two different commands. but for now, it will do.
	[e registerSelector:@selector(handlePRIVMSG:net:channel:) forCommands:[NSArray arrayWithObjects:@"pm", @"privmsg", @"query", @"msg", nil] usingClass:self];
	[e registerSelector:@selector(handleRAW:net:channel:) forCommands:[NSArray arrayWithObjects:@"raw", @"quote", nil] usingClass:self];
	[e registerSelector:@selector(handleNAMES:net:channel:) forCommands:[NSArray arrayWithObjects:@"names", @"users", nil] usingClass:self];
	[e registerSelector:@selector(_wut:net:channel:) forCommands:@"o_o" usingClass:self];
	[e registerSelector:@selector(handleREVS:net:channel:) forCommands:@"reverse" usingClass:self];
	[e registerSelector:@selector(handleTWEET:net:channel:) forCommands:@"tweet" usingClass:self];
	[e registerSelector:@selector(handleDATE:net:channel:) forCommands:@"date" usingClass:self];
	[e registerSelector:@selector(handleSLAP:net:channel:) forCommands:@"slap" usingClass:self];
	[e registerSelector:@selector(handleMYVERSION:net:channel:) forCommands:@"myversion" usingClass:self];
	[e registerSelector:@selector(handleCLEAR:net:channel:) forCommands:@"clear" usingClass:self];
	[e registerSelector:@selector(handleCLEARALL:net:) forCommands:@"clearall" usingClass:self];
	[e registerSelector:@selector(handleTOPIC:net:channel:) forCommands:@"topic" usingClass:self];
	[e registerSelector:@selector(handleBRAG:net:channel:) forCommands:@"brag" usingClass:self];
	[e registerSelector:@selector(handleMODE:net:channel:) forCommands:@"mode" usingClass:self];
	[e registerSelector:@selector(handleOP:net:channel:) forCommands:[NSArray arrayWithObjects:@"op", @"o", nil] usingClass:self];
	[e registerSelector:@selector(handleDEOP:net:channel:) forCommands:@"deop" usingClass:self];
	[e registerSelector:@selector(handleHALFOP:net:channel:) forCommands:[NSArray arrayWithObjects:@"halfop", @"h", nil] usingClass:self];
	[e registerSelector:@selector(handleDEHALFOP:net:channel:) forCommands:@"dehalfop" usingClass:self];
	[e registerSelector:@selector(handleVOICE:net:channel:) forCommands:[NSArray arrayWithObjects:@"voice", @"v", nil] usingClass:self];
	[e registerSelector:@selector(handleDEVOICE:net:channel:) forCommands:@"devoice" usingClass:self];
	[e registerSelector:@selector(handleQUIET:net:channel:) forCommands:[NSArray arrayWithObjects:@"quiet", @"q", nil] usingClass:self];
	[e registerSelector:@selector(handleUNQUIET:net:channel:) forCommands:@"unquiet" usingClass:self];
    [e registerSelector:@selector(handleAWAY:net:channel:) forCommands:@"away" usingClass:self];
	[e registerSelector:@selector(handleUPTIME:net:channel:) forCommands:@"uptime" usingClass:self];
	[e registerSelector:@selector(handleLIST) forCommands:@"list" usingClass:self];
	[e registerSelector:@selector(handleAC3XXSSWAG) forCommands:@"segfault" usingClass:self];
}

- (void)handleAC3XXSSWAG {
	UIWindow *swag = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[swag setWindowLevel:UIWindowLevelStatusBar];
	[swag setHidden:NO];
	[swag setBackgroundColor:[UIColor blackColor]];
	UIImageView *doubleSwag = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hdtoolbar420.jpeg"]];
	[doubleSwag setFrame:swag.frame];
	[swag addSubview:doubleSwag];
	[doubleSwag release]; // gotta into memories
	[self performSelector:@selector(die) withObject:nil afterDelay:4];
	// this code has officially been cleaned and approaved by Cykey(c)
	// the most significant contribution by him
	// give him a round of applause for this.
}

- (void)die {
	[NSException performSelector:@selector(james)];
}

- (void)handleLIST {
	[[RCChatController sharedController] animateChannelList];
}

- (void)handleUPTIME:(NSString *)uptim net:(RCNetwork *)net channel:(RCChannel *)chan {
	struct timeval boottime;
	int meb[2] = {CTL_KERN, KERN_BOOTTIME};
	size_t size = sizeof(boottime);
	time_t now;
	time_t uptime = -1;
	time(&now);
	if (sysctl(meb, 2, &boottime, &size, NULL, 0) != -1 && boottime.tv_sec != 0) {
		uptime = now - boottime.tv_sec;
	}
	int weeks = 0;
	int days = 0;
	int hours = 0;
	int minutes = 0;
	int seconds = 0;
	if (uptime > 604800) {
		weeks = floor(uptime/604800);
		uptime -= weeks * 604800;
	}
	if (uptime > 86400) {
		days = floor(uptime/86400);
		uptime -= days * 86400;
	}
	if (uptime > 3600) {
		hours = floor(uptime/3600);
		uptime -= hours * 3600;
	}
	if (uptime > 60) {
		minutes = floor(uptime/60);
		uptime -= minutes * 60;
	}
	seconds = (int)uptime;
	NSString *send = [NSString stringWithFormat:@"System Uptime: %d Weeks, %d Days, %d Hours, %d Minutes, %d Seconds", (int)weeks, (int)days, (int)hours, (int)minutes, (int)seconds];
	[chan recievedMessage:send from:[net useNick] type:RCMessageTypeNormal];
	[net sendMessage:[NSString stringWithFormat:@"PRIVMSG %@ :%@", chan, send]];
}

- (void)handleAWAY:(NSString *)args net:(RCNetwork *)net channel:(RCChannel *)chan {
    if (!args) {
        if ([net isAway]) {
            [net sendMessage:@"AWAY"];
        } else {
            // perhaps make this configurable in the future(?)
            [net sendMessage:@"AWAY :Be back later."];
        }
    } else {
        [net sendMessage:[NSString stringWithFormat:@"AWAY :%@", args]];
    }
}

- (void)handleUNQUIET:(NSString *)args net:(RCNetwork *)net channel:(RCChannel *)chan {
	[self handleMODE:[NSString stringWithFormat:@"-q %@", args] net:net channel:chan];
}

- (void)handleQUIET:(NSString *)args net:(RCNetwork *)net channel:(RCChannel *)chan {
	[self handleMODE:[NSString stringWithFormat:@"+q %@", args] net:net channel:chan];
}

- (void)handleDEVOICE:(NSString *)args net:(RCNetwork *)net channel:(RCChannel *)chan {
	[self handleMODE:[NSString stringWithFormat:@"-v %@", args] net:net channel:chan];
}

- (void)handleVOICE:(NSString *)args net:(RCNetwork *)net channel:(RCChannel *)chan {
	[self handleMODE:[NSString stringWithFormat:@"+v %@", args] net:net channel:chan];
}

- (void)handleDEHALFOP:(NSString *)args net:(RCNetwork *)net channel:(RCChannel *)chan {
	[self handleMODE:[NSString stringWithFormat:@"-h %@", args] net:net channel:chan];
}

- (void)handleHALFOP:(NSString *)args net:(RCNetwork *)net channel:(RCChannel *)chan {
	[self handleMODE:[NSString stringWithFormat:@"+h %@", args] net:net channel:chan];
}

- (void)handleDEOP:(NSString *)args net:(RCNetwork *)net channel:(RCChannel *)chan {
	[self handleMODE:[NSString stringWithFormat:@"-o %@", args] net:net channel:chan];
}

- (void)handleOP:(NSString *)args net:(RCNetwork *)net channel:(RCChannel *)chan {
	[self handleMODE:[NSString stringWithFormat:@"+o %@", args] net:net channel:chan];
}

- (void)handleMODE:(NSString *)args net:(RCNetwork *)net channel:(RCChannel *)chan {
	if (![args hasPrefix:@"#"]) {
		[net sendMessage:[NSString stringWithFormat:@"MODE %@ %@", chan, args]];
	}
	else {
		[net sendMessage:[NSString stringWithFormat:@"MODE %@", args]];
	}
}

- (void)handleBRAG:(NSString *)args net:(RCNetwork *)net channel:(RCChannel *)chan {
	return;
    int netCount = 0, chanCount = 0, olineCount = 0, opsCount = 0, hopsCount = 0, voiceCount = 0, powerCount = 0;
    int oppedUsers = 0, hoppedUsers = 0, voicedUsers = 0, normalUsers = 0;
    BOOL isHopped = NO;
    for (id network in [[RCNetworkManager sharedNetworkManager] networks]) {
        if ([network isConnected]) netCount++;
		for (RCChannel *chan in [network _channels]) {
			if (![chan isKindOfClass:[RCPMChannel class]] && ![chan isKindOfClass:[RCConsoleChannel class]]) {
				chanCount++;
			}
			for (int loc = 0; loc < [[chan fullUserList] count]; loc++) {
				NSString *rank = RCUserRank([[chan fullUserList] objectAtIndex:loc], net);
				if (!rank || ![rank isEqualToString:@""])
					continue;
				// this needs to be dynamic.
				// since channels could technically have 8 different user modes, etc.
				// please refer to prefix dictionary. I will rewrite this entirely later.
			}
		}
        for (id channel in [network _channels]) {
            if ([channel joined] && ![channel respondsToSelector:@selector(ipInfo)]) {
                chanCount += 1;
            }
            for (NSString *user in [channel fullUserList]) {
                if ([user hasPrefix:@"@"]) {
                    if ([user isEqualToString:[NSString stringWithFormat:@"@%@", [net useNick]]]) {
                        powerCount += (unsigned int)[[channel fullUserList] count];
                        opsCount++;
                    } else {
                        oppedUsers++;
                    }
                } else if ([user hasPrefix:@"%"]) {
                    if ([user isEqualToString:[NSString stringWithFormat:@"%%%@", [net useNick]]]) {
                        isHopped = YES;
                        hopsCount++;
                    } else {
                        hoppedUsers++;
                    }
                } else if ([user hasPrefix:@"+"]) {
                    if ([user isEqualToString:[NSString stringWithFormat:@"+%@", [net useNick]]]) {
                        voiceCount++;
                    } else {
                        voicedUsers++;
                    }
                } else {
                    normalUsers++;
                }
            }
        }
        if (isHopped) {
            powerCount += voicedUsers;
            powerCount += normalUsers;
        }
        chanCount -= 1;
        if([network isOper]) olineCount++;
    }
    NSString *message = [NSString stringWithFormat:@"I am in %d channels while connected to %d networks. I have %d o:lines, %d ops, %d halfops, and %d voices with power over %d individual users.", chanCount, netCount, olineCount, opsCount, hopsCount, voiceCount, powerCount];
    [chan recievedMessage:message from:[net useNick] type:RCMessageTypeNormal];
	[net sendMessage:[NSString stringWithFormat:@"PRIVMSG %@ :%@", chan, message]];
}

- (void)handleTOPIC:(NSString *)tp net:(RCNetwork *)net channel:(RCChannel *)chan {
	if (!tp) {
		[net sendMessage:[NSString stringWithFormat:@"TOPIC %@", chan]];
		return;
	}
	[net sendMessage:[NSString stringWithFormat:@"TOPIC %@", tp]];
}

- (void)handleCLEAR:(NSString *)cle net:(RCNetwork *)net channel:(RCChannel *)chan {
	[chan clearAllMessages];
}

- (void)handleCLEARALL:(NSString *)omg net:(RCNetwork *)net {
    for (id channel in [net _channels]) {
        [channel clearAllMessages];
    }
}

- (void)handleMYVERSION:(NSString *)vs net:(RCNetwork *)_net channel:(RCChannel *)_chan {
	NSString *vsr = @"Current Version: Relay 1.0 (Build NaNaNaNaNaNaN)";
	[_chan recievedMessage:vsr from:[_net useNick] type:RCMessageTypeNormal];
	[_net sendMessage:[NSString stringWithFormat:@"PRIVMSG %@ :%@", _chan, vsr]];
}

- (void)handleSLAP:(NSString *)slap net:(RCNetwork *)net channel:(RCChannel *)chan {
	if (!slap) slap = @"self";
	[self handleME:[NSString stringWithFormat:@"slaps %@ around a bit with a large trout", slap] net:net channel:chan];
}

- (void)handleDATE:(NSString *)dt net:(RCNetwork *)net channel:(RCChannel *)chan {
	// The date & time is currently: Sunday, February 10, 2013 6:32:47 PM
	NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
	[fmt setDateStyle:NSDateFormatterFullStyle];
	[fmt setTimeStyle:NSDateFormatterLongStyle];
	// fix time zone stufffs.
	NSString *date = [@"The date & time is currently: " stringByAppendingString:[fmt stringFromDate:[NSDate date]]];
	[net sendMessage:[NSString stringWithFormat:@"PRIVMSG %@ :%@", chan, date]];
	[chan recievedMessage:date from:[net useNick] type:RCMessageTypeNormal];
	[fmt release];
}

- (void)handleTWEET:(NSString *)tw net:(RCNetwork *)net channel:(RCChannel *)chan {
	if (NSClassFromString(@"TWTweetComposeViewController")) {
		if ([TWTweetComposeViewController canSendTweet]) {
			TWTweetComposeViewController *tw = [[TWTweetComposeViewController alloc] init];
			UIViewController *rc = [((RCAppDelegate *)[[UIApplication sharedApplication] delegate]) navigationController];
			[rc presentModalViewController:tw animated:YES];
			[tw release];
		}
		else {
			UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"Cannot Send Tweet" message:@"To allow you to tweet via relay, you must allow it in Settings -> Privacy -> Twitter" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
			[al show];
			[al release];
		}
	}
	else {
		[chan recievedMessage:@"This feature requires iOS6+" from:@"" type:RCMessageTypeError];
	}
}

- (void)_wut:(NSString *)wut net:(RCNetwork *)net channel:(RCChannel *)chan {
	NSString *str = [NSString stringWithFormat:@"PRIVMSG %@ :\u0CA0_\u0CA0", chan];
	[net sendMessage:str];
	[chan recievedMessage:@"\u0CA0_\u0CA0" from:[net useNick] type:RCMessageTypeNormal];
}

- (void)handleREVS:(NSString *)rev net:(RCNetwork *)net channel:(RCChannel *)chan {
	NSMutableString *revd = [[NSMutableString alloc] init];
	for (int i = 0; i < [rev length]; i++) {
		[revd appendString:[NSString stringWithFormat:@"%C", [rev characterAtIndex:[rev length]-(i+1)]]];
	}
	[net sendMessage:[NSString stringWithFormat:@"PRIVMSG %@ :%@", chan, revd]];
	[chan recievedMessage:revd from:[net useNick] type:RCMessageTypeNormal];
	[revd release];
}

- (void)handleNAMES:(NSString *)names net:(RCNetwork *)net channel:(RCChannel *)chan {
	if (!names) {
		NSString *req = [NSString stringWithFormat:@"NAMES %@", chan];
		[net sendMessage:req];
		[[RCChatController sharedController] closeWithDuration:0.00]; // just in case. :s
		[[RCChatController sharedController] pushUserListWithDefaultDuration];
		return;
	}
	NSArray *channels = [names componentsSeparatedByString:@" "];
	if ([channels count] <= 1)
		channels = [names componentsSeparatedByString:@","];
	NSString *base = @"NAMES ";
	NSString *first = nil;
	for (NSString *chan in channels) {
		NSString *geh = [[chan stringByReplacingOccurrencesOfString:@"," withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
		if (geh != nil && [geh length] > 1) {
			if (!first) first = geh;
			base = [base stringByAppendingFormat:@"%@,", geh];
		}
	}
	if (first) {
		[[RCChatController sharedController] selectChannel:first fromNetwork:net];
		[[RCChatController sharedController] closeWithDuration:0.0];
		[[RCChatController sharedController] pushUserListWithDefaultDuration];
	}
	if ([base hasSuffix:@","])
		base = [base substringToIndex:[base length]-1];
	[net sendMessage:base];
}

- (void)handleRAW:(NSString *)raw net:(RCNetwork *)net channel:(RCChannel *)chan {
	[net sendMessage:raw];
	// okay then.
}

- (void)handlePRIVMSG:(NSString *)msg net:(RCNetwork *)net channel:(RCChannel *)chan {
    NSString *usrchanetc = nil;
    NSString *rmsg = nil;
    NSScanner *scanr = [[NSScanner alloc] initWithString:msg];
    [scanr scanUpToString:@" " intoString:&usrchanetc];
    [scanr scanUpToString:@"" intoString:&rmsg];
    RCChannel *chan_ = [net channelWithChannelName:usrchanetc];
    if (!chan_) {
        chan_ = [net addChannel:usrchanetc join:NO];
    }
    if (!!rmsg && [net sendMessage:[NSString stringWithFormat:@"PRIVMSG %@ :%@", usrchanetc, rmsg]]) {
        [chan_ recievedMessage:rmsg from:[net useNick] type:RCMessageTypeNormal];
    }
    if (![[[[RCChatController sharedController] currentPanel] channel] isEqual:chan_]) {
        [[RCChatController sharedController] selectChannel:usrchanetc fromNetwork:net];
    }
    [scanr release];
}

- (NSString *)nowPlayingInfo {
    MPMusicPlayerController *musicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    if (!musicPlayer) return nil;
    MPMediaItem *currentItem = [musicPlayer nowPlayingItem];
    if (!currentItem || [musicPlayer playbackState] == MPMusicPlaybackStatePaused) {
        return nil;
	}
    NSString *finalStr = [NSString stringWithFormat:@"is listening to %@ by %@, from %@", ([currentItem valueForProperty:MPMediaItemPropertyTitle] ?: @"Unknown Title"), ([currentItem valueForProperty:MPMediaItemPropertyArtist] ?: @"Unknown Artist"), ([currentItem valueForProperty:MPMediaItemPropertyAlbumTitle] ?: @"Unknown Album")];
	return finalStr;
}

- (void)handleNP:(NSString *)np net:(RCNetwork *)net channel:(RCChannel *)chan {
	NSString *finalStr = @"is not currently listening to music.";
	if (![NSThread isMainThread]) {
		NSInvocation *vc = [[NSInvocation alloc] init];
		[vc setTarget:self];
		[vc setSelector:@selector(nowPlayingInfo)];
		NSString *rt = nil;
		[vc getReturnValue:&rt];
		[vc performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];
		if (rt) finalStr = rt;
		[vc release];
	}
	else {
		NSString *meh = [self nowPlayingInfo];
		if (meh) finalStr = meh;
	}
    [self handleME:finalStr net:net channel:chan];
}

- (void)handleME:(NSString *)me net:(RCNetwork *)net channel:(RCChannel *)chan {
	if (!me) return;
	NSString *msg = [NSString stringWithFormat:@"PRIVMSG %@ :%c%@ %@%c", chan, 0x01, @"ACTION", me, 0x01];
	if ([net sendMessage:msg])
		[chan recievedMessage:me from:[net useNick] type:RCMessageTypeAction];
}

- (void)handleJOIN:(NSString *)aJ net:(RCNetwork *)net channel:(RCChannel *)aChan {
	if (!aJ) return;
	NSArray *channels = [aJ componentsSeparatedByString:@" "];
	if ([channels count] <= 1)
		channels = [aJ componentsSeparatedByString:@","];
	NSString *base = @"JOIN ";
	NSString *first = nil;
	for (NSString *chan in channels) {
		NSString *geh = [[chan stringByReplacingOccurrencesOfString:@"," withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""];
		if (geh != nil && [geh length] > 1) {
			if (!first) first = geh;
			[net addChannel:geh join:NO];
			base = [base stringByAppendingFormat:@"%@,", geh];
		}
	}
	if (first) {
		[[RCChatController sharedController] selectChannel:first fromNetwork:net];
	}
	if ([base hasSuffix:@","])
		base = [base substringToIndex:[base length]-1];
	[net sendMessage:base];
}

- (void)handlePART:(NSString *)part net:(RCNetwork *)net channel:(RCChannel *)aChan {
	if (!part) {
		[aChan setJoined:NO withArgument:@"Relay 1.0"];
	}
	else {
		NSScanner *scanr = [[NSScanner alloc] initWithString:part];
		NSString *chan = nil;
		NSString *reason = nil;
		[scanr scanUpToString:@" " intoString:&chan];
		if (![chan hasPrefix:@"#"]) {
			[aChan setJoined:NO withArgument:part];
			[scanr release];
			return;
		}
		if (![chan isEqualToString:part]) {
			[scanr scanUpToString:@"" intoString:&reason];
			[aChan setJoined:NO withArgument:reason];
			[scanr release];
			return;
		}
		[scanr release];
	}
}

@end
