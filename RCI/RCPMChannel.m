//
//  RCPMChannel.m
//  Relay
//
//  Created by Max Shavrick on 3/24/12.
//

#import "RCPMChannel.h"
#import "RCNetwork.h"

@implementation RCPMChannel
@synthesize ipInfo=_ipInfo, chanInfos=_chanInfos, wantsWhois=_wantsWhois, hasWhois=_hasWhois, connectionInfo=_connectionInfo;

- (id)initWithChannelName:(NSString *)_name {
	if ((self = [super initWithChannelName:_name])) {
		self.joined = YES;
		[fullUserList addObject:_name];
	}
	return self;
}

- (void)changeNick:(NSString *)old toNick:(NSString *)new_ {
	dispatch_async(dispatch_get_main_queue(), ^ {
		@synchronized(self) {
			if ([old isEqualToString:[self channelName]]) {
				if ([(RCNetwork *)[self network] channelWithChannelName: new_]) {
					id nself = [[self network] channelWithChannelName: new_];
					[self receivedMessage:[NSString stringWithFormat:@"%c\u2022 %@%c is now known as %c%@%c", RCIRCAttributeBold, old, RCIRCAttributeBold, RCIRCAttributeBold, new_, RCIRCAttributeBold] from:@"" time:nil type:RCMessageTypeNormal];
					[nself receivedMessage:[NSString stringWithFormat:@"%c\u2022 %@%c is now known as %c%@%c", RCIRCAttributeBold, old, RCIRCAttributeBold, RCIRCAttributeBold, new_, RCIRCAttributeBold] from:@"" time:nil type:RCMessageTypeNormal];
					return;
				}
				[self setChannelName:new_];
			}
			[self receivedMessage:[NSString stringWithFormat:@"%c\u2022 %@%c is now known as %c%@%c", RCIRCAttributeBold, old, RCIRCAttributeBold, RCIRCAttributeBold, new_, RCIRCAttributeBold] from:@"" time:nil type:RCMessageTypeNormal];
		}
	});
}

- (void)requestWhoisInformation {
//	thirstyForWhois = YES;
//	// remember: override users WHOIS command and do remote WHOIS, similar to this below.
//	[delegate sendMessage:[NSString stringWithFormat:@"WHOIS %@ %@", channelName, channelName]];
}

- (void)recievedWHOISInformation {
//	thirstyForWhois = NO;
//	hasWhois = YES;
//    self.cellHeights = @[[self heightForString:self.ipInfo], [self heightForString:self.chanInfos], [self heightForString:self.connectionInfo]];
//	self.finalWhoisInfoString = [NSString stringWithFormat:@"%@\r\n\r\n%@\r\n\r\n%@", self.ipInfo, self.chanInfos, self.connectionInfo];
//	NSLog(@"meh %@", usersPanel);
//	[usersPanel reloadData];
}

- (void)setPartnerIsOnline:(BOOL)partnerIsOnline {
	
}

- (void)setSuccessfullyJoined:(BOOL)success {}

- (void)join {}

- (void)part {}

- (void)setJoined:(BOOL)joind {}

- (BOOL)joined {
	return YES;
}

- (BOOL)isUserInChannel:(NSString *)user {
	return [user isEqualToString:_channelName] || [user isEqualToString:[[self network] nickname]];
}

- (BOOL)isPrivate {
	return YES;
}

@end
