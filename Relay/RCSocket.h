//
//  RCSocket.h
//  Relay
//
//  Created by Max Shavrick on 12/23/11.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCSocket : NSObject {
	NSString *_server;
	NSString *_nick;
	NSString *_port;
	NSInputStream *iStream;
	NSOutputStream *oStream;
}
@property (nonatomic, retain, setter = setServer:) NSString *server;

@end
