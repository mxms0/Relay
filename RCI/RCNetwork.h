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

@protocol RCChannelDelegate <NSObject>
- (void)channel:(RCChannel *)channel userJoined:(NSString *)user;
- (void)channel:(RCChannel *)channel userParted:(NSString *)user message:(NSString *)message;
- (void)channel:(RCChannel *)channel userKicked:(NSString *)user reason:(NSString *)message;
- (void)channel:(RCChannel *)channel userBanned:(NSString *)user reason:(NSString *)reason;
- (void)channel:(RCChannel *)channel userModeChanged:(NSString *)user modes:(int)modes;
- (void)channel:(RCChannel *)channel receivedMessage:(RCMessage *)message;

@end

@protocol RCNetworkDelegate <NSObject>
- (void)networkConnected:(RCNetwork *)network;
- (void)networkDisconnected:(RCNetwork *)network;
- (void)network:(RCNetwork *)network connectionFailed:(RCConnectionFailure)fail;
- (void)network:(RCNetwork *)network serverSentLine:(RCLineType)lineType;
- (void)network:(RCNetwork *)network receivedNotice:(NSString *)notice user:(NSString *)user;

@end

typedef enum RCSocketStatus {
	RCSocketStatusConnecting,
	RCSocketStatusConnected,
	RCSocketStatusError,
	RCSocketStatusClosed
} RCSocketStatus;

@interface RCNetwork : NSObject
@property (nonatomic, retain) NSDictionary *prefixes;
@property (nonatomic, readonly) NSMutableArray *channels;
@property (nonatomic, retain) NSString *stringDescription;
@property (nonatomic, retain) NSString *serverAddress;
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *realname;
@property (nonatomic, retain) NSString *serverPassword;
@property (nonatomic, retain) NSString *nickServPassword;
@property (nonatomic, retain) NSString *uUID;
@property (nonatomic, retain) NSArray *connectCommands;
@property (nonatomic, assign) uint16_t port;
@property (atomic, assign) BOOL isRegistered;

@property (nonatomic, assign) id listCallback;
@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, assign) BOOL isOper;
@property (nonatomic, assign) BOOL isAway;
@property (nonatomic, assign) id <RCNetworkDelegate> delegate;
@property (nonatomic, assign) id <RCChannelDelegate> channelDelegate;
@property (nonatomic, copy) void (^channelCreationHandler)(RCChannel *);
// Settings go here
@property (nonatomic, readonly) NSMutableArray *alternateNicknames;
@property (nonatomic, assign) BOOL useSSL;
@property (nonatomic, assign) BOOL handleMOTD;


- (RCNetwork *)uniqueCopy;
- (RCChannel *)channelWithChannelName:(NSString *)chan;
- (void)createConsoleChannel;
- (void)connect;
- (BOOL)disconnect;
- (void)disconnectCleanupWithMessage:(NSString *)msg;
- (RCChannel *)consoleChannel;
- (BOOL)isConnected;
- (BOOL)sendMessage:(NSString *)msg;
- (BOOL)sendMessage:(NSString *)msg canWait:(BOOL)canWait;
- (void)receivedMessage:(NSString *)msg;
- (void)moveChannelAtIndex:(int)idx toIndex:(int)newIdx;
- (RCChannel *)addChannel:(NSString *)_chan join:(BOOL)join;
- (RCPMChannel *)pmChannelWithChannelName:(NSString *)chan;
- (RCChannel *)addTemporaryChannelListingIfItDoesntAlreadyExist:(NSString *)_chan;
- (void)removeChannel:(RCChannel *)chan;
- (void)handlePING:(id)pong;
- (void)handleCTCPRequest:(NSString *)request from:(NSString *)from;
- (BOOL)isTryingToConnectOrConnected;
- (NSString *)defaultQuitMessage;
- (BOOL)read;
- (BOOL)write;
- (BOOL)hasPendingBites; //nom
@end

char *RCIPForURL(NSString *URL);
void RCParseUserMask(NSString *mask, NSString **nick, NSString **user, NSString **hostmask);
