//
//  RCNetworkManager.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCNetworkManager.h"
#import "RCNavigator.h"

@implementation RCNetworkManager
@synthesize isBG;
static id snManager = nil;
static NSMutableArray *networks = nil;

- (void)ircNetworkWithInfo:(NSDictionary *)info isNew:(BOOL)n {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
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
	if (![rooms containsObject:@"IRC"]) [rooms addObject:@"IRC"];
	[network setupRooms:rooms];
	[p drain];
	[networks addObject:network];
	[[RCNavigator sharedNavigator] addNetwork:network];
	[network release];
	if (n) [self saveNetworks];

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
	@autoreleasepool {
		NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:PREFS_ABSOLUT];
		if (!dict) return;
		if ([dict objectForKey:NETS_KEY]) {
			NSArray *nets = [[NSArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:[dict objectForKey:NETS_KEY]]];
			for (NSDictionary *dict in nets) {
				[[RCNetworkManager sharedNetworkManager] ircNetworkWithInfo:dict isNew:NO];
			}
			[nets release];
			return;
		}
		[dict release];
		NSLog(@"Shutup NSKeyedUnarchiver.");
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
		[net release];
		[[RCNavigator sharedNavigator] addNetwork:net];
		[[RCNavigator sharedNavigator] channelSelected:[chan bubble]];
		[[RCNavigator sharedNavigator] scrollViewDidEndDecelerating:nil];
	}
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
		isBG = NO;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setIsBackgrounding:) name:BG_NOTIF object:nil];
	}
	snManager = self;
	return snManager;
}

- (void)setIsBackgrounding:(BOOL)notif {
	isBG = (BOOL)notif;
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
