//
//  RANetworkManager.h
//  Relay IRC
//
//  Created by Max Shavrick on 7/20/15.
//  Copyright (c) 2015 Mxms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCNetwork.h"

@interface RANetworkManager : NSObject {
	BOOL isBG;
	BOOL saving;
	BOOL isSetup;
}
@property (nonatomic, assign) BOOL isBG;
@property (nonatomic, readonly) BOOL isSettingUp;
+ (instancetype)sharedNetworkManager;
//- (RCNetwork *)networkWithDescription:(NSString *)_desc;
//- (void)ircNetworkWithInfo:(NSDictionary *)info isNew:(BOOL)n;
//- (BOOL)replaceNetwork:(RCNetwork *)net withNetwork:(RCNetwork *)net;
//- (void)jumpToFirstNetworkAndConsole;
//- (void)receivedMemoryWarning;
//- (void)dispatchChanges;
- (void)addNetwork:(RCNetwork *)net;
//- (void)saveSettingsDictionary:(NSDictionary *)dict dispatchChanges:(BOOL)n;
//- (NSDictionary *)settingsDictionary;
//- (id)valueForSetting:(NSString *)set;
//- (void)setValue:(id)val forSetting:(NSString *)set;
//- (NSString *)networkPreferencesPath;
- (NSMutableArray *)networks;
//- (void)removeNet:(RCNetwork *)net;
//- (void)saveNetworks;
- (void)unpack;
//- (void)connectAll;
//- (void)disconnectAll;
//- (void)setupWelcomeView;
//- (void)setAway:(BOOL)aw;
@end
