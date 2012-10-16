//
//  RCBasicCommands.m
//  Relay
//
//  Created by Max Shavrick on 10/15/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCBasicCommands.h"

@implementation RCBasicCommands

+ (void)load {
	RCCommandEngine *e = [RCCommandEngine sharedInstance];
	[e registerSelector:@selector(handleME:net:) forCommands:@"me" usingClass:self];
	[e registerSelector:@selector(handleNP:net:) forCommands:[NSArray arrayWithObjects:@"nowplaying", @"np", @"ipod", nil] usingClass:self];
	[e registerSelector:@selector(someTest:net:) forCommands:@"test" usingClass:self];
}

- (void)handleNP:(NSString *)np net:(RCNetwork *)net {
		
}

@end
