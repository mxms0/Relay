//
//  RCNetwork.h
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import <Foundation/Foundation.h>
#import "RCChannel.h"
#import "RCConsoleChannel.h"
#import "RCPMChannel.h"
#import "RCMessage.h"
#import <objc/message.h>
#import "NSString+Utils.h"

typedef NS_ENUM(NSInteger, RCLineType) {
	RCLineGlobal,
	RCLineKill,
	RCLineZap,
	RCLineOperator,
	RCLineQ
};

typedef NS_ENUM(NSInteger, RCConnectionFailure) {
	RCConnectionFailureEstablishingSocket,
	RCConnectionFailureObtainingHost,
	RCConnectionFailureConnecting,
	RCConnectionFailureConnectingViaSSL
};

typedef NS_ENUM(NSInteger, RCSocketStatus) {
	RCSocketStatusClosed = 0,
	RCSocketStatusConnecting,
	RCSocketStatusConnected,
	RCSocketStatusError,
};

@protocol RCChannelDelegate <NSObject>
- (void)channel:(RCChannel *)channel userJoined:(NSString *)user;
- (void)channel:(RCChannel *)channel userParted:(NSString *)user message:(NSString *)message;
- (void)channel:(RCChannel *)channel userKicked:(NSString *)user kicker:(NSString *)kicker reason:(NSString *)message;
- (void)channel:(RCChannel *)channel userBanned:(NSString *)user banner:(NSString *)banner reason:(NSString *)reason;
- (void)channel:(RCChannel *)channel userModeChanged:(NSString *)user modes:(int)modes;
- (void)channel:(RCChannel *)channel receivedMessage:(RCMessage *)message;

@end

@protocol RCNetworkDelegate <NSObject>
- (void)networkConnected:(RCNetwork *)network;
- (void)networkDisconnected:(RCNetwork *)network;
- (void)network:(RCNetwork *)network connectionFailed:(RCConnectionFailure)fail;
- (void)network:(RCNetwork *)network serverSentLine:(RCLineType)lineType;
- (void)network:(RCNetwork *)network receivedNotice:(NSString *)notice user:(NSString *)user;
@optional
- (NSString *)defaultQuitMessageForNetwork:(RCNetwork *)network;
- (void)network:(RCNetwork *)network receivedMOTDMessage:(NSString *)message;
@end

@interface RCNetwork : NSObject
@property (nonatomic, retain) NSDictionary *operatorModes;
@property (nonatomic, readonly) NSMutableOrderedSet *channels; // pls dont mutate
@property (nonatomic, retain) NSString *stringDescription;
@property (nonatomic, retain) NSURL *serverAddress;
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *realname;
@property (nonatomic, retain) NSString *serverPassword;
@property (nonatomic, retain) NSString *nickServPassword;
@property (readonly, retain) NSString *uniqueIdentifier;
@property (nonatomic, assign) uint16_t port;
@property (nonatomic, assign) BOOL useSSL;
@property (nonatomic, assign) BOOL handleMOTD;
@property (nonatomic, readonly, getter=isRegistered) BOOL registered;
@property (nonatomic, readonly, getter=isNetworkOperator) BOOL networkOperator;
@property (nonatomic, assign, getter=isAway, setter=setAway:) BOOL away;
@property (nonatomic, assign) id <RCNetworkDelegate> delegate;
@property (nonatomic, assign) id <RCChannelDelegate> channelDelegate;
@property (nonatomic, copy) void (^channelCreationHandler)(RCChannel *);
@property (nonatomic, retain) NSMutableArray *alternateNicknames;
@property (nonatomic, retain) NSDictionary *numericStringFormatOverride;

- (void)connect;
- (BOOL)disconnect;
- (void)disconnectCleanupWithMessage:(NSString *)msg;
- (BOOL)isConnected;
- (BOOL)isTryingToConnectOrConnected;
- (BOOL)sendMessage:(NSString *)msg;
- (BOOL)sendMessage:(NSString *)msg canWait:(BOOL)canWait;
- (RCChannel *)consoleChannel;
- (RCChannel *)addChannel:(NSString *)_chan join:(BOOL)join;
- (RCPMChannel *)pmChannelWithChannelName:(NSString *)chan;
- (RCChannel *)channelWithChannelName:(NSString *)chan;
- (void)moveChannelAtIndex:(NSUInteger)idx toIndex:(NSUInteger)newIdx;
- (void)removeChannel:(RCChannel *)chan;
- (void)enumerateOverChannelsWithBlock:(void (^)(RCChannel *channel, BOOL *stop))block;
@end

char *RCIPForURL(NSString *URL);
void RCParseUserMask(NSString *mask, NSString **nick, NSString **user, NSString **hostmask);
