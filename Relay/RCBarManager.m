//
//  RCBarManager.m
//  Relay
//
//  Created by Max Shavrick on 3/23/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCBarManager.h"

@implementation RCBarManager
@synthesize rightGroup, leftGroup;

- (id)init {
	if ((self = [super init])) {
		rightGroup = [[RCBarGroup alloc] initWithFrame:CGRectMake(0, 0, 15, 29)];
		leftGroup = [[RCBarGroup alloc] initWithFrame:CGRectMake(0, 0, 15, 29)];
	}
	return self;
}

@end
