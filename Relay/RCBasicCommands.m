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
	[e registerSelector:@selector(handlePRIVMSG:net:channel:) forCommands:[NSArray arrayWithObjects:@"pm", @"privmsg", @"query", nil] usingClass:self];
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
    [self handleME:finalStr net:net channel:chan];
}

- (void)handleME:(NSString *)me net:(RCNetwork *)net channel:(RCChannel *)chan {
	if (!me) return;
	NSString *msg = [NSString stringWithFormat:@"PRIVMSG %@ :%c%@ %@%c", [chan channelName], 0x01, @"ACTION", me, 0x01];
	if ([net sendMessage:msg])
		[chan recievedMessage:me from:[net useNick] type:RCMessageTypeAction];
}

- (void)handleJOIN:(NSString *)aJ net:(RCNetwork *)net channel:(RCChannel *)aChan {
	/*
	 
	 for (NSString *piece in [join componentsSeparatedByString:@","]) {
	 if ([piece isEqualToString:@" "]||[piece isEqualToString:@""] || !piece) {
	 continue;
	 }
	 if (!([piece hasPrefix:@"#"]) || ([piece hasPrefix:@"&"])) {
	 piece = [@"#" stringByAppendingString:piece];
	 }
	 id ch = [delegate addChannel:piece join:YES];
	 [[RCNavigator sharedNavigator] channelSelected:[ch bubble]];
	 [[RCNavigator sharedNavigator] scrollToBubble:[ch bubble]];
	 }
	 
	 */
	
	if (!aJ) return;
	NSArray *channels = [aJ componentsSeparatedByString:@" "];
	for (NSString *chan in channels) {
		NSString *geh = [[chan stringByReplacingOccurrencesOfString:@"," withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@" "];
		if (geh != nil && [geh length] > 1) {
			[net sendMessage:[NSString stringWithFormat:@"JOIN %@", geh]];
		}
	}
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
