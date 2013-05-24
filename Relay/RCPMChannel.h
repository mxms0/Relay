//
//  RCPMChannel.h
//  Relay
//
//  Created by Max Shavrick on 3/24/12.
//

#import "RCChannel.h"

@interface RCPMChannel : RCChannel {
	NSString *ipInfo;
	NSString *chanInfos;
	BOOL partnerIsOnline;
	NSString *connectAddr;
}
@property (nonatomic, retain) NSString *ipInfo;
@property (nonatomic, retain) NSString *chanInfos;
@property (nonatomic, retain) NSString *connectAddr;
@property (nonatomic, readonly) BOOL thirstyForWhois;
- (BOOL)isPrivate;
- (void)_reallySetWhois:(NSString *)whois;
- (void)requestWhoisInformation;
@end
