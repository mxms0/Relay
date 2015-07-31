//
//  RCPMChannel.m
//  Relay
//
//  Created by Max Shavrick on 3/24/12.
//

#import "RCPMChannel.h"
#import "RCNetwork.h"

@implementation RCPMChannel
@synthesize ipInfo, chanInfos, thirstyForWhois, hasWhois, connectionInfo;

- (id)initWithChannelName:(NSString *)_name {
	if ((self = [super initWithChannelName:_name])) {
		partnerIsOnline = NO;
		ipInfo = nil;
		chanInfos = nil;
	}
	return self;
}

- (void)initialize_me:(NSString *)chan {
	channelName = [chan retain];
	joinOnConnect = YES;
	cellRepresentation = nil;
	joined = NO;
	newMessageCount = 0;
	userRanksAdv = [NSMutableDictionary new];
	fullUserList = [[NSMutableArray alloc] init];
	[fullUserList addObject:chan];
}

- (void)storePassword {
}

- (void)retrievePassword {
}

- (void)changeNick:(NSString *)old toNick:(NSString *)new_ {
	dispatch_async(dispatch_get_main_queue(), ^ {
		@synchronized(self) {
			if ([old isEqualToString:[self channelName]]) {
				if ([(RCNetwork *)[self delegate] channelWithChannelName: new_]) {
					id nself = [[self delegate] channelWithChannelName: new_];
					[self recievedMessage:[NSString stringWithFormat:@"%c\u2022 %@%c is now known as %c%@%c", RCIRCAttributeBold, old, RCIRCAttributeBold, RCIRCAttributeBold, new_, RCIRCAttributeBold] from:@"" time:nil type:RCMessageTypeNormalE];
					[nself recievedMessage:[NSString stringWithFormat:@"%c\u2022 %@%c is now known as %c%@%c", RCIRCAttributeBold, old, RCIRCAttributeBold, RCIRCAttributeBold, new_, RCIRCAttributeBold] from:@"" time:nil type:RCMessageTypeNormalE];
					return;
				}
				[self setChannelName:new_];
			}
			[self recievedMessage:[NSString stringWithFormat:@"%c\u2022 %@%c is now known as %c%@%c", RCIRCAttributeBold, old, RCIRCAttributeBold, RCIRCAttributeBold, new_, RCIRCAttributeBold] from:@"" time:nil type:RCMessageTypeNormalE];
		}
	});
}

- (void)shouldPost:(BOOL)isHighlight withMessage:(NSString *)msg {
//	[self setUserJoined:[self channelName]];
//	[self setUserJoined:[delegate useNick]];
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
//		newMessageCount++;
//		if ([[RCChatController sharedController] isShowingChatListView]) {
//			if (newMessageCount > 101) return;
//			// if it's at 100, it will stop drawing anything new anyways. since the 99+ thing. so k
//			[cellRepresentation setNewMessageCount:newMessageCount];
//			[cellRepresentation performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
//		}
//	}
}

- (NSNumber *)heightForString:(NSString *)str {
	return 0;
//    return @([str boundingRectWithSize:CGSizeMake([RCTopViewCard cardWidth] - 20, CGFLOAT_MAX)
//                                options:NSStringDrawingUsesLineFragmentOrigin
//                             attributes:@{ NSFontAttributeName: [UIFont systemFontOfSize:14] }
//                                context:nil].size.height+20);
}

- (void)requestWhoisInformation {
//	thirstyForWhois = YES;
//	// remember: override users WHOIS command and do remote WHOIS, similar to this below.
//	[delegate sendMessage:[NSString stringWithFormat:@"WHOIS %@ %@", channelName, channelName]];
}

- (void)recievedWHOISInformation {
	thirstyForWhois = NO;
	hasWhois = YES;
    self.cellHeights = @[[self heightForString:self.ipInfo], [self heightForString:self.chanInfos], [self heightForString:self.connectionInfo]];
//	self.finalWhoisInfoString = [NSString stringWithFormat:@"%@\r\n\r\n%@\r\n\r\n%@", self.ipInfo, self.chanInfos, self.connectionInfo];
//	NSLog(@"meh %@", usersPanel);
	[usersPanel reloadData];
}

- (void)setPartnerIsOnline:(BOOL)partnerIsOnline {
	
}

- (void)setJoined:(BOOL)joind withArgument:(NSString *)arg1 {
	if (joind) {
		partnerIsOnline = YES;
	}
	return;
} 

- (void)setSuccessfullyJoined:(BOOL)success {
	
}

- (void)setJoined:(BOOL)joind {
}

- (BOOL)joined {
	return YES;
}

- (BOOL)isUserInChannel:(NSString *)user {
	return [user isEqualToString:channelName] || [user isEqualToString:[[self delegate] useNick]];
}

- (BOOL)isPrivate {
	return YES;
}

@end
