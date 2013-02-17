//
//  RCNetworkManager.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCNetworkManager.h"
#import "RCChatController.h"

@implementation RCNetworkManager
@synthesize isBG, _printMotd;
static id snManager = nil;
static NSMutableArray *networks = nil;

- (void)ircNetworkWithInfo:(NSDictionary *)info isNew:(BOOL)n {
	RCNetwork *network = [RCNetwork networkWithInfoDictionary:info];
	[self addNetwork:network];
}

- (void)addNetwork:(RCNetwork *)_net {
	for (RCNetwork *net in networks) {
		if ([[net _description] isEqualToString:[_net _description]]) {
			return;
		}
	}
	if (![_net consoleChannel]) [_net addChannel:@"\x01IRC" join:NO];
	[networks addObject:_net];
	if ([_net COL]) [_net connect];
	if (!isSetup) [self saveNetworks];
}

- (BOOL)replaceNetwork:(RCNetwork *)orig withNetwork:(RCNetwork *)anew {
	for (int i = 0; i < [networks count]; i++) {
		RCNetwork *someNet = [networks objectAtIndex:i];
		if ([[someNet _description] isEqualToString:[orig _description]]) {
			[networks removeObjectAtIndex:i];
			someNet = nil;
			[networks insertObject:anew atIndex:i];
			[anew release];
			return YES;
		}
	}
	return NO;
}

- (void)removeNet:(RCNetwork *)net {
	@synchronized(self) {
		if ([net isConnected]) {
			[net disconnect];
		}
		[networks removeObject:net];
		if ([networks count] == 0) {
			[self setupWelcomeView];
		}
		else {
			reloadNetworks();
		}
		[self saveNetworks];
	}
}

- (void)jumpToFirstNetworkAndConsole {
	if ([networks count] < 1) return;
	[[RCChatController sharedController] selectChannel:@"\x01IRC" fromNetwork:[networks objectAtIndex:0]];
}

- (void)setupWelcomeView {
	NSLog(@"SHOULD BRING UP ADD NETWORK CONTROLLERR !!11");
	[[RCChatController sharedController] setDefaultTitleAndSubtitle];
}

- (void)unpack {
	isSetup = YES;
	_printMotd = YES;
	@autoreleasepool {
		NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithContentsOfFile:[self networkPreferencesPath]] autorelease];
		if (!dict) {
			isSetup = NO;
			return;
		}
		if ([[dict allKeys] count] == 0) {
			[self setupWelcomeView];
			isSetup = NO;
			return;
		}
		for (NSString *_net in [dict allKeys]) {
			NSDictionary *_info = [dict objectForKey:_net];
			[self ircNetworkWithInfo:_info isNew:NO];
		}
	}
	[self jumpToFirstNetworkAndConsole];
	reloadNetworks();
	isSetup = NO;
}

- (RCNetwork *)networkWithDescription:(NSString *)_desc {
	for (RCNetwork *net in networks) {
		if ([[net _description] isEqualToString:_desc]) return net;
	}
	return nil;
}

- (NSString *)networkPreferencesPath {
	char *hdir = getenv("HOME");
	if (!hdir) {
		NSLog(@"CAN'T FIND HOME DIRECTORY TO LOAD NETWORKS");
		exit(1);
	}
	NSString *absol = [[NSString stringWithFormat:@"%s/Documents/Networks.plist", hdir] retain];
	return [absol autorelease];
}

- (void)saveNetworks {
	if (isSetup) return;
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	for (RCNetwork *net in networks) {
		if (![net isKindOfClass:[RCWelcomeNetwork class]])
			if ([net _description])	[dict setObject:[net infoDictionary] forKey:[net _description]];
	}
	NSString *error;
	NSData *saveData = [NSPropertyListSerialization dataFromPropertyList:dict format:NSPropertyListBinaryFormat_v1_0 errorDescription:&error];
	if (![saveData writeToFile:[self networkPreferencesPath] atomically:NO]) {
		NSLog(@"Couldn't save.. :(%@)", error);
	}
}

+ (RCNetworkManager *)sharedNetworkManager {
	@synchronized(self) {
		if (!snManager) snManager = [[self alloc] init];
	}
	return snManager;
}

- (RCNetworkManager *)init {
	if ((self = [super init])) {
		isBG = NO;
		saving = NO;
		networks = [[NSMutableArray alloc] init];
	}
	snManager = self;
	return snManager;
}

- (NSMutableArray *)networks {
	return networks;
}

- (void)dealloc {
	[networks release];
	networks = nil;
	[super dealloc];
}

@end
