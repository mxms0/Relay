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
	NSString *connectionInfo;
	NSString *finalWhoisInfoString;
	BOOL partnerIsOnline;
}
@property (nonatomic, retain) NSString *ipInfo;
@property (nonatomic, retain) NSString *chanInfos;
@property (nonatomic, retain) NSString *connectionInfo;
@property (nonatomic, retain) NSArray *cellHeights;
@property (nonatomic, assign) BOOL thirstyForWhois;
@property (nonatomic, assign) BOOL hasWhois;
- (BOOL)isPrivate;
- (void)requestWhoisInformation;
- (void)recievedWHOISInformation;
@end
