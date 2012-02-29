//
//  RCMessage.m
//  Relay
//
//  Created by Max Shavrick on 2/20/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCMessage.h"

@implementation RCMessage
@synthesize flavor, message, isHighlight;

- (void)dealloc {
	[message release];
	[super dealloc];
}
@end
