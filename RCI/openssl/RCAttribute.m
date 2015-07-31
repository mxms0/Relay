//
//  RCAttribute.m
//  Relay
//
//  Created by Max Shavrick on 7/27/14.
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
