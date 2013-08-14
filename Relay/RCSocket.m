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
		MARK;
		NSLog(@"Error allocating SSL context.");
		//	ERR_print_errors(stderr);
	}
	return _ctx;
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
		interval = 0.8;
		[[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryStateDidChange:) name:UIDeviceBatteryStateDidChangeNotification object:[UIDevice currentDevice]];
	}
	return self;
}

- (int)connectToAddr:(NSString *)server withSSL:(BOOL)_ssl andPort:(int)port fromNetwork:(RCNetwork *)net {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
#if LOGALL
	NSLog(@"System Proxy Settings: {{%@}};", CFNetworkCopySystemProxySettings());
#endif
	if (kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iPhoneOS_4_0) {
		task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
			[[UIApplication sharedApplication] endBackgroundTask:task];
			task = UIBackgroundTaskInvalid;
		}];
	}
	int sockfd = 0;
	struct hostent *host;
	struct sockaddr_in addr;
	if ((host = gethostbyname([server UTF8String])) == NULL) {
		[net disconnectCleanupWithMessage:@"Error obtaining host."];
		// ERROR OBTAINING HOST
		[p drain];
		return -1;
	}
	sockfd = socket(PF_INET, SOCK_STREAM, 0);
	if (sockfd < 0) {
		[net disconnectCleanupWithMessage:@"Error establishing socket."];
		// ERROR ESTABLISHING SOCKET(?)
		[p drain];
		return -1;
	}
	int set = 1;
	setsockopt(sockfd, SOL_SOCKET, SO_NOSIGPIPE, (void *)&set, sizeof(int));
	bzero(&addr, sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);
	addr.sin_addr.s_addr = *(long *)(host ->h_addr);
	if (connect(sockfd, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
		[net disconnectCleanupWithMessage:@"Error connecting."];
		// ERROR CONNECTING
		return -1;
	}
	if (_ssl) {
		SSL_library_init();
		SSL_CTX *ctx = RCInitContext();
		net->ctx = ctx;
		net->ssl = SSL_new(ctx);
		SSL_set_fd(net->ssl, sockfd);
		if (SSL_connect(net->ssl) == -1) {
			// ERROR CONNECTING ..
			[net disconnectCleanupWithMessage:@"Error connecting via SSL."];
			[p drain];
			return -1;
		}
	}
	
	int opts = fcntl(sockfd, F_GETFL);
	opts = (opts | O_NONBLOCK);
	if (fcntl(sockfd, F_SETFL, opts) < 0) {
		MARK;
		return -1;
	}
	[p drain];
	if (!isPolling) {
		[NSThread detachNewThreadSelector:@selector(configureSocketPoll) toTarget:self withObject:nil];
		isPolling = YES;
	}
	return sockfd;
}

- (void)configureSocketPoll {
#if TARGET_IPHONE_SIMULATOR
	interval = 0.1;
#endif
	tv = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(pollSockets) userInfo:nil repeats:YES];
	[[NSRunLoop currentRunLoop] addTimer:tv forMode:NSDefaultRunLoopMode];
	[[NSRunLoop currentRunLoop] run];
}

- (void)batteryStateDidChange:(NSNotification *)noti {
	UIDevice *device = [UIDevice currentDevice];
	if ([device batteryState] == UIDeviceBatteryStateCharging) {
		interval = 0.2;
	}
	else if ([device batteryState] == UIDeviceBatteryStateUnplugged) {
		interval = 0.8;
	}
	[tv invalidate];
	tv = nil;
	[self configureSocketPoll];
	NSLog(@"Changing poll speed.. %f", interval);
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
	int c = 0;
	for (RCNetwork *net in [[RCNetworkManager sharedNetworkManager] networks]) {
		int fd = net->sockfd;
		if (fd > -1) {
			c++;
			FD_SET(fd, &rfds);
			FD_SET(fd, &wfds);
		}
		mfds = MAX(mfds, fd);
	}
	if (c == 0) {
		_isReading = NO;
		[tv invalidate];
		tv = nil;
		isPolling = NO;
		return;
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
	_isReading = NO;
}

@end
