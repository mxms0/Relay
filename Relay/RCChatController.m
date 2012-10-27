//
//  RCChatController.m
//  Relay
//
//  Created by Max Shavrick on 10/26/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChatController.h"

@implementation RCChatController
@synthesize view;
static id _inst = nil;

+ (id)sharedInstance {
	if (!_inst) _inst = [[self alloc] init];
	return _inst;
}

@end
