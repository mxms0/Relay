//
//  RCOperation.m
//  Relay
//
//  Created by Max Shavrick on 7/23/13.
//

#import "RCOperation.h"

@implementation RCOperation
@synthesize delegate, cancelled;

- (id)init {
	if ((self = [super init])) {
		cancelled = NO;
	}
	return self;
}

- (BOOL)isFinished {
	return finished;
}

- (BOOL)isExecuting {
	return executing;
}

- (BOOL)isConcurrent {
	return YES;
}

- (void)cancel {
	cancelled = YES;
	[super cancel];
}

- (void)start {
	[super start];
	NSLog(@"fds %d", self.isCancelled);
	if (!self.cancelled) {
		[self willChangeValueForKey:@"isExecuting"];
		[NSThread detachNewThreadSelector:@selector(searchForKeyword:) toTarget:delegate withObject:self];
        executing = YES;
        [self didChangeValueForKey:@"isExecuting"];
	}
	else {
		[self finish];
	}
}

- (void)finish {
	[self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    executing = NO;
    finished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end
