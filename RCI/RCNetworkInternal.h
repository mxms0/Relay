//
//  RCNetworkInternal.h
//  Relay IRC
//
//  Created by Max Shavrick on 2/14/16.
//  Copyright © 2016 Mxms. All rights reserved.
//

#ifndef RCNetworkInternal_h
#define RCNetworkInternal_h

#import "RCNetwork.h"

@interface RCNetwork ()
@property (nonatomic, retain) NSString *uniqueIdentifier;
@property (atomic, readwrite) RCSocketStatus status;
@end

#endif /* RCNetworkInternal_h */
