//
//  RCNetworkManager.m
//  Relay
//
//  Created by James Long on 23/12/2011.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import "RCNetworkManager.h"

@implementation RCNetworkManager

static RCNetworkManager *rcNetworkManager = nil;

+ (RCNetworkManager *)sharedManager {
    if (!rcNetworkManager) {
        rcNetworkManager = [[RCNetworkManager alloc] init];
    }
    return rcNetworkManager;
}

@end
