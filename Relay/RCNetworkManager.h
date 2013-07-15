//
//  RCNetworkManager.h
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import <Foundation/Foundation.h>
#import "RCNetwork.h"
#import "RCKeychainItem.h"
#import "RCPasswordRequestAlert.h"

@interface RCNetworkManager : NSObject {
	BOOL isBG;
	BOOL saving;
	BOOL isSetup;
}
@property (nonatomic, assign) BOOL isBG;
+ (RCNetworkManager *)sharedNetworkManager;
- (RCNetwork *)networkWithDescription:(NSString *)_desc;
- (void)ircNetworkWithInfo:(NSDictionary *)info isNew:(BOOL)n;
- (BOOL)replaceNetwork:(RCNetwork *)net withNetwork:(RCNetwork *)net;
- (void)jumpToFirstNetworkAndConsole;
- (void)addNetwork:(RCNetwork *)net;
- (NSString *)networkPreferencesPath;
- (NSMutableArray *)networks;
- (void)removeNet:(RCNetwork *)net;
- (void)saveNetworks;
- (void)unpack;
- (void)setupWelcomeView;
@end
