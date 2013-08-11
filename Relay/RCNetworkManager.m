//
//  RCNetworkManager.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCNetworkManager.h"
#import "RCChatController.h"

@implementation RCNetworkManager
@synthesize isBG;
static id snManager = nil;
static NSMutableArray *networks = nil;

- (void)ircNetworkWithInfo:(NSDictionary *)info isNew:(BOOL)n {
	RCNetwork *network = [RCNetwork networkWithInfoDictionary:info];
	[self addNetwork:network];
}

- (void)addNetwork:(RCNetwork *)_net {
	for (RCNetwork *net in networks) {
		if ([[net uUID] isEqualToString:[_net uUID]]) {
			return;
		}
	}
	if (![_net consoleChannel]) [_net addChannel:@"\x01IRC" join:NO];
	[networks insertObject:_net atIndex:[networks count]];
	if ([_net COL]) [_net connect];
	if (!isSetup) [self saveNetworks];
}

- (BOOL)replaceNetwork:(RCNetwork *)orig withNetwork:(RCNetwork *)anew {
	for (int i = 0; i < [networks count]; i++) {
		RCNetwork *someNet = [networks objectAtIndex:i];
		if ([[someNet uUID] isEqualToString:[orig uUID]]) {
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

- (void)receivedMemoryWarning {
	for (RCNetwork *net in networks) {
		for (RCChannel *chan in net->_channels) {
			if ([chan isKindOfClass:[RCPMChannel class]]) {
				[(RCPMChannel *)chan setIpInfo:nil];
				[(RCPMChannel *)chan setConnectionInfo:nil];
				[(RCPMChannel *)chan setChanInfos:nil];
			}
		}
	}
	// also consider trimming conversations down to like 30 messages
	// but thats probably slow being that webkit needs to be on main thread
	// hm.. what can i trash..
}

- (void)setupWelcomeView {
	NSLog(@"SHOULD BRING UP ADD NETWORK CONTROLLERR !!11");
	[[RCChatController sharedController] setDefaultTitleAndSubtitle];
}

- (void)unpack {
	isSetup = YES;
	@autoreleasepool {
		NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithContentsOfFile:[self networkPreferencesPath]] autorelease];
		if (!dict) {
			isSetup = NO;
			return;
		}
		NSArray *nets = [dict objectForKey:@"0_NSO"];
		if ([nets count] == 0) {
			[self setupWelcomeView];
			isSetup = NO;
			return;
		}
		for (NSDictionary *_info in nets) {
			[self ircNetworkWithInfo:_info isNew:NO];
		}
	}
	[self jumpToFirstNetworkAndConsole];
	reloadNetworks();
	isSetup = NO;
}

- (RCNetwork *)networkWithDescription:(NSString *)_desc {
	for (RCNetwork *net in networks) {
		if ([[net uUID] isEqualToString:_desc]) return net;
	}
	return nil;
}

- (NSString *)networkPreferencesPath {
	char *hdir = getenv("HOME");
	if (!hdir) {
		NSLog(@"CAN'T FIND HOME DIRECTORY TO LOAD NETWORKS");
		exit(1);
	}
	char dir[4096];
	sprintf(dir, "%s/Documents/Networks.plist", hdir);
	NSString *absol = [[NSString alloc] initWithUTF8String:dir];
	return [absol autorelease];
}

- (void)saveNetworks {
	if (isSetup) return;
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	NSMutableArray *sav = [[NSMutableArray alloc] init];
	for (RCNetwork *net in networks) {
		if ([net uUID]) [sav addObject:[net infoDictionary]];
	}
	[dict setObject:sav forKey:@"0_NSO"];
	[sav release];
	// this is why order isn't maintained. it's being added to a dictionary.
	// fixx THIS LATER MAX OR FUDGE WILL KILL YOU.
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

- (NSDictionary *)settingsDictionary {
	NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:SETTINGS_KEY];
	if (!dict) {
		dict = [NSDictionary dictionary];
	}
	return [[dict retain] autorelease];
}

- (id)valueForSetting:(NSString *)set {
	NSDictionary *settings = [[NSUserDefaults standardUserDefaults] dictionaryForKey:SETTINGS_KEY];
	return [settings objectForKey:set];
}

- (void)setValue:(id)val forSetting:(NSString *)set {
	NSMutableDictionary *dict = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:SETTINGS_KEY] mutableCopy];
	if (!dict) {
		dict = [[NSMutableDictionary alloc] init];
	}
	[dict setValue:val forKey:set];
	[self saveSettingsDictionary:dict dispatchChanges:NO];
	[dict release];
}

- (void)saveSettingsDictionary:(NSDictionary *)dict dispatchChanges:(BOOL)dispatch {
	[[NSUserDefaults standardUserDefaults] setValue:dict forKey:SETTINGS_KEY];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[[NSNotificationCenter defaultCenter] postNotificationName:SETTINGS_CHANGED_KEY object:nil];
}

- (void)dealloc {
	[networks release];
	networks = nil;
	[super dealloc];
}

@end
