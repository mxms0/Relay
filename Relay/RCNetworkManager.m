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
	RCKeychainItem *wrapper = nil;
	if ([[info objectForKey:S_PASS_KEY] boolValue]) {
		wrapper = [[RCKeychainItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%@spass", [network _description]] accessGroup:@"us.mxms.relay"];
		[network setSpass:([wrapper objectForKey:S_PASS_KEY] ?: @"")];
		[wrapper release];
		wrapper = nil;
	}
	if ([[info objectForKey:N_PASS_KEY] boolValue]) {
		wrapper = [[RCKeychainItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%@npass", [network _description]]  accessGroup:@"us.mxms.relay"];
		[network setNpass:([wrapper objectForKey:N_PASS_KEY] ?: @"")];
		[wrapper release];
		wrapper = nil;
	}

	NSMutableArray *rooms = [[[info objectForKey:CHANNELS_KEY] mutableCopy] autorelease];
	if (!rooms) rooms = [[NSMutableArray alloc] init];
	if (![rooms containsObject:@"IRC"]) [rooms addObject:@"IRC"];
	[network setupRooms:rooms];
	[networks addObject:network];
	[[RCNavigator sharedNavigator] addNetwork:network];
	[self performSelectorInBackground:@selector(finishSetupForNetwork:) withObject:network];
	[network release];
	[self performSelectorInBackground:@selector(saveNetworks) withObject:nil];
}

- (void)addNetwork:(RCNetwork *)_net {
	for (RCNetwork *net in networks) {
		if ([[net _description] isEqualToString:[_net _description]]) {
			return;
		}
	}
	if (![[_net channels] containsObject:@"IRC"]) [[_net channels] addObject:@"IRC"];
	[networks addObject:_net];
	[[RCNavigator sharedNavigator] addNetwork:_net];
	if ([_net COL]) [_net connect];
	[self saveNetworks];
}

- (void)finishSetupForNetwork:(RCNetwork *)net {
	if ([net COL]) [net performSelectorOnMainThread:@selector(connect) withObject:nil waitUntilDone:NO];
}

- (void)removeNet:(RCNetwork *)net {
	[networks removeObject:net];
	if ([networks count] == 0) {
		[self setupWelcomeView];
	}
	[self saveChannelData:nil];
}

- (void)unpack {
	_printMotd = NO;
	@autoreleasepool {
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFS_ABSOLUT];
		if (!dict) return;
		if ([[dict allKeys] count] == 0) {
			[self setupWelcomeView];
			[dict release];
			return;
		}
		for (NSString *_net in [dict allKeys]) {
			NSDictionary *_info = [dict objectForKey:_net];
			[self ircNetworkWithInfo:_info isNew:NO];
		}
	}
}

- (void)setupWelcomeView {
	RCWelcomeNetwork *net = [[RCWelcomeNetwork alloc] init];
	[net setSDescription:@"Welcome!"];	
	[net setServer:@"irc.nightcoast.net"];
	[net addChannel:@"#Relay" join:YES];
	RCChannel *chan = [[net _channels] objectForKey:@"#Relay"];
	[chan recievedEvent:RCEventTypeTopic from:@"" message:@"Welcome to Relay!"];
	[[chan panel] setHidesEntryField:YES];
	[chan recievedMessage:@"Try out some cool features! :D" from:@"" type:RCMessageTypeNormal];
	[chan recievedMessage:@"Blah, Blah, more blah!" from:@"" type:RCMessageTypeNormal];
	[[self networks] addObject:net];
	[[RCNavigator sharedNavigator] addNetwork:net];
	[[RCNavigator sharedNavigator] channelSelected:[chan bubble]];
	[[RCNavigator sharedNavigator] scrollViewDidEndDecelerating:nil];
	[net release];
}

- (RCNetwork *)networkWithDescription:(NSString *)_desc {
	for (RCNetwork *net in networks) {
		if ([[net _description] isEqualToString:_desc]) return net;
	}
	return nil;
}

- (void)saveNetworks {
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:PREFS_PLIST] ?: [NSMutableDictionary dictionary];
	for (RCNetwork *net in networks) {
		[dict setObject:[net infoDictionary] forKey:[net _description]];
	}
	if (![dict writeToFile:PREFS_ABSOLUT atomically:NO]) {
		// FIX IT
		NSLog(@"Couldn't save...:l");
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
}

- (void)saveChannelData:(id)unused {
	if (saving) return;
	[self performSelectorInBackground:@selector(_reallySaveChannelData:) withObject:unused];
}

- (RCNetwork *)networkAtIndex:(int)_index {
	for (RCNetwork *net in networks) {
		if ([net index] == _index)
			return net;
	}
	return nil;
}

- (RCNetwork *)networkWithQuickDescription:(NSString *)_descr {
	for (RCNetwork *net in networks) {
		if ([[net descriptionForComparing] isEqualToString:_descr])
			return net;
	}
	return nil;
}

- (void)_reallySaveChannelData:(id)unused {
	saving = YES;
	NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingString:NETS_PLIST];
	NSUInteger hashCode = 00000;
	NSDictionary *_dict = [[NSDictionary alloc] initWithContentsOfFile:path];
	if (_dict) hashCode = (unsigned int)[[_dict objectForKey:@"0_UNSIGNEDHASH"] intValue];
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
	for (RCNetwork *net in networks) {
		NSMutableDictionary *netDict = [[NSMutableDictionary alloc] init];
		for (NSString *_chan in [net channels]) {
			RCChannel *chan = [[net _channels] objectForKey:_chan];
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
