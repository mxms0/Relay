//
//  RCPMChannel.h
//  Relay
//
//  Created by Max Shavrick on 3/24/12.
//

#import "RCChannel.h"

@interface RCPMChannel : RCChannel {
	NSString *_ipInfo;
	NSString *_chanInfos;
	NSString *_connectionInfo;
	NSString *_finalWhoisInfoString;
	BOOL _partnerIsOnline;
}
@property (nonatomic, retain) NSString *ipInfo;
@property (nonatomic, retain) NSString *chanInfos;
@property (nonatomic, retain) NSString *connectionInfo;
@property (nonatomic, assign) BOOL wantsWhois;
@property (nonatomic, assign) BOOL hasWhois;
- (BOOL)isPrivate;
- (void)requestWhoisInformation;
- (void)recievedWHOISInformation;
@end
