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
@synthesize message;

- (id)initWithMessage:(RCMessage *)_message {
	if ((self = [super init])) {
		self.message = _message;
	}
	return self;
}

- (void)formatMessage {
	int numeric = [[self.message numeric] intValue];
	
	switch (numeric) {
		
			
	}
}

- (void)dealloc {
	self.message = nil;
	[super dealloc];
}

@end
