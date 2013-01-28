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
}

- (void)handleDATE:(NSString *)dt net:(RCNetwork *)net channel:(RCChannel *)chan {
	
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
}

- (void)_wut:(NSString *)wut net:(RCNetwork *)net channel:(RCChannel *)chan {
	NSString *str = [NSString stringWithFormat:@"PRIVMSG %@ :\u0CA0_\u0CA0", [chan channelName]];
	[net sendMessage:str];
	[chan recievedMessage:str from:[net useNick] type:RCMessageTypeNormal];
}

- (void)handleREVS:(NSString *)rev net:(RCNetwork *)net channel:(RCChannel *)chan {
	NSMutableString *revd = [[NSMutableString alloc] init];
	for (int i = 0; i < [rev length]; i++) {
		[revd appendString:[NSString stringWithFormat:@"%C", [rev characterAtIndex:[rev length]-(i+1)]]];
	}
	[net sendMessage:[NSString stringWithFormat:@"PRIVMSG %@ :%@", [chan channelName], revd]];
	[chan recievedMessage:revd from:[net useNick] type:RCMessageTypeNormal];
	[revd release];
}

- (void)handleNAMES:(NSString *)names net:(RCNetwork *)net channel:(RCChannel *)chan {
	if (!names) {
		NSString *req = [NSString stringWithFormat:@"NAMES %@", [chan channelName]];
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
	NSString *msg = [NSString stringWithFormat:@"PRIVMSG %@ :%c%@ %@%c", [chan channelName], 0x01, @"ACTION", me, 0x01];
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
	}
}

@end
