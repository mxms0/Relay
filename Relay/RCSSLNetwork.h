//
//  RCSSLNetwork.h
//  Relay
//
//  Created by Max Shavrick on 7/29/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCnetwork.h"
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>
#include <sys/socket.h>
#include <resolv.h>
#include <netdb.h>
#include "openssl/ssl.h"
#include "openssl/err.h"

SSL_CTX *initContext(void);

@interface RCSSLNetwork : RCNetwork {
	SSL_CTX *ctx;
	SSL *ssl;
}

@end
