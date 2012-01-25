//
//  RCNetworkManager.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCNetworkManager.h"

@implementation RCNetworkManager

static id snManager = nil;
static NSMutableArray *networks = nil;

+ (void)ircNetworkWithInfo:(NSDictionary *)info {
	(void)[[self class] sharedNetworkManager];
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
	[network setTitles:[info objectForKey:CHANNELS_KEY]];
	
	for (RCNetwork *net in [[RCNetworkManager sharedNetworkManager] networks]) {
		if ([[net descriptionForComparing] isEqualToString:[network descriptionForComparing]]) {
			[network release];
			return;
		}
	}
	// if it passes, then setup to not waste memory.
	[network setupRooms:[info objectForKey:CHANNELS_KEY]];
	[networks addObject:network];
	[[self sharedNetworkManager] saveNetworks];
	[network release];
}

+ (void)saveNetworks {
	[[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:networks] forKey:NETS_KEY];
}

- (void)saveNetworks {
	[[self class] saveNetworks];
}

+ (RCNetworkManager *)sharedNetworkManager {
	if (!snManager)
		snManager = [[self alloc] init];
	NSLog(@"Singletonloading.. %@", snManager);
	return snManager;
}

- (RCNetworkManager *)init {
	if ((self = [super init])) {
		if ([[NSUserDefaults standardUserDefaults] objectForKey:NETS_KEY])
			networks = [[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:NETS_KEY]] mutableCopy];
		else networks = [[NSMutableArray alloc] init];
	}
	snManager = self;
	return snManager;
}

- (NSMutableArray *)networks {
	if (!networks)
		networks = [[NSMutableArray alloc] init];
	return networks;
}

- (void)dealloc {
	[networks release];
	networks = nil;
	[super dealloc];
}

@end
