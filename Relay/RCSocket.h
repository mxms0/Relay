//
//  RCSocket.h
//  Relay
//
//  Created by Max Shavrick on 3/11/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <sys/un.h>
#import <arpa/inet.h>
#import <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#import "RCNetwork.h"

@class RCSocket;
@protocol RCSocketDelegate 
- (void)socket:(RCSocket *)sock recievedString:(NSString *)string;
@end

@interface RCSocket : NSObject {
	RCNetwork <RCSocketDelegate> *delegate;
}
@property (nonatomic, assign) RCNetwork <RCSocketDelegate> *delegate;
- (BOOL)connect;
@end