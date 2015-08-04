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
		channelName = [_name retain];
		joinOnConnect = YES;
		cellRepresentation = nil;
		self.joined = YES;
		newMessageCount = 0;
		userRanksAdv = [NSMutableDictionary new];
		fullUserList = [[NSMutableArray alloc] init];
		[fullUserList addObject:_name];
	}
	return self;
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
					[self recievedMessage:[NSString stringWithFormat:@"%c\u2022 %@%c is now known as %c%@%c", RCIRCAttributeBold, old, RCIRCAttributeBold, RCIRCAttributeBold, new_, RCIRCAttributeBold] from:@"" time:nil type:RCMessageTypeNormalEx];
					[nself recievedMessage:[NSString stringWithFormat:@"%c\u2022 %@%c is now known as %c%@%c", RCIRCAttributeBold, old, RCIRCAttributeBold, RCIRCAttributeBold, new_, RCIRCAttributeBold] from:@"" time:nil type:RCMessageTypeNormalEx];
					return;
				}
				[self setChannelName:new_];
			}
			[self recievedMessage:[NSString stringWithFormat:@"%c\u2022 %@%c is now known as %c%@%c", RCIRCAttributeBold, old, RCIRCAttributeBold, RCIRCAttributeBold, new_, RCIRCAttributeBold] from:@"" time:nil type:RCMessageTypeNormalEx];
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

- (void)setJoined:(BOOL)joind withArgument:(NSString *)arg1 {
	if (joind) {
		partnerIsOnline = YES;
	}
	return;
} 

- (void)setSuccessfullyJoined:(BOOL)success {
	
}

- (void)setJoined:(BOOL)joind {}

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
