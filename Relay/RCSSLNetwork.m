//
//  RCSSLNetwork.m
//  Relay
//
//  Created by Max Shavrick on 7/29/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCSSLNetwork.h"

@implementation RCSSLNetwork

SSL_CTX *initContext(void) {
	SSL_METHOD *meth; // lol;
	SSL_CTX *_ctx;
	OpenSSL_add_all_algorithms();
	SSL_load_error_strings();
	meth = (SSL_METHOD *)SSLv23_client_method();
	_ctx = SSL_CTX_new(meth);
	if (_ctx == NULL) {
		// fuck.
		//	ERR_print_errors(stderr);
	}
	return _ctx;
	
}

- (void)_connect {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	canSend = YES;
	isRegistered = NO;
	if (sendQueue) [sendQueue release];
	sendQueue = nil;
	if (status == RCSocketStatusConnecting) return;
	if (status == RCSocketStatusConnected) return;;
	useNick = nick;
	self.userModes = @"~&@%+";
	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_4_0) {
		task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
			[[UIApplication sharedApplication] endBackgroundTask:task];
			task = UIBackgroundTaskInvalid;
		}];
	}
	RCChannel *chan = [_channels objectForKey:@"IRC"];
	if (chan) [chan recievedMessage:[NSString stringWithFormat:@"Connecting to %@ on port %d", server, port] from:@"" type:RCMessageTypeNormal];
	status = RCSocketStatusConnecting;
	char buff[512];
	int fd = 0;
	SSL_library_init();
	ctx = initContext();
	struct hostent *host;
	struct sockaddr_in addr;
	if ((host = gethostbyname([server UTF8String])) == NULL) {
		// fuckme
		perror([server UTF8String]);
	}
	sockfd = socket(PF_INET, SOCK_STREAM, 0);
	bzero(&addr, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);
	addr.sin_addr.s_addr = *(long *)(host->h_addr);
	if (connect(sockfd, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
		// fuckyou
		// close(sockfd)
		// aborttttt !!!
	}
	ssl = SSL_new(ctx);
	SSL_set_fd(ssl, sockfd);
	if ((SSL_connect(ssl) == -1)) {
		// fuck you !!!
		ERR_print_errors_fp(stderr);
		// cleanup
		[p drain];
		status = RCSocketStatusError;
		return;
	}
	if ([spass length] > 0) {
		[self sendMessage:[@"PASS " stringByAppendingString:spass] canWait:NO];
	}
	[self sendMessage:[@"USER " stringByAppendingFormat:@"%@ %@ %@ :%@", (username ? username : nick), nick, nick, (realname ? realname : nick)] canWait:NO];
	[self sendMessage:[@"NICK " stringByAppendingString:nick] canWait:NO];
	while ((fd = SSL_read(ssl, buff, sizeof(buff))) > 0) {
		buff[fd] = 0;
		NSMutableString *msg = [[NSMutableString alloc] initWithCString:(const char *)buff encoding:NSUTF8StringEncoding];
		while ([msg rangeOfString:@"\r\n"].location != NSNotFound) {
			if ([msg isEqualToString:@"\r\n"] || [msg isEqualToString:@""] || msg == nil) break;
			if ([msg rangeOfString:@"\r\n"].location == NSNotFound) break;
			// i guess i really have to.
			NSString *send = [[NSString alloc] initWithString:[msg substringWithRange:NSMakeRange(0, [msg rangeOfString:@"\r\n"].location+2)]];
#if LOGALL
			NSLog(@"MESSAGE: %@", send);
#endif
			[self recievedMessage:send];
			[send release];
			send = nil;
			if ([msg respondsToSelector:@selector(deleteCharactersInRange:)]) {
				if ([msg rangeOfString:@"\r\n"].location != NSNotFound) {
					@try {
						[msg deleteCharactersInRange:NSMakeRange(0, [msg rangeOfString:@"\r\n"].location+2)];
					}
					@catch (NSException *e) { }
				}
			}
			else {
				msg = [msg mutableCopy];
				// meh. i know i'm going to regret this.
				// so. so. so. much.
				// for some reason, data is becoming an NSString for one reason or another,
				// i'm honestly not sure if it's becoming the actual send var;
				// or just some random string.
				// i honestly just want to bail out here, but i cannot simply trash the data unless its not existant.
				// also tempted to send this stuff to testflight. but do not want app crashing after multitasking
				// because testflight sucks ass.
			}
		}
		[msg release];
		msg = nil;
		usleep(30);

		
	}
	[p drain];

}

- (BOOL)sendMessage:(NSString *)msg canWait:(BOOL)canWait {
	if ((!canWait) || isRegistered) {
		msg = [msg stringByAppendingString:@"\r\n"];
		if (canSend) {
			if (SSL_write(ssl, [msg UTF8String], strlen([msg UTF8String])) < 0) {
				NSLog(@"fuckerdd !! ");
				return NO;
			}
			else {
				// success! :D
				return YES;
			}
		}
	}
	// this whole sendqueue shit needs to be cleaned up majorly.
	NSLog(@"Adding to queue... %@:%d:%d",msg, (int)canWait, (int)isRegistered);
	if (!sendQueue) sendQueue = [[NSMutableString alloc] init];
	[sendQueue appendFormat:@"%@\r\n", msg];
	return NO;
}

- (BOOL)disconnect {
	if (_isDiconnecting) return NO;
	_isDiconnecting = YES;
	if (status == RCSocketStatusClosed) return NO;
	if ((status == RCSocketStatusConnected) || (status == RCSocketStatusConnecting)) {
		[self sendMessage:@"QUIT :Relay 1.0"];
		status = RCSocketStatusClosed;
		if (sendQueue) [sendQueue release];
		sendQueue = nil;
		close(sockfd);
		[[UIApplication sharedApplication] endBackgroundTask:task];
		task = UIBackgroundTaskInvalid;
		status = RCSocketStatusClosed;
		isRegistered = NO;
		SSL_CTX_free(ctx);
		for (NSString *chan in [_channels allKeys]) {
			RCChannel *_chan = [self channelWithChannelName:chan];
			[_chan setMyselfParted];
		}
		NSLog(@"Disconnected.");
	}
	_isDiconnecting = NO;
	return YES;	
	

}

@end
