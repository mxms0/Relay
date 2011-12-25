//
//  RCSocket.h
//  Relay
//
//  Created by Max Shavrick on 12/23/11.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCResponseParser.h"
#import <objc/runtime.h>

typedef enum RCSocketStatus {
	RCSocketStatusNotOpen,
	RCSocketStatusConnecting,
	RCSocketStatusOpen,
	RCSocketStatusError,
	RCSocketStatuClosed
} RCSocketStatus;

@interface RCSocket : NSObject <NSStreamDelegate> {
	RCResponseParser *parser;
	NSString *server;
	NSString *nick;
    NSString *servPass;
	int port;
	BOOL isRegistered;
	RCSocketStatus status;
	BOOL wantsSSL;
	NSMutableArray *channels;
	NSInputStream *iStream;
	NSOutputStream *oStream;
}
@property (nonatomic, retain) NSString *server;
@property (nonatomic, retain) NSString *nick;
@property (nonatomic, retain) NSString *servPass;
@property (nonatomic, assign) int port;
@property (nonatomic, assign) BOOL wantsSSL;
@property (nonatomic, assign) RCSocketStatus status;
@property (nonatomic, retain) NSMutableArray *channels;
@property (nonatomic, assign) BOOL isRegistered;
- (BOOL)connect;
- (BOOL)disconnect;
- (void)respondToVersion:(NSString *)from;
- (void)messageRecieved:(NSString *)message;
- (void)sendMessage:(NSString *)command;
- (void)channel:(NSString *)chan recievedMessage:(NSString *)msg fromUser:(NSString *)usr;
- (void)addUser:(NSString *)nick toRoom:(NSString *)room;
- (void)addRoom:(NSString *)roomName;
- (BOOL)isConnected;
- (NSArray *)parseString:(NSString *)string;
@end
