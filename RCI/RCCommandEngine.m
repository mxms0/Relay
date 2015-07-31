//
//  RCCommandEngine.m
//  Relay
//
//  Created by Max Shavrick on 10/15/12.
//

#import "RCCommandEngine.h"
#import "RCNetwork.h"
#include <objc/message.h>

@implementation RCCommandEngine
static id _eInstance = nil;

+ (id)sharedInstance {
	if (!_eInstance) _eInstance = [[self alloc] init];
	return _eInstance;
}

- (id)init {
	if ((self = [super init])) {
		cmds = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (void)registerSelector:(SEL)selector forCommands:(id)commands usingClass:(Class)mee {
	if ([commands isKindOfClass:[NSString class]])
		[cmds setObject:[NSArray arrayWithObjects:NSStringFromSelector(selector), NSStringFromClass(mee), nil] forKey:[commands lowercaseString]];
	else {
		for (NSString *command in commands) {
			[cmds setObject:[NSArray arrayWithObjects:NSStringFromSelector(selector), NSStringFromClass(mee), nil] forKey:[command lowercaseString]];
		}
	}
}

- (void)handleCommand:(NSString *)command fromNetwork:(RCNetwork *)net forChannel:(RCChannel *)chan {
	@synchronized(self) {
		NSString *cmd_ = nil;
		NSString *_rest = nil;
		NSScanner *scan = [[NSScanner alloc] initWithString:command];
		[scan scanUpToString:@" " intoString:&cmd_];
		cmd_ = [cmd_ lowercaseString];
		NSArray *info = [cmds objectForKey:cmd_];
		if (info && ([info count] == 2)) {
			SEL call = NSSelectorFromString([info objectAtIndex:0]);
			Class target = NSClassFromString([info objectAtIndex:1]);
			if (!target) {
				[self errorHandlingCommand:command forNetwork:net];
				[scan release];
				return;
			}
			id obj = [[target alloc] init];
			[scan scanUpToString:@"" intoString:&_rest];
#if LOGALL
			NSLog(@"Command recieved: SEL:[%@] target:[%@] args:[%@]", NSStringFromSelector(call), obj, _rest);
#endif
			@try {
				((void (*)(id, SEL, id, id, id))objc_msgSend)(obj, call, _rest, net, chan);
			}
			@catch (NSException *e) {
				NSLog(@"RELAY::ERROR SELECTOR [%@] CLASS: [%@] EXC: [%@]", NSStringFromSelector(call), NSStringFromClass(target), e);
			}
			[obj release]; // still not sure wether or not this is a good idea. hm
			[scan release];
		}
		else {
			// command not found.
			[self errorHandlingCommand:command forNetwork:net];
			[scan release];
		}
	}
}

- (void)errorHandlingCommand:(NSString *)cmd forNetwork:(RCNetwork *)net {
	[net sendMessage:cmd];
}

- (NSArray *)commandsMatchingString:(NSString *)str {
	return [[cmds allKeys] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(SELF beginswith[cd] %@)", str]];
}

@end
