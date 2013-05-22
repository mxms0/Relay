//
//  RCSocket.m
//  Relay
//
//  Created by Max Shavrick on 5/3/13.
//

#import "RCSocket.h"
#import "RCNetwork.h"
#import "RCNetworkManager.h"

@implementation RCSocket
static id _instance = nil;

SSL_CTX *RCInitContext(void) {
	SSL_METHOD *meth; // lol;
	SSL_CTX *_ctx;
	OpenSSL_add_all_algorithms();
	SSL_load_error_strings();
	meth = (SSL_METHOD *)SSLv23_client_method();
	_ctx = SSL_CTX_new(meth);
	if (_ctx == NULL) {
		// fuck.
		MARK;
		NSLog(@"FUCKKKKK");
		//	ERR_print_errors(stderr);
	}
	return _ctx;
}

char *RCIPForURL(NSString *URL) {
	char *hostname = (char *)[URL UTF8String];
	struct addrinfo hints, *res;
	struct in_addr addr;
	int err;
	memset(&hints, 0, sizeof(hints));
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_family = AF_INET;
	if ((err = getaddrinfo(hostname, NULL, &hints, &res)) != 0) {
		return NULL;
	}
	addr.s_addr = ((struct sockaddr_in *)(res->ai_addr))->sin_addr.s_addr;
	freeaddrinfo(res);
	return inet_ntoa(addr);
}

+ (id)sharedSocket {
	@synchronized(self) {
		if (!_instance) _instance = [[self alloc] init];
		return _instance;
	}
	return nil;
}

- (id)init {
	if ((self = [super init])) {
		_isReading = NO;
		isPolling = NO;
	}
	return self;
}

- (int)connectToAddr:(NSString *)server withSSL:(BOOL)ssl andPort:(int)port fromNetwork:(RCNetwork *)net {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_4_0) {
		task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
			[[UIApplication sharedApplication] endBackgroundTask:task];
			task = UIBackgroundTaskInvalid;
		}];
	}
	NSString *spass = [net spass];
	NSString *nick = [net nick];
	NSString *useNick = nick;
	NSString *realname = nick;
	NSString *username = nick;
	BOOL SASL = [net SASL];
	int sockfd = 0;
	if (ssl) {
		sockfd = 0;
		SSL_library_init();
		SSL_CTX *ctx = RCInitContext();
		net->ctx = ctx;
		struct hostent *host;
		struct sockaddr_in addr;
		if ((host = gethostbyname([server UTF8String])) == NULL) {
			MARK;
			//[self disconnectWithMessage:@"Error obtaining host."];
			[p drain];
			return NO;
		}
		sockfd = socket(PF_INET, SOCK_STREAM, 0);
		int set = 1;
		setsockopt(sockfd, SOL_SOCKET, SO_NOSIGPIPE, (void *)&set, sizeof(int));
		bzero(&addr, sizeof(addr));
		addr.sin_family = AF_INET;
		addr.sin_port = htons(port);
		addr.sin_addr.s_addr = *(long *)(host->h_addr);
		if (connect(sockfd, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
			MARK;
			//[self disconnectWithMessage:@"Error connecting to host."];
			[p drain];
			return NO;
		}
		ssl = SSL_new(ctx);
		SSL_set_fd(ssl, sockfd);
		if (SSL_connect(ssl) == -1) {
			MARK;
			//[self disconnectWithMessage:@"Error connecting with SSL."];
			[p drain];
			return NO;
		}
		int opts = fcntl(sockfd, F_GETFL);
		opts = (opts | O_NONBLOCK);
		if (fcntl(sockfd, F_SETFL, opts) < 0) {
			MARK;
			return -1;
		}
		if (SASL) {
			[net sendMessage:@"CAP LS" canWait:NO];
		}
		if ([spass length] > 0) {
			[net sendMessage:[@"PASS " stringByAppendingString:spass] canWait:NO];
		}
		if (!nick || [nick isEqualToString:@""]) {
			nick = @"__GUEST";
			useNick = @"__GUEST";
		}
		[net sendMessage:[@"USER " stringByAppendingFormat:@"%@ %@ %@ :%@", (username ? username : nick), nick, nick, (realname ? realname : nick)] canWait:NO];
		[net sendMessage:[@"NICK " stringByAppendingString:nick] canWait:NO];
	}
	else {
		struct sockaddr_in serv_addr;
		sockfd = socket(AF_INET, SOCK_STREAM, 0);
		if (sockfd < 0) {
			MARK;
			return -1;
		}
		int set = 1;
		setsockopt(sockfd, SOL_SOCKET, SO_NOSIGPIPE, (void *)&set, sizeof(int));
		memset(&serv_addr, 0, sizeof(serv_addr));
		serv_addr.sin_family = AF_INET;
		serv_addr.sin_port = htons(port);
		char *ip = RCIPForURL(server);
		if (ip == NULL) {
			MARK;
			return -2;
		}
		NSLog(@"hi %@", CFNetworkCopySystemProxySettings());;
		if (inet_pton(AF_INET, ip, &serv_addr.sin_addr) <= 0) {
			MARK;
			return -1;
		}
		if (connect(sockfd, (struct sockaddr *)&serv_addr, sizeof(serv_addr)) < 0) {
			MARK;
			return -1;
		}
		int opts = fcntl(sockfd, F_GETFL);
		opts = (opts | O_NONBLOCK);
		if (fcntl(sockfd, F_SETFL, opts) < 0) {
			MARK;
			return -1;
		}
		if ([spass length] > 0) {
			[net sendMessage:[@"PASS " stringByAppendingString:spass] canWait:NO];
		}
		[net sendMessage:@"CAP LS" canWait:NO];
		if (SASL) {
			//	[self sendMessage:@"CAP REQ :mutli-prefix sasl server-time" canWait:NO];
			[net sendMessage:@"CAP REQ :sasl" canWait:NO];
		}
		else {
			//	[self sendMessage:@"CAP REQ :server-time" canWait:NO];
		}
		if (!nick || [nick isEqualToString:@""]) {
			nick = @"__GUEST";
			useNick = @"__GUEST";
		}
		[net sendMessage:[@"USER " stringByAppendingFormat:@"%@ %@ %@ :%@", (username ? username : nick), nick, nick, (realname ? realname : nick)] canWait:NO];
		[net sendMessage:[@"NICK " stringByAppendingString:nick] canWait:NO];
		[net sendMessage:@"CAP END" canWait:NO];
	}
	[p drain];
	if (!isPolling) {
		[NSThread detachNewThreadSelector:@selector(configureSocketPoll) toTarget:self withObject:nil];
	}
	isPolling = YES;
	return sockfd;
}

