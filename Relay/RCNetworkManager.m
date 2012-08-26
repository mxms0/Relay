//
//  RCNetworkManager.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCNetworkManager.h"
#import "RCNavigator.h"

@implementation RCNetworkManager
@synthesize isBG, _printMotd;
static id snManager = nil;
static NSMutableArray *networks = nil;

- (void)ircNetworkWithInfo:(NSDictionary *)info isNew:(BOOL)n {
	RCNetwork *network = [[RCNetwork alloc] init];
	[network setUsername:[info objectForKey:USER_KEY]];
	[network setNick:[info objectForKey:NICK_KEY]];
	[network setRealname:[info objectForKey:NAME_KEY]];
	[network setSDescription:[info objectForKey:DESCRIPTION_KEY]];
	[network setServer:[info objectForKey:SERVR_ADDR_KEY]];
	[network setPort:[[info objectForKey:PORT_KEY] intValue]];
	[network setUseSSL:[[info objectForKey:SSL_KEY] boolValue]];
	[network setCOL:[[info objectForKey:COL_KEY] boolValue]];
	for (RCNetwork *net in networks) {
		if ([[network _description] isEqualToString:[net _description]]) {
			[network release];
			NSLog(@"Returning..");
			return;
		}
	}

	if ([[info objectForKey:S_PASS_KEY] boolValue]) {
        //[network setSpass:([wrapper objectForKey:S_PASS_KEY] ?: @"")];
		RCKeychainItem *item = [[RCKeychainItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%@spass", [network _description]]];
		[network setSpass:([item objectForKey:(id)kSecValueData] ?: @"")];
		if ([network spass] == nil || [[network spass] length] == 0) {
			[network setShouldRequestSPass:YES];
		}
		[item release];
	}
	if ([[info objectForKey:N_PASS_KEY] boolValue]) {
		//[network setNpass:([wrapper objectForKey:N_PASS_KEY] ?: @"")];
		RCKeychainItem *item = [[RCKeychainItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%@npass", [network _description]]];
        [network setNpass:([item objectForKey:(id)kSecValueData] ?: @"")];
		if ([network npass] == nil || [[network npass] length] == 0) {
			[network setShouldRequestNPass:YES];
		}
		[item release];
	}
	NSMutableArray *rooms = [[[info objectForKey:CHANNELS_KEY] mutableCopy] autorelease];
	if (!rooms) {
		[network addChannel:@"IRC" join:NO];
	}
	[network _setupRooms:rooms];
	[networks addObject:network];
	[[RCNavigator sharedNavigator] addNetwork:network];
	[network release];
    if ([network COL]) {
        [network connect];
    }
	[self performSelectorInBackground:@selector(saveNetworks) withObject:nil];
}

- (void)addNetwork:(RCNetwork *)_net {
	for (RCNetwork *net in networks) {
		if ([[net _description] isEqualToString:[_net _description]]) {
			return;
		}
	}
	if (![_net consoleChannel]) [_net addChannel:@"IRC" join:NO];
	[networks addObject:_net];
	[[RCNavigator sharedNavigator] addNetwork:_net];
	if ([_net COL]) [_net connect];
	if (!isSetup) [self saveNetworks];
}

- (void)finishSetupForNetwork:(RCNetwork *)net {
	// the alerts do not stop the connection to process to wait for the user to enter the password
	// so we dont want the network connecting until we get the users password or not.
	BOOL sc = NO;
	if ([net shouldRequestNPass]) {
		RCPasswordRequestAlert *alert = [[RCPasswordRequestAlert alloc] initWithNetwork:net type:RCPasswordRequestAlertTypeNickServ];
		[alert show];
		[alert release];
		sc = YES;
	}
	if ([net shouldRequestSPass]) {
		RCPasswordRequestAlert *alert = [[RCPasswordRequestAlert alloc] initWithNetwork:net type:RCPasswordRequestAlertTypeServer];
		[alert show];
		[alert release];
		sc = YES;
	}
	if (sc) return;
	if ([net COL]) [net connect];
}

- (void)removeNet:(RCNetwork *)net {
	@synchronized(self) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if ([net isConnected]) {
				[net disconnect];
			}
			[networks removeObject:net];
			if ([networks count] == 0) {
				[self setupWelcomeView];
			}
			else {
				[[RCNavigator sharedNavigator] selectNetwork:[networks objectAtIndex:0]];
			}
			[self saveNetworks];
		});
	}
}

- (void)unpack {
	isSetup = YES;
	_printMotd = YES;
	@autoreleasepool {
		NSMutableDictionary *dict = [[[NSMutableDictionary alloc] initWithContentsOfFile:PREFS_ABSOLUT] autorelease];
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
	isSetup = NO;
}

- (void)setupWelcomeView {
	RCWelcomeNetwork *net = [[RCWelcomeNetwork alloc] init];
	[net setSDescription:@"Welcome!"];	
	[net setServer:@"irc.nightcoast.net"]; // olol.
	[net addChannel:@"#Relay" join:YES];
    [[self networks] addObject:net];
	[[RCNavigator sharedNavigator] addNetwork:net];
	[[RCNavigator sharedNavigator] selectNetwork:net];
	RCChannel *chan = [net channelWithChannelName:@"#Relay"];
    [[RCNavigator sharedNavigator] channelSelected:[chan bubble]];
	[chan recievedMessage:@"Welcome to Relay!" from:@"" type:RCMessageTypeTopic];
	[[chan panel] setHidesEntryField:YES];
	[chan recievedMessage:@"Try out some cool features! :D" from:@"" type:RCMessageTypeNormal];
	[chan recievedMessage:@"Blah, Blah, more blah!" from:@"" type:RCMessageTypeNormal];
	[net release];
}

- (RCNetwork *)networkWithDescription:(NSString *)_desc {
	for (RCNetwork *net in networks) {
		if ([[net _description] isEqualToString:_desc]) return net;
	}
	return nil;
}

- (void)saveNetworks {
	if (isSetup) return;
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_PLIST] ?: [NSMutableDictionary dictionary];
	for (RCNetwork *net in networks) {
		if (![net isKindOfClass:[RCWelcomeNetwork class]])
			if ([net _description])	[dict setObject:[net infoDictionary] forKey:[net _description]];
	}
	NSString *error;
	NSData *saveData = [NSPropertyListSerialization dataFromPropertyList:dict format:NSPropertyListBinaryFormat_v1_0 errorDescription:&error];
	if (![saveData writeToFile:PREFS_ABSOLUT atomically:NO]) {
		NSLog(@"Couldn't save.. :(%@)", error);
		return;
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
