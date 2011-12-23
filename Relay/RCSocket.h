//
//  RCSocket.h
//  Relay
//
//  Created by Max Shavrick on 12/23/11.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCSocket : NSObject <NSStreamDelegate> {
	NSString *server;
	NSString *nick;
	int port;
	BOOL wantsSSL;
	NSInputStream *iStream;
	NSOutputStream *oStream;
}
@property (nonatomic, retain) NSString *server;
@property (nonatomic, retain) NSString *nick;
@property (nonatomic, assign) int port;
@property (nonatomic, assign) BOOL wantsSSL;
- (BOOL)connect;
@end
