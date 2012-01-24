//
//  RCNetwork.h
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import <Foundation/Foundation.h>
typedef enum RCSocketStatus {
	RCSocketStatusConnecting,
	RCSocketStatusConnected,
	RCSocketStatusError,
	RCSocketStatusNotOpen,
	RCSocketStatusClosed
} RCSocketStatus;

@interface RCNetwork : NSObject <NSStreamDelegate> {
	NSMutableArray *channels;
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
	BOOL isRegistered;
	BOOL useSSL;
	BOOL COL;
}
@property (nonatomic, retain) NSMutableArray *channels;
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
- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;
- (BOOL)sendMessage:(NSString *)msg;
- (void)recievedMessage:(NSString *)msg;
- (void)errorOccured:(NSError *)error;
- (NSString *)connectionStatus;
- (void)handlePING:(NSString *)pong;
- (void)handleCTCPRequest:(NSString *)request;
- (void)parseUsermask:(NSString *)mask nick:(NSString **)nick user:(NSString **)user hostmask:(NSString **)hostmask;
@end
