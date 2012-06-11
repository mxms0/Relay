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
	RCSocketStatusNotOpen,
	RCSocketStatusClosed
} RCSocketStatus;

@interface RCNetwork : NSObject <NSStreamDelegate> {
	NSMutableDictionary *_channels;
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
	NSInputStream *iStream;
	NSOutputStream *oStream;
	NSMutableString *sendQueue;
	RCSocketStatus status;
	BOOL isReading:1;
	int task;
	int port;
	int index;
	int maxStatusLength;
	int sockfd;
	BOOL isRegistered:1;
	BOOL useSSL:1;
	BOOL COL:1;
	BOOL shouldSave:1;
	BOOL canSend:1;
	BOOL _isDiconnecting:1;
}
@property (nonatomic, retain) NSMutableDictionary *_channels;
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
@property (nonatomic, assign) int index;

- (NSString *)_description;
- (BOOL)connect;
- (BOOL)disconnect;
- (BOOL)isConnected;
- (NSString *)descriptionForComparing;
- (BOOL)sendMessage:(NSString *)msg;
- (BOOL)sendMessage:(NSString *)msg canWait:(BOOL)canWait;
- (void)recievedMessage:(NSString *)msg;
- (void)errorOccured:(NSError *)error;
- (void)setupRooms:(NSArray *)rooms;
- (void)addChannel:(NSString *)_chan join:(BOOL)join;
- (void)removeChannel:(RCChannel *)chan;
- (NSString *)connectionStatus;
- (void)handlePING:(NSString *)pong;
- (void)handleCTCPRequest:(NSString *)request;
- (void)parseUsermask:(NSString *)mask nick:(NSString **)nick user:(NSString **)user hostmask:(NSString **)hostmask;
- (id)infoDictionary;
@end
char *ipForURL(NSString *URL);
@interface CALayer (Haxx)
- (id)_nq:(id)arg1;
@end

