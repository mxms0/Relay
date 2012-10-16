//
//  RCCommandEngine.m
//  Relay
//
//  Created by Max Shavrick on 10/15/12.
//

#import "RCCommandEngine.h"
#import "RCNetwork.h"

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
		[cmds setObject:[NSArray arrayWithObjects:NSStringFromSelector(selector), NSStringFromClass(mee), nil] forKey:commands];
	else {
		for (NSString *command in commands) {
			if ([command isKindOfClass:[NSString class]])
				[cmds setObject:[NSArray arrayWithObjects:NSStringFromSelector(selector), NSStringFromClass(mee), nil] forKey:command];
		}
	}
}

- (void)handleCommand:(NSString *)command fromNetwork:(RCNetwork *)net {
	@synchronized(self) {
		NSString *_cmd;
		NSString *_crap;
		NSScanner *scan = [[NSScanner alloc] initWithString:command];
		[scan scanUpToString:@" " intoString:&_cmd];
		NSArray *info = [cmds objectForKey:_cmd];
		if (info && ([info count] == 2)) {
			SEL call = NSSelectorFromString([info objectAtIndex:0]);
			Class target = NSClassFromString([info objectAtIndex:1]);
			if (!target) {
				[self errorHandlingCommand:command forNetwork:net];
				[scan release];
				return;
			}
			id obj = [[target alloc] init];
			[scan scanUpToString:@"" intoString:&_crap];
			if ([scan scanLocation] == [_cmd length])
				_crap = nil;
			@try {
				objc_msgSend(obj, call, _crap, net);
			}
			@catch (NSException *e) {
				NSLog(@"RELAY:: BAD SELECTOR [%@] CLASS: [%@]", NSStringFromSelector(call), NSStringFromClass(target));;
			}
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

@end
