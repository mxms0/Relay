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
#import "RCSocket.h"
#import "TestFlight.h"
#import "ISO8601DateFormatter.h"

@class RCChannelManager;
typedef enum RCSocketStatus {
	RCSocketStatusConnecting,
	RCSocketStatusConnected,
	RCSocketStatusError,
	RCSocketStatusClosed
} RCSocketStatus;

@interface RCNetwork : NSObject <UIAlertViewDelegate> {
	@public
	NSMutableArray *_channels;
	NSMutableArray *_nicknames;
	NSString *sDescription;
	NSString *server;
	NSString *nick;
	NSString *username;
	NSString *realname;
	NSString *useNick;
	NSString *spass;
	NSString *npass;
	NSString *userModes;
	NSString *uUID;
	NSMutableString *cache;
	NSMutableString *writebuf;
	NSMutableData *rcache;
	SSL_CTX *ctx;
	SSL *ssl;
	RCSocketStatus status;
	NSTimer *disconnectTimer;
	int task;
	int port;
	int sockfd;
	int dcCount;
	BOOL isRegistered;
	BOOL useSSL;
	BOOL COL;
	BOOL shouldSave;
	BOOL canSend;
	BOOL SASL;
	BOOL _selected;
	BOOL expanded;
	BOOL _isDisconnecting;
	BOOL shouldRequestSPass;
	BOOL shouldRequestNPass;
	BOOL isWriting;
	BOOL isOper;
    BOOL isAway;
	id listCallback;
	NSDictionary *prefix;
}
@property (nonatomic, retain) NSDictionary *prefix;
@property (nonatomic, readonly) NSMutableArray *_channels;
@property (nonatomic, readonly) NSMutableArray *_nicknames;
@property (nonatomic, retain) NSString *sDescription;
@property (nonatomic, retain) NSString *server;
@property (nonatomic, retain) NSString *nick;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *realname;
@property (nonatomic, retain) NSString *spass;
@property (nonatomic, retain) NSString *npass;
@property (nonatomic, retain) NSString *useNick;
@property (nonatomic, retain) NSString *userModes;
@property (nonatomic, retain) NSString *uUID;
@property (nonatomic, readonly) NSMutableString *cache;
@property (nonatomic, assign) int port;
@property (nonatomic, assign) BOOL isRegistered;
@property (nonatomic, assign) BOOL useSSL;
@property (nonatomic, assign) BOOL COL;
@property (nonatomic, assign) BOOL SASL;
@property (nonatomic, assign) BOOL shouldRequestSPass;
@property (nonatomic, assign) BOOL shouldRequestNPass;
@property (nonatomic, assign) id listCallback;
@property (nonatomic, assign) BOOL _selected;
@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, assign) BOOL isOper;
@property (nonatomic, assign) BOOL isAway;
+ (RCNetwork *)networkWithInfoDictionary:(NSDictionary *)dict;
- (RCChannel *)channelWithChannelName:(NSString *)chan;
- (NSString *)_description;
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
- (RCChannel *)addChannel:(NSString *)_chan join:(BOOL)join;
- (void)removeChannel:(RCChannel *)chan;
- (void)handlePING:(id)pong;
- (void)handleCTCPRequest:(NSString *)request from:(NSString *)from;
- (BOOL)isTryingToConnectOrConnected;
- (NSString *)defaultQuitMessage;
- (BOOL)read;
- (BOOL)write;
- (BOOL)hasPendingBites; //nom
- (id)infoDictionary;
- (void)savePasswords;
@end

SSL_CTX *RCInitContext(void);
char *RCIPForURL(NSString *URL);
void RCParseUserMask(NSString *mask, NSString **nick, NSString **user, NSString **hostmask);
