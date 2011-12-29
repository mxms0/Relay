//
//  RCNetwork.m
//  Relay
//
//  Created by James Long on 24/12/2011.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import "RCNetwork.h"
#import "RCNetworkManager.h"

@implementation RCNetwork

@synthesize server, sDescription, username, nickname, realname, sPass, nPass, port, channels, wantsSSL, socket;

+ (id)createNetworkWithAddress:(NSString *)url port:(int)port wantsSSL:(BOOL)_ssl description:(NSString *)_description withUsername:(NSString *)_username andNickname:(NSString *)_nickName realName:(NSString *)_realName serverPassword:(NSString *)_sPass nickServPass:(NSString *)_nPass {
	RCNetwork *net = [[self alloc] init];
	[net setServer:url];
	[net setPort:port];
	[net setWantsSSL:_ssl];
	[net setSDescription:(_description ? _description : url)];
	[net setUsername:_username];
	[net setNickname:_nickName];
	[net setRealname:_realName];
	[net setSPass:_sPass];
	[net setNPass:_nPass];
	return net;
}

- (void)joinRoom:(NSString *)room {
	if (!channels) channels = [[NSMutableArray alloc] init];
	if (![channels containsObject:room]) {
		[channels addObject:room];
		[socket addRoom:room];
		[[RCNetworkManager sharedNetworkManager] saveNetworks];
	}
}	

- (BOOL)isConnected {
	return [socket isConnected];
}

- (NSString *)connectionStatus {
	if ([socket status] == RCSocketStatusOpen) 
		return @"Connected";
	else if ([socket status] == RCSocketStatuClosed)
		return @"Disconnected";
	else if ([socket status] == RCSocketStatusConnecting)
		return @"Connected";
	else if ([socket status] == RCSocketStatusError)
		return @"Could not connect...";
	else return @"Disconnected";
}

- (id)initWithCoder:(NSCoder *)coder {
	if ((self = [super init])) {
		NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
		if ([coder containsValueForKey:@"SERVER"])
			[self setServer:[coder decodeObjectForKey:@"SERVER"]];
		if ([coder containsValueForKey:@"DESCRIPTION"])
			[self setSDescription:[coder decodeObjectForKey:@"DESCRIPTION"]];
		if ([coder containsValueForKey:@"PORT"])
			[self setPort:[[coder decodeObjectForKey:@"PORT"] intValue]];
		if ([coder containsValueForKey:@"WANTS_SSL"])
			[self setWantsSSL:[[coder decodeObjectForKey:@"WANTS_SSL"] boolValue]];
		if ([coder containsValueForKey:@"USERNAME"])
			[self setUsername:[coder decodeObjectForKey:@"USERNAME"]];
		if ([coder containsValueForKey:@"NICK_NAME"]) 
			[self setNickname:[coder decodeObjectForKey:@"NICK_NAME"]];
		if ([coder containsValueForKey:@"REAL_NAME"])
			[self setRealname:[coder decodeObjectForKey:@"REAL_NAME"]];
		if ([coder containsValueForKey:@"SERVER_PASS"])
			[self setSPass:[coder decodeObjectForKey:@"SERVER_PASS"]];
		if ([coder containsValueForKey:@"N_SERV_PASS"])
			[self setNPass:[coder decodeObjectForKey:@"N_SERV_PASS"]];
		if ([coder containsValueForKey:@"CHANNELS"])
			[self setChannels:[coder decodeObjectForKey:@"CHANNELS"]];
		else 
			[self setChannels:[[NSMutableArray alloc] init]];
		
		[pool drain];
	}
	return self;
}

- (id)description {
	return [NSString stringWithFormat:@"<%@: %p; server = %@; description = %@; username = %@; channels = %@;>", NSStringFromClass([self class]), self, server, sDescription, username, channels];
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:server forKey:@"SERVER"];
	[coder encodeObject:sDescription forKey:@"DESCRIPTION"];
	[coder encodeObject:[NSNumber numberWithInt:port] forKey:@"PORT"];
	[coder encodeObject:[NSNumber numberWithBool:wantsSSL] forKey:@"WANTS_SSL"];
	[coder encodeObject:username forKey:@"USERNAME"];
	[coder encodeObject:nickname forKey:@"NICK_NAME"];
	[coder encodeObject:realname forKey:@"REAL_NAME"];
	[coder encodeObject:sPass forKey:@"SERVER_PASS"];
	[coder encodeObject:nPass forKey:@"N_SERV_PASS"];
	[coder encodeObject:channels forKey:@"CHANNELS"];
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
	[sDescription release];
	sDescription = nil;
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
