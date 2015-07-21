//
//  RCColorAttribute.m
//  Relay
//
//  Created by Max Shavrick on 7/27/14.
//

#import "RCColorAttribute.h"

@implementation RCColorAttribute
@synthesize fg = _fg, bg = _bg;

- (id)initWithType:(RCIRCAttribute)typ start:(int)pos fg:(int)fg bg:(int)bg {
	if ((self = [super initWithType:typ start:pos])) {
		_fg = fg;
		_bg = bg;
	}
	return self;
}

@end
