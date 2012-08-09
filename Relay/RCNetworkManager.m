//
//  RCNetworkManager.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCNetworkManager.h"
#import "RCNavigator.h"
#import "RCSSLNetwork.h"

@implementation RCNetworkManager
@synthesize isBG, _printMotd;
static id snManager = nil;
static NSMutableArray *networks = nil;

- (void)ircNetworkWithInfo:(NSDictionary *)info isNew:(BOOL)n {
	RCNetwork *network = nil;
	if ([[info objectForKey:SSL_KEY] boolValue]) {
		network = [[RCSSLNetwork alloc] init];
	}
	else {
		network = [[RCNetwork alloc] init];
	}
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
		RCKeychainItem *item = [[RCKeychainItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%@spass", [network _description]] accessGroup:nil];
		[network setSpass:([item objectForKey:(id)kSecValueData] ?: @"")];
		if ([network spass] == nil || [[network spass] length] == 0) {
			[network setShouldRequestSPass:YES];
		}
		[item release];
	}
	if ([[info objectForKey:N_PASS_KEY] boolValue]) {
		//[network setNpass:([wrapper objectForKey:N_PASS_KEY] ?: @"")];
		RCKeychainItem *item = [[RCKeychainItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%@npass", [network _description]] accessGroup:nil];
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
	[self performSelectorInBackground:@selector(saveNetworks) withObject:nil];
}

- (void)addNetwork:(RCNetwork *)_net {
	for (RCNetwork *net in networks) {
		if ([[net _description] isEqualToString:[_net _description]]) {
			return;
		}
	}
	if (![[[_net _channels] allKeys] containsObject:@"IRC"]) [_net addChannel:@"IRC" join:NO];
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
	[networks removeObject:net];
	if ([networks count] == 0) {
		[self setupWelcomeView];
	}
	[self saveChannelData:nil];
	[self saveNetworks];
}

- (void)unpack {
	isSetup = YES;
	_printMotd = NO;
	@autoreleasepool {
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFS_ABSOLUT];
		if (!dict) {
			isSetup = NO;
			return;
		}
		if ([[dict allKeys] count] == 0) {
			[self setupWelcomeView];
			[dict release];
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
	[net setServer:@"irc.nightcoast.net"];
	[net addChannel:@"#Relay" join:YES];
	RCChannel *chan = [[net _channels] objectForKey:@"#Relay"];
	[chan recievedMessage:@"Welcome to Relay!" from:@"" type:RCMessageTypeTopic];
	[[chan panel] setHidesEntryField:YES];
	[chan recievedMessage:@"Try out some cool features! :D" from:@"" type:RCMessageTypeNormal];
	[chan recievedMessage:@"Blah, Blah, more blah!" from:@"" type:RCMessageTypeNormal];
	[[self networks] addObject:net];
	[[RCNavigator sharedNavigator] addNetwork:net];
	[[RCNavigator sharedNavigator] channelSelected:[chan bubble]];
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

- (void)setupChannelData:(NSString *)nilOrNull {
	return;
	// FIX THIS FIX THIS FIX THIS
	/*
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:NETS_PLIST];
	NSDictionary *dataz = [[NSDictionary alloc] initWithContentsOfFile:path];
	if (!dataz) {
		NSLog(@"Uhh..");
		[pool drain];
		return;
	}
	NSLog(@"Unarchiving messages..");
	for (NSString *key in [dataz allKeys]) {
		RCNetwork *net = [self networkWithQuickDescription:key];
		if (net) {
			NSDictionary *subDataz = [dataz objectForKey:key];
			for (NSString *_key in [subDataz allKeys]) {
				RCChannel *_chan = [[net _channels] objectForKey:_key];
				if (!_chan) continue;
				NSArray *_msgs = [NSKeyedUnarchiver unarchiveObjectWithData:[subDataz objectForKey:_key]];
				if (!_msgs) continue;
				RCChatPanel *panel = [_chan panel];
				if (panel) {
					if ([_msgs count] > 0) {
						[[panel messages] addObjectsFromArray:_msgs];
						[[panel tableView] reloadData];
					}
				}
			}
		}
	}
	NSLog(@"Archived Messages..");
	[dataz release];
	[pool drain];
	 */
}

- (void)saveChannelData:(id)unused {
	if (saving) return;
	[self performSelectorInBackground:@selector(_reallySaveChannelData:) withObject:unused];
}

- (void)_reallySaveChannelData:(id)unused {
	saving = YES;
	/* REALLY BAD CODE.
	 // FIX THIS MAX. 
	 // REALLY BAD IDEAS IN THIS.
	NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:NETS_PLIST];
	NSUInteger hashCode = 00000;
	NSDictionary *_dict = [[NSDictionary alloc] initWithContentsOfFile:path];
	if (_dict) hashCode = (unsigned int)[[_dict objectForKey:@"0_UNSIGNEDHASH"] intValue];
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	for (RCNetwork *net in networks) {
		NSMutableDictionary *netDict = [[NSMutableDictionary alloc] init];
		for (NSString *_chan in [[net _channels] allKeys]) {
			RCChannel *chan = [net channelWithChannelName:_chan];
			if (chan) {
				NSArray *messages = [[chan panel] messages];
				NSData *_messages = [NSKeyedArchiver archivedDataWithRootObject:messages];
				[netDict setObject:_messages forKey:(NSString *)[NSString stringWithFormat:@"%@", chan.channelName]];
			}
		}
		[dict setObject:netDict forKey:[net descriptionForComparing]];
		[netDict release];
	}
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
		[[NSFileManager defaultManager] createFileAtPath:path contents:(NSData *)[NSDictionary dictionary] attributes:NULL];
	}
	if (hashCode == [dict hash]) {
		NSLog(@"not saving..");
		goto end;
	}
	[dict setObject:[NSString stringWithFormat:@"%u", [dict hash]] forKey:@"0_UNSIGNEDHASH"];
	if (![dict writeToFile:path atomically:NO]) {
		NSLog(@"ERROR SAVING. EMAIL MX@ICJ.ME PLZ. KTHX");
	}
	goto end;
end:{
	[dict release];
	[p drain];
	saving = NO;
	}
	 */
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
