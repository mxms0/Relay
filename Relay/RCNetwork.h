//
//  RCNetwork.h
//  Relay
//
//  Created by James Long on 24/12/2011.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCSocket.h"

@interface RCNetwork : NSObject {
	RCSocket *socket;
	NSString *server;
	NSString *description;
	NSString *username;
	NSString *nickname;
	NSString *realname;
	NSString *sPass; //Server Password
	NSString *nPass; // NickServ Password
	int port;
	NSMutableArray *channels;
	BOOL wantsSSL;
}
@property (nonatomic, retain) RCSocket *socket;
@property (nonatomic, retain) NSString *server;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *nickname;
@property (nonatomic, retain) NSString *realname;
@property (nonatomic, retain) NSString *sPass; //Server Password
@property (nonatomic, retain) NSString *nPass; // NickServ Password
@property (nonatomic, assign) int port;
@property (nonatomic, retain) NSMutableArray *channels;
@property (nonatomic, assign) BOOL wantsSSL;

+ (id)createNetworkWithAddress:(NSString *)url port:(int)port wantsSSL:(BOOL)_ssl description:(NSString *)_description withUsername:(NSString *)_username andNickname:(NSString *)_nickName realName:(NSString *)_realName serverPassword:(NSString *)_sPass nickServPass:(NSString *)_nPass;
- (void)connect;
- (void)disconnect;

@end
