//
//  RCNetwork.h
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import <Foundation/Foundation.h>
#import "RCChannel.h"

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
	NSString *spass;
	NSString *npass;
	NSInputStream *iStream;
	NSOutputStream *oStream;
	RCSocketStatus status;
	int task;
	int port;
	int _scores; // ha. funny. jokes. get it. under_scores. ><
	BOOL isRegistered;
	BOOL useSSL;
	BOOL COL;
	BOOL shouldSave;
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
@property (nonatomic, assign) int port;
@property (nonatomic, assign) BOOL isRegistered;
@property (nonatomic, assign) BOOL useSSL;
@property (nonatomic, assign) BOOL COL;

- (BOOL)connect;
- (BOOL)disconnect;
- (BOOL)isConnected;
- (NSString *)descriptionForComparing;
- (BOOL)sendMessage:(NSString *)msg;
- (void)recievedMessage:(NSString *)msg;
- (void)errorOccured:(NSError *)error;
- (void)setupRooms:(NSArray *)rooms;
- (void)addChannel:(NSString *)_chan join:(BOOL)join;
- (NSString *)connectionStatus;
- (void)handlePING:(NSString *)pong;
- (void)handleCTCPRequest:(NSString *)request;
- (void)parseUsermask:(NSString *)mask nick:(NSString **)nick user:(NSString **)user hostmask:(NSString **)hostmask;
- (id)infoDictionary;
@end
