//
//  RCSocket.h
//  Relay
//
//  Created by Max Shavrick on 5/3/13.
//

#import <Foundation/Foundation.h>
#include <netdb.h>
#include "openssl/ssl.h"
#include "openssl/err.h"
#include <sys/ioctl.h>
#import <dispatch/dispatch.h>

typedef enum RCSocketStatus {
	RCSocketStatusConnecting,
	RCSocketStatusConnected,
	RCSocketStatusError,
	RCSocketStatusClosed
} RCSocketStatus;

@class RCNetwork;
@interface RCSocket : NSObject {
	float interval;
	NSTimer *tv;
	BOOL _isReading;
	BOOL isPolling;
}
+ (id)sharedSocket;
- (int)connectToAddr:(NSString *)server withSSL:(BOOL)ssl andPort:(int)port fromNetwork:(RCNetwork *)net;
inline SSL_CTX *RCInitContext(void);
@end
