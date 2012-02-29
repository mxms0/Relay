//
//  RCNetworkManager.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCNetworkManager.h"
#import "RCNavigator.h"

@implementation RCNetworkManager

static id snManager = nil;
static NSMutableArray *networks = nil;

- (void)ircNetworkWithInfo:(NSDictionary *)info {
	RCNetwork *network = [[RCNetwork alloc] init];
	[network setUsername:[info objectForKey:USER_KEY]];
	[network setNick:[info objectForKey:NICK_KEY]];
	[network setRealname:[info objectForKey:NAME_KEY]];
	[network setSpass:[info objectForKey:S_PASS_KEY]];
	[network setNpass:[info objectForKey:N_PASS_KEY]];
	[network setSDescription:[info objectForKey:DESCRIPTION_KEY]];
	[network setServer:[info objectForKey:SERVR_ADDR_KEY]];
	[network setPort:[[info objectForKey:PORT_KEY] intValue]];
	[network setUseSSL:[[info objectForKey:SSL_KEY] boolValue]];
	[network setCOL:[[info objectForKey:COL_KEY] boolValue]];
	
	for (RCNetwork *net in networks) {
		if ([[net descriptionForComparing] isEqualToString:[network descriptionForComparing]]) {
			[network release];
			return;
		}
	}
	NSMutableArray *rooms = [[info objectForKey:CHANNELS_KEY] mutableCopy];
	if (!rooms) rooms = [[NSMutableArray alloc] init];
	[rooms addObject:@"IRC"];
	[network setupRooms:rooms];
	[networks addObject:network];
	[network release];
	[self saveNetworks];
}

+ (void)saveNetworks {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFS_ABSOLUT];
	NSMutableArray *temp = [[NSMutableArray alloc] init];
	for (RCNetwork *net in networks) {
		[temp addObject:[net infoDictionary]];
	}
	[dict setObject:[NSKeyedArchiver archivedDataWithRootObject:temp] forKey:NETS_KEY];
	if (![dict writeToFile:PREFS_ABSOLUT atomically:NO]) {
		// FIX IT
		NSLog(@"Couldn't save...:l");
	}
	[temp release];
	[dict release];
}

- (void)unpack {
	NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFS_ABSOLUT];
	NSArray *nets = [[NSArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:[dict objectForKey:NETS_KEY]]];
	for (NSDictionary *dict in nets) {
		[[RCNetworkManager sharedNetworkManager] ircNetworkWithInfo:dict];
	}
	[nets release];
	[dict release];
	for (RCNetwork *net in [[RCNetworkManager sharedNetworkManager] networks]) {
		[[RCNavigator sharedNavigator] addNetwork:net];
		if ([net COL]) [net connect];
	}
	if ([networks count] == 0) {
		NSLog(@"Shutup NSKeyedUnarchiver.");
		RCWelcomeNetwork *net = [[RCWelcomeNetwork alloc] init];
		[net setSDescription:@"Welcome!"];
		[net setServer:@"irc.nightcoast.net"];
		[net addChannel:@"#Relay" join:YES];
		RCChannel *chan = [[net _channels] objectForKey:@"#Relay"];
		[chan recievedEvent:RCEventTypeTopic from:@"" message:@"Welcome to Relay!"];
		[[chan panel] setHidesEntryField:YES];
		[chan recievedMessage:@"Try out some cool features! :D" from:@"" type:RCMessageTypeAction];
		[chan recievedMessage:@"Blah, Blah, more blah!" from:@"Me" type:RCMessageTypeNormal];
		[[self networks] addObject:net];
		[net release];
		[[RCNavigator sharedNavigator] addNetwork:net];
		[[RCNavigator sharedNavigator] channelSelected:[chan bubble]];
	}
	[[RCNavigator sharedNavigator] scrollViewDidEndDecelerating:nil];
}

- (RCNetwork *)networkWithDescription:(NSString *)_desc {
	for (RCNetwork *net in [self networks]) {
		if ([[net _description] isEqualToString:_desc]) return net;
	}
	return nil;
}

- (void)saveNetworks {
	[[self class] saveNetworks];
}

+ (RCNetworkManager *)sharedNetworkManager {
	@synchronized(self) {
		if (!snManager) snManager = [[self alloc] init];
	}
	return snManager;
}

- (RCNetworkManager *)init {
	if ((self = [super init])) {
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
