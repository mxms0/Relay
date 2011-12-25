//
//  RCNetwork.m
//  Relay
//
//  Created by James Long on 24/12/2011.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import "RCNetwork.h"

@implementation RCNetwork

@synthesize server, description, username, nickname, realname, sPass, nPass, port, channels, wantsSSL, socket;

+ (id)createNetworkWithAddress:(NSString *)url port:(int)port wantsSSL:(BOOL)_ssl description:(NSString *)_description withUsername:(NSString *)_username andNickname:(NSString *)_nickName realName:(NSString *)_realName serverPassword:(NSString *)_sPass nickServPass:(NSString *)_nPass {
	RCNetwork *net = [[self alloc] init];
	[net setServer:url];
	[net setPort:port];
	[net setWantsSSL:_ssl];
	[net setDescription:(_description ? _description : url)];
	[net setUsername:_username];
	[net setNickname:_nickName];
	[net setRealname:_realName];
	[net setSPass:_sPass];
	[net setNPass:_nPass];
	return net;
}

- (void)connect {
	if (!socket) {
		socket = [[RCSocket alloc] init];
		[socket setNick:nickname];
		[socket setServer:server];
		[socket setPort:port];
		[socket setWantsSSL:wantsSSL];
		[socket setServPass:sPass];
		[socket connect];
	}
	else {
		if ([socket status] == RCSocketStatusConnecting || [socket status] == RCSocketStatusOpen)
			return;
		[socket disconnect];
	}
}
- (void)disconnect {
	[socket disconnect];
}

- (void)dealloc {
	[super dealloc];
	[server release];
	server = nil;
	[description release];
	description = nil;
	[username release];
	username = nil;
	[nickname release];
	nickname = nil;
	[realname release];
	realname = nil;
	[sPass release];
	sPass = nil;
	[nPass release];
	nPass = nil;
	[channels release];
	channels = nil;
	if ([socket isConnected])
		[socket disconnect];
	[socket release];
	socket = nil;
}

@end
