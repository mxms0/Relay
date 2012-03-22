//
//  RCNetworkManager.h
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import <Foundation/Foundation.h>
#import "RCNetwork.h"
#import "RCWelcomeNetwork.h"

@interface RCNetworkManager : NSObject {
	BOOL isBG;
}
@property (nonatomic, assign) BOOL isBG;
+ (RCNetworkManager *)sharedNetworkManager;
- (RCNetwork *)networkWithDescription:(NSString *)_desc;
- (void)ircNetworkWithInfo:(NSDictionary *)info isNew:(BOOL)n;
- (void)addNetwork:(RCNetwork *)net;
- (NSMutableArray *)networks;
- (void)removeNet:(RCNetwork *)net;
+ (void)saveNetworks;
- (void)saveNetworks;
- (void)unpack;

@end