- (void)configureSocketPoll {
	[[NSRunLoop currentRunLoop] addTimer:[NSTimer timerWithTimeInterval:1 target:self selector:@selector(pollSockets) userInfo:nil repeats:YES] forMode:NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] run];
}

- (void)pollSockets {
	if (_isReading) {
		return;
	}
	_isReading = YES;
	fd_set rfds, wfds;
	int mfds = 0;
	FD_ZERO(&rfds);
	FD_ZERO(&wfds);
	for (RCNetwork *net in [[RCNetworkManager sharedNetworkManager] networks]) {
		int fd = net->sockfd;
		if (fd == -1) continue;
		FD_SET(fd, &rfds);
		FD_SET(fd, &wfds);
		mfds = MAX(mfds, fd);
	}
	mfds++;
	int sel = select(mfds, &rfds, &wfds, NULL, NULL);
	if (sel == -1) {
		MARK;
		return;
	}
	for (RCNetwork *net in [[RCNetworkManager sharedNetworkManager] networks]) {
		int sockfd = net->sockfd;
		if (sockfd == -1) continue;
		if (FD_ISSET(sockfd, &rfds)) {
			[net read];
		}
		if (FD_ISSET(sockfd, &wfds) && [net hasPendingBites]) {
			[net write];
		}
	}
/*
	for (RCNetwork *net in [[RCNetworkManager sharedNetworkManager] networks]) {
		if (net->sockfd == -1) continue;
		
		char buf[512];
		int fd = 0;
		NSMutableString *cache = [net cache];
		while ((fd = read(net->sockfd, buf, 512)) > 0) {
			NSString *appenddee = [[NSString alloc] initWithBytesNoCopy:buf length:fd encoding:NSUTF8StringEncoding freeWhenDone:NO];
			if (appenddee) {
				[cache appendString:appenddee];
				[appenddee release];
				while (([cache rangeOfString:@"\r\n"].location != NSNotFound)) {
					// should probably use NSCharacterSet, etc etc.
					int loc = [cache rangeOfString:@"\r\n"].location+2;
					NSString *cbuf = [cache substringToIndex:loc];
					[net recievedMessage:cbuf];
					[cache deleteCharactersInRange:NSMakeRange(0, loc)];
				}
			}
		}
	}*/
	_isReading = NO;
}

@end
