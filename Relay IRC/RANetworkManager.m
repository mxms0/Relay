//
//  RANetworkManager.m
//  Relay IRC
//
//  Created by Max Shavrick on 7/20/15.
//  Copyright (c) 2015 Mxms. All rights reserved.
//

#import "RANetworkManager.h"

@implementation RANetworkManager
@synthesize isBG, isSettingUp;
static id snManager = nil;
static NSMutableArray *networks = nil;

//- (void)ircNetworkWithInfo:(NSDictionary *)info isNew:(BOOL)n {
//	RCNetwork *network = [RCNetwork networkWithInfoDictionary:info];
//	[self addNetwork:network];
//}
//
- (void)addNetwork:(RCNetwork *)_net {
	for (RCNetwork *net in networks) {
		if ([[net uUID] isEqualToString:[_net uUID]]) {
			return;
		}
	}
	@synchronized(networks) {
		[networks addObject:_net];
	}
	if (!isSettingUp) [self saveNetworks];
}

//- (BOOL)replaceNetwork:(RCNetwork *)orig withNetwork:(RCNetwork *)anew {
//	for (int i = 0; i < [networks count]; i++) {
//		RCNetwork *someNet = [networks objectAtIndex:i];
//		if ([[someNet uUID] isEqualToString:[orig uUID]]) {
//			[networks removeObjectAtIndex:i];
//			someNet = nil;
//			[networks insertObject:anew atIndex:i];
//			reloadNetworks();
//			return YES;
//		}
//	}
//	[networks addObject:anew];
//	reloadNetworks();
//	return NO;
//}
//
//- (void)removeNet:(RCNetwork *)net {
//	if (!net) return;
//	@synchronized(self) {
//		if ([net isConnected]) {
//			[net disconnect];
//		}
//		[networks removeObject:net];
//		if ([networks count] == 0) {
//			[self setupWelcomeView];
//			[[RCChatController sharedController] selectChannel:nil fromNetwork:nil];
//		}
//		else {
//			reloadNetworks();
//		}
//		[self saveNetworks];
//	}
//}
//
//- (void)setAway:(BOOL)aw {
//	if ([[self valueForSetting:SHOULD_AWAY_KEY] boolValue])
//		for (RCNetwork *network in networks) {
//			if ([network isConnected]) {
//				if (!network.isAway) {
//					if (aw) [network sendMessage:@"AWAY :Be back later."];
//				}
//				else
//					if (!aw) [network sendMessage:@"AWAY"];
//			}
//		}
//}
//
//- (void)jumpToFirstNetworkAndConsole {
//	if ([networks count] < 1) return;
//	[[RCChatController sharedController] selectChannel:CONSOLECHANNEL fromNetwork:[networks objectAtIndex:0]];
//}
//
//- (void)receivedMemoryWarning {
//	for (RCNetwork *net in networks) {
//		for (RCChannel *chan in net->_channels) {
//			if ([chan isKindOfClass:[RCPMChannel class]]) {
//				[(RCPMChannel *)chan setIpInfo:nil];
//				[(RCPMChannel *)chan setConnectionInfo:nil];
//				[(RCPMChannel *)chan setChanInfos:nil];
//			}
//		}
//	}
//	// also consider trimming conversations down to like 30 messages
//	// but thats probably slow being that webkit needs to be on main thread
//	// hm.. what can i trash..
//}
//
//- (void)setupWelcomeView {
//	NSLog(@"SHOULD BRING UP ADD NETWORK CONTROLLERR !!11");
//	[[RCChatController sharedController] setDefaultTitleAndSubtitle];
//}

- (void)unpack {
	isSettingUp = YES;
	@autoreleasepool {
		NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithContentsOfFile:[self networkPreferencesPath]] autorelease];
		if (!dict) {
			isSettingUp = NO;
			return;
		}
		NSArray *nets = [dict objectForKey:@"0_NSO"];
		if ([nets count] == 0) {
//			[self setupWelcomeView];
			isSettingUp = NO;
			return;
		}
//		for (NSDictionary *_info in nets) {
//			
//			[self ircNetworkWithInfo:_info isNew:NO];
//		}
	}
//	[self jumpToFirstNetworkAndConsole];
//	reloadNetworks();
	isSettingUp = NO;
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
//	if (isSettingUp) return;
//#if IGNORE_SAVE
//	return;
//#endif
//	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//	NSMutableArray *sav = [[NSMutableArray alloc] init];
//	for (RCNetwork *net in networks) {
//		[net savePasswords];
//		if ([net uUID]) [sav addObject:[net infoDictionary]];
//	}
//	[dict setObject:sav forKey:@"0_NSO"];
//	[sav release];
//	NSError *error = nil;;
//	NSData *saveData = [NSPropertyListSerialization dataWithPropertyList:dict format:NSPropertyListBinaryFormat_v1_0 options:0 error:&error];
//	if (![saveData writeToFile:[self networkPreferencesPath] atomically:NO]) {
//		NSLog(@"Couldn't save.. :(%@)", error);
//	}
}

+ (instancetype)sharedNetworkManager {
	static id snManager = nil;
	static dispatch_once_t token;
	
	dispatch_once(&token, ^ {
		snManager = [[self alloc] init];
	});
	
	return snManager;
}

- (instancetype)init {
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

//- (NSDictionary *)settingsDictionary {
//	NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:SETTINGS_KEY];
//	if (!dict) {
//		dict = [NSDictionary dictionary];
//	}
//	return [[dict retain] autorelease];
//}
//
//- (id)valueForSetting:(NSString *)set {
//	NSDictionary *settings = [[NSUserDefaults standardUserDefaults] dictionaryForKey:SETTINGS_KEY];
//	NSData *dd = [settings objectForKey:set];
//	if (!dd) return nil;
//	NSString *ret = [[NSString alloc] initWithData:dd encoding:NSUTF8StringEncoding];
//	return [ret autorelease];
//}
//
//- (void)setValue:(id)val forSetting:(NSString *)set {
//	NSMutableDictionary *dict = [[[NSUserDefaults standardUserDefaults] dictionaryForKey:SETTINGS_KEY] mutableCopy];
//	if (!dict) {
//		dict = [[NSMutableDictionary alloc] init];
//	}
//	[dict setValue:[[val description] dataUsingEncoding:NSUTF8StringEncoding] forKey:set];
//	[self saveSettingsDictionary:dict dispatchChanges:NO];
//	[dict release];
//}
//
//- (void)saveSettingsDictionary:(NSDictionary *)dict dispatchChanges:(BOOL)dispatch {
//	[[NSUserDefaults standardUserDefaults] setValue:dict forKey:SETTINGS_KEY];
//	[[NSUserDefaults standardUserDefaults] synchronize];
//	if (dispatch) [self dispatchChanges];
//}

- (void)connectAll {
	for (RCNetwork *net in networks) {
		[net connect];
	}
}

- (void)disconnectAll {
	for (RCNetwork *net in networks) {
		[net disconnect];
	}
}

//- (void)dispatchChanges {
//	[[NSNotificationCenter defaultCenter] postNotificationName:SETTINGS_CHANGED_KEY object:nil];
//}

- (void)dealloc {
	[networks release];
	networks = nil;
	[super dealloc];
}

@end
