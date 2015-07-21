//
//  RCAttribute.m
//  Relay
//
//  Created by Siberia on 7/27/14.
//  Copyright (c) 2014 American Heritage School. All rights reserved.
//

#import "RCAttribute.h"

@implementation RCAttribute
@synthesize end = _end, type = _type, start = _start;

- (id)initWithType:(RCIRCAttribute)typ start:(int)pos {
	if ((self = [super init])) {
		_type = typ;
		_start = pos;
	}
	return self;
}

@end
