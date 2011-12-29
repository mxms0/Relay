//
//  RCNetworkManager.h
//  Relay
//
//  Created by Max Shavrick on 12/24/11.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCNEtwork.h"

@interface RCNetworkManager : NSObject {

}

+ (id)sharedNetworkManager;
- (void)unpack;
- (id)networks;
+ (void)saveNetworks;
- (void)saveNetworks;
- (void)addNetwork:(RCNetwork *)net;
@end
