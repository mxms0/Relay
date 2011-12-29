//
//  RCNetworkManager.m
//  Relay
//
//  Created by Max Shavrick on 12/24/11.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import "RCNetworkManager.h"

@implementation RCNetworkManager

static NSMutableArray *networks = nil;
static id sharedInstance = nil;

+ (id)sharedNetworkManager {
	if (!sharedInstance) 
		sharedInstance = [[self alloc] init];
	return sharedInstance;
}

+ (void)saveNetworks {
	[[NSUserDefaults standardUserDefaults] setObject:([NSKeyedArchiver archivedDataWithRootObject:networks]) forKey:@"Networks"];
}
- (void)saveNetworks {
	[[self class] saveNetworks];
}

- (id)networks {
	return networks;
}

- (void)unpack {
	if (!networks) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Networks"]) {
			networks = [[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"Networks"]] mutableCopy];
		}
		else {
			networks = [[NSMutableArray alloc] init];
		}
		[pool drain];
	}
}

- (void)addNetwork:(RCNetwork *)net {
	NSLog(@"WHATTT %@ : %@", networks, net);
	for (RCNetwork *netw in networks) {
		if ([netw.sDescription isEqualToString:net.sDescription]) {
			NSLog(@"ERROR: Cannot have two servers with the same description.");
			return;
		}
	}
	[networks addObject:net];
	[self saveNetworks];
}

- (void)dealloc {
	[super dealloc];
	[networks release];
	networks = nil;
}

@end
