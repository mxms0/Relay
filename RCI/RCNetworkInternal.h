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

#define RCUnimplemented() \
	do {\
		NSLog(@"UNIMPLEMENTED. %s", __PRETTY_FUNCTION__);\
	} while (0);

@interface RCNetwork ()
@property (nonatomic, retain) NSString *uniqueIdentifier;
@property (atomic, readwrite) RCSocketStatus status;
@property (atomic, readwrite) BOOL reading;
@property (atomic, readwrite) BOOL writing;
@property (atomic, readwrite) NSTimer *disconnectTimer;
@end

#endif /* RCNetworkInternal_h */
