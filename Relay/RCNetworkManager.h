//
//  RCNetworkManager.h
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import <Foundation/Foundation.h>
#import "RCNetwork.h"

@interface RCNetworkManager : NSObject {
	
}
+ (RCNetworkManager *)sharedNetworkManager;
+ (void)ircNetworkWithInfo:(NSDictionary *)info;
- (NSMutableArray *)networks;
+ (void)saveNetworks;
- (void)saveNetworks;

@end
