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
#include "openssl/ssl.h"
#include "openssl/err.h"
#import "NSString+Utils.h"

#undef LOGALL
#define LOGALL 1

typedef NS_ENUM(NSInteger, RCLineType) {
	RCLineGlobal,
	RCLineKill,
	RCLineZap,
	RCLineOperator,
	RClineQ
};

typedef NS_ENUM(NSInteger, RCConnectionFailure) {
	RCConnectionFailureEstablishingSocket,
	RCConnectionFailureObtainingHost,
	RCConnectionFailureConnecting,
	RCConnectionFailureConnectingViaSSL
};

@protocol RCChannelDelegate <NSObject>
- (void)channel:(RCChannel *)channel userJoined:(NSString *)user;
- (void)channel:(RCChannel *)channel userParted:(NSString *)user;
- (void)channel:(RCChannel *)channel userKicked:(NSString *)user;
- (void)channel:(RCChannel *)channel userBanned:(NSString *)user;
- (void)channel:(RCChannel *)channel userModeChanged:(NSString *)user modes:(int)modes;
- (void)channel:(RCChannel *)channel receivedMessage:(RCMessage *)message from:(NSString *)from time:(time_t)time;

@end

@protocol RCNetworkDelegate <NSObject>
- (void)networkConnected:(RCNetwork *)network;
- (void)networkDisconnected:(RCNetwork *)network;
- (void)network:(RCNetwork *)network connectionFailed:(RCConnectionFailure)fail;
- (void)network:(RCNetwork *)network serverSentLine:(RCLineType)lineType;

@end

typedef enum RCSocketStatus {
	RCSocketStatusConnecting,
	RCSocketStatusConnected,
	RCSocketStatusError,
	RCSocketStatusClosed
} RCSocketStatus;

@interface RCNetwork : NSObject <UIAlertViewDelegate> {
	NSMutableArray *_channels;
	NSMutableArray *tmpChannels;
	NSMutableArray *_nicknames;
	NSString *sDescription;
	NSString *server;
	NSString *nick;
	NSString *username;
	NSString *realname;
	NSString *useNick;
	NSString *spass;
	NSString *npass;
	NSString *uUID;
	NSMutableString *writebuf;
	NSMutableData *rcache;
	NSArray *connectCommands;
	SSL_CTX *ctx;
	SSL *ssl;
	RCSocketStatus status;
	NSTimer *disconnectTimer;
	int port;
	int sockfd;
	BOOL saslWasSuccessful;
	BOOL isRegistered;
	BOOL useSSL;
	BOOL canSend;
	BOOL expanded;
	BOOL shouldRequestSPass;
	BOOL shouldRequestNPass;
	BOOL isWriting;
	BOOL isOper;
    BOOL isAway;
	BOOL tagged;
	id listCallback;
	dispatch_source_t readSource;
	dispatch_source_t writeSource;
	
	NSDictionary *prefix;
}
@property (nonatomic, retain) NSDictionary *prefix;
@property (nonatomic, readonly) NSMutableArray *channels;
@property (nonatomic, readonly) NSMutableArray *_nicknames;
@property (nonatomic, retain) NSString *sDescription;
@property (nonatomic, retain) NSString *server;
@property (nonatomic, retain) NSString *nick;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *realname;
@property (nonatomic, retain) NSString *spass;
@property (nonatomic, retain) NSString *npass;
@property (nonatomic, retain) NSString *useNick;
@property (nonatomic, retain) NSString *uUID;
@property (nonatomic, retain) NSArray *connectCommands;
@property (nonatomic, assign) int port;
@property (nonatomic, assign) BOOL isRegistered;
@property (nonatomic, assign) BOOL useSSL;
@property (nonatomic, assign) BOOL shouldRequestSPass;
@property (nonatomic, assign) BOOL shouldRequestNPass;
@property (nonatomic, assign) id listCallback;
@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, assign) BOOL isOper;
@property (nonatomic, assign) BOOL isAway;
@property (nonatomic, assign) BOOL tagged;
@property (nonatomic, assign) id <RCNetworkDelegate> delegate;
@property (nonatomic, assign) id <RCChannelDelegate> channelDelegate;
+ (RCNetwork *)networkWithInfoDictionary:(NSDictionary *)dict;
- (RCNetwork *)uniqueCopy;
- (RCChannel *)channelWithChannelName:(NSString *)chan;
- (NSString *)_description;
- (void)performCopyoverWithNetwork:(RCNetwork *)net;
- (void)connect;
- (BOOL)disconnect;
- (void)disconnectCleanupWithMessage:(NSString *)msg;
- (RCChannel *)consoleChannel;
- (BOOL)isConnected;
- (void)connectOrDisconnectDependingOnCurrentStatus;
- (BOOL)sendMessage:(NSString *)msg;
- (BOOL)sendMessage:(NSString *)msg canWait:(BOOL)canWait;
- (void)recievedMessage:(NSString *)msg;
- (void)errorOccured:(NSError *)error;
- (void)_setupChannels:(NSArray *)rooms;
- (void)setupRooms:(NSArray *)rooms;
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
- (NSDictionary *)infoDictionary;
- (void)savePasswords;
@end

SSL_CTX *RCInitContext(void);
char *RCIPForURL(NSString *URL);
void RCParseUserMask(NSString *mask, NSString **nick, NSString **user, NSString **hostmask);
