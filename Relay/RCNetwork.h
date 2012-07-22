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
#import "RCNavigator.h"
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
#include <ifaddrs.h>

typedef enum RCSocketStatus {
	RCSocketStatusConnecting,
	RCSocketStatusConnected,
	RCSocketStatusError,
	RCSocketStatusClosed
} RCSocketStatus;

@interface RCNetwork : NSObject {
	NSMutableDictionary *_channels;
    NSMutableArray *_nicknames;
	NSMutableArray *_bubbles;
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
	RCSocketStatus status;
	int task;
	int port;
	int maxStatusLength;
	int sockfd;
	BOOL isRegistered;
	BOOL useSSL;
	BOOL COL;
	BOOL shouldSave;
	BOOL canSend;
	BOOL _isDiconnecting;
	BOOL shouldRequestSPass;
	BOOL shouldRequestNPass;
}
@property (nonatomic, retain) NSMutableDictionary *_channels;
@property (nonatomic, retain) NSMutableArray *_nicknames;
@property (nonatomic, readonly) NSMutableArray *_bubbles;
@property (nonatomic, retain) NSString *sDescription;
@property (nonatomic, retain) NSString *server;
@property (nonatomic, retain) NSString *nick;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *realname;
@property (nonatomic, retain) NSString *spass;
@property (nonatomic, retain) NSString *npass;
@property (nonatomic, readonly) NSString *useNick;
@property (nonatomic, retain) NSString *userModes;
@property (nonatomic, assign) int port;
@property (nonatomic, assign) BOOL isRegistered;
@property (nonatomic, assign) BOOL useSSL;
@property (nonatomic, assign) BOOL COL;
@property (nonatomic, assign) BOOL shouldRequestSPass;
@property (nonatomic, assign) BOOL shouldRequestNPass;
- (RCChannel *)channelWithChannelName:(NSString *)chan;
- (NSString *)_description;
- (void)connect;
- (BOOL)disconnect;
- (BOOL)isConnected;
- (BOOL)sendMessage:(NSString *)msg;
- (BOOL)sendMessage:(NSString *)msg canWait:(BOOL)canWait;
- (void)recievedMessage:(NSString *)msg;
- (void)errorOccured:(NSError *)error;
- (void)setupRooms:(NSArray *)rooms;
- (void)addChannel:(NSString *)_chan join:(BOOL)join;
- (void)removeChannel:(RCChannel *)chan;
- (void)handlePING:(NSString *)pong;
- (void)handleCTCPRequest:(NSString *)request;
- (id)infoDictionary;
@end
char *RCIPForURL(NSString *URL);
void RCParseUserMask(NSString *mask, NSString **nick, NSString **user, NSString **hostmask);
@interface CALayer (Haxx)
- (id)_nq:(id)arg1;
@end

