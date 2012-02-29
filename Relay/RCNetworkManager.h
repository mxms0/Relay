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
	
}
+ (RCNetworkManager *)sharedNetworkManager;
- (RCNetwork *)networkWithDescription:(NSString *)_desc;
- (void)ircNetworkWithInfo:(NSDictionary *)info;
- (NSMutableArray *)networks;
+ (void)saveNetworks;
- (void)saveNetworks;
- (void)unpack;

@end
