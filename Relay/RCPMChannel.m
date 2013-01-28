//
//  RCPMChannel.m
//  Relay
//
//  Created by Max Shavrick on 3/24/12.
//

#import "RCPMChannel.h"
#import "RCNetworkManager.h"
#import "RCChatController.h"
#import "NSString+IRCStringSupport.h"

@implementation RCPMChannel
@synthesize ipInfo, chanInfos, connectAddr;

- (id)initWithChannelName:(NSString *)_name {
	if ((self = [super initWithChannelName:_name])) {
		partnerIsOnline = NO;
		ipInfo = nil;
		chanInfos = nil;
		connectAddr = nil;
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
    panel = [[RCChatPanel alloc] initWithStyle:UITableViewStylePlain andChannel:self];
	[fullUserList addObject:chan];
}

- (void)changeNick:(NSString *)old toNick:(NSString *)new_ {
	dispatch_async(dispatch_get_main_queue(), ^(void){
		@synchronized(self) {
			if ([old isEqualToString:[self channelName]]) {
				if ([[self delegate] channelWithChannelName: new_]) {
					id nself = [[self delegate] channelWithChannelName: new_];
					[self recievedMessage:[NSString stringWithFormat:@"%c\u2022 %@%c is now known as %c%@%c", RCIRCAttributeBold, old, RCIRCAttributeBold, RCIRCAttributeBold, new_, RCIRCAttributeBold] from:@"" type:RCMessageTypeNormalE];
					[nself recievedMessage:[NSString stringWithFormat:@"%c\u2022 %@%c is now known as %c%@%c", RCIRCAttributeBold, old, RCIRCAttributeBold, RCIRCAttributeBold, new_, RCIRCAttributeBold] from:@"" type:RCMessageTypeNormalE];
					return;
				}
				[self setChannelName:new_];
			}
			[self recievedMessage:[NSString stringWithFormat:@"%c\u2022 %@%c is now known as %c%@%c", RCIRCAttributeBold, old, RCIRCAttributeBold, RCIRCAttributeBold, new_, RCIRCAttributeBold] from:@"" type:RCMessageTypeNormalE];
		}
	});
}

- (void)shouldPost:(BOOL)isHighlight withMessage:(NSString *)msg {
	[self setUserJoined:[self channelName]];
	[self setUserJoined:[delegate useNick]];
	if (isHighlight) {
		if ([[RCNetworkManager sharedNetworkManager] isBG]) {
			UILocalNotification *nc = [[UILocalNotification alloc] init];
			[nc setFireDate:[NSDate date]];
			[nc setAlertBody:[msg stringByStrippingIRCMetadata]];
            [nc setSoundName:UILocalNotificationDefaultSoundName];
			[nc setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[delegate _description], RCCurrentNetKey, [self channelName], RCCurrentChanKey, nil]];
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

- (void)_reallySetWhois:(NSString *)whois {

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

	return;
}

- (void)setJoined:(BOOL)joind {
    return;
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
