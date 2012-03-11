//
//  RCNetwork.h
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import <Foundation/Foundation.h>
#import "RCChannel.h"
#import "RCConsoleChannel.h"
#import "RCNavigator.h"

typedef enum RCSocketStatus {
	RCSocketStatusConnecting,
	RCSocketStatusConnected,
	RCSocketStatusError,
	RCSocketStatusNotOpen,
	RCSocketStatusClosed
} RCSocketStatus;

@interface RCNetwork : NSObject <NSStreamDelegate> {
	NSMutableArray *channels;
	NSMutableDictionary *_channels;
	NSString *sDescription;
	NSString *server;
	NSString *nick;
	NSString *username;
	NSString *realname;
	NSString *useNick;
	NSString *spass;
	NSString *npass;
	NSInputStream *iStream;
	NSOutputStream *oStream;
	NSMutableString *sendQueue;
	RCSocketStatus status;
	int task;
	int port;
	int index;
	int _scores; // ha. funny. jokes. get it. under_scores. >< 
	/* _scores isn't actually used anymore.. */
	BOOL isRegistered;
	BOOL useSSL;
	BOOL COL;
	BOOL shouldSave;
	BOOL canSend;
}
@property (nonatomic, retain) NSMutableArray *channels;
@property (nonatomic, retain) NSMutableDictionary *_channels;
@property (nonatomic, retain) NSString *sDescription;
@property (nonatomic, retain) NSString *server;
@property (nonatomic, retain) NSString *nick;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *realname;
@property (nonatomic, retain) NSString *spass;
@property (nonatomic, retain) NSString *npass;
@property (nonatomic, readonly) NSString *useNick;
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
