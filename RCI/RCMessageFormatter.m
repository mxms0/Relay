//
//  RCMessageFormatter.m
//  Relay
//
//  Created by Siberia on 6/10/14.
//  Copyright (c) 2014 American Heritage School. All rights reserved.
//

#import "RCMessageFormatter.h"
#import "RCI.h"

@implementation RCMessageFormatter
@synthesize message, sender, color, attributedString, height, nameWidth, landscapeHeight;

- (id)initWithMessage:(NSString *)_message {
	if ((self = [super init])) {
		self.message = _message;
	}
	return self;
}
- (void)dealloc {
	self.attributedString = nil;
	self.message = nil;
	self.sender = nil;
	[super dealloc];
}

@end
