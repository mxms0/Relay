//
//  RCSocket.h
//  Relay
//
//  Created by Max Shavrick on 1/16/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface RCSocket : NSObject <NSStreamDelegate> {
	id network;
	int task;
	NSInputStream *iStream;
	NSOutputStream *oStream;
	RCSocketStatus status;
	NSOperationQueue *queue;
	id <RCResponseDelegate> delegate;
}
@property (nonatomic, retain) id <RCResponseDelegate> delegate;
@property (nonatomic, readonly) RCSocketStatus status;
- (id)initWithNetwork:(id)_network;
- (BOOL)_connect;
- (BOOL)_disconnect;
- (BOOL)sendMessage:(NSString *)msg;
- (void)recievedMessage:(NSString *)msg;
- (BOOL)_isConnecting;
- (BOOL)_isConnected;
@end
