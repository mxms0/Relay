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
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <netdb.h>
#include <time.h>
#include <resolv.h>
#include <netdb.h>
#include "openssl/ssl.h"
#include "openssl/err.h"
#include <ifaddrs.h>
#import "TestFlight.h"

@class RCChannelManager;
typedef enum RCSocketStatus {
	RCSocketStatusConnecting,
	RCSocketStatusConnected,
	RCSocketStatusError,
	RCSocketStatusClosed
} RCSocketStatus;

@interface RCNetwork : NSObject <UIAlertViewDelegate> {
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
	NSMutableString *sendQueue;
	SSL_CTX *ctx;
	SSL *ssl;
	RCSocketStatus status;
	int task;
	int port;
	int sockfd;
	BOOL isRegistered;
	BOOL useSSL;
	BOOL COL;
	BOOL shouldSave;
	BOOL canSend;
	BOOL SASL;
	BOOL _selected;
	BOOL expanded;
	BOOL _isDiconnecting;
	BOOL shouldRequestSPass;
	BOOL shouldRequestNPass;
	RCChannelManager *namesCallback;
    BOOL tryingToConnect;
    NSDictionary *prefix;
}
@property (nonatomic, retain) NSDictionary* prefix;
@property (nonatomic, retain) NSMutableArray *_channels;
@property (nonatomic, retain) NSMutableArray *_nicknames;
@property (nonatomic, retain) NSString *sDescription;
@property (nonatomic, retain) NSString *server;
@property (nonatomic, retain) NSString *nick;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *realname;
@property (nonatomic, retain) NSString *spass;
@property (nonatomic, retain) NSString *npass;
@property (nonatomic, retain) NSString *useNick;
@property (nonatomic, retain) NSString *userModes;
@property (nonatomic, assign) int port;
@property (nonatomic, assign) BOOL isRegistered;
@property (nonatomic, assign) BOOL useSSL;
@property (nonatomic, assign) BOOL COL;
@property (nonatomic, assign) BOOL SASL;
@property (nonatomic, assign) BOOL shouldRequestSPass;
@property (nonatomic, assign) BOOL shouldRequestNPass;
@property (nonatomic, assign) RCChannelManager *namesCallback;
@property (nonatomic, assign) BOOL _selected;
@property (nonatomic, assign) BOOL expanded;
+ (RCNetwork *)networkWithInfoDictionary:(NSDictionary *)dict;
- (RCChannel *)channelWithChannelName:(NSString *)chan;
- (NSString *)_description;
- (void)connect;
- (BOOL)disconnect;
- (RCChannel *)consoleChannel;
- (BOOL)isConnected;
- (void)connectOrDisconnectDependingOnCurrentStatus;
- (BOOL)sendMessage:(NSString *)msg;
- (BOOL)sendMessage:(NSString *)msg canWait:(BOOL)canWait;
- (void)recievedMessage:(NSString *)msg;
- (void)errorOccured:(NSError *)error;
- (void)_setupRooms:(NSArray *)rooms;
- (void)setupRooms:(NSArray *)rooms;
- (RCChannel *)addChannel:(NSString *)_chan join:(BOOL)join;
- (void)removeChannel:(RCChannel *)chan;
- (void)handlePING:(NSString *)pong;
- (void)handleCTCPRequest:(NSString *)request;
- (BOOL)isTryingToConnectOrConnected;
- (NSString *)defaultQuitMessage;
- (id)infoDictionary;
@end
SSL_CTX *RCInitContext(void);
char *RCIPForURL(NSString *URL);
void RCParseUserMask(NSString *mask, NSString **nick, NSString **user, NSString **hostmask);
@interface CALayer (Haxx)
- (id)_nq:(id)arg1;
@end

