//
//  RCSocket.m
//  Relay
//
//  Created by Max Shavrick on 12/23/11.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import "RCSocket.h"

@implementation RCSocket
@synthesize server, nick, port, wantsSSL, srvpass;

- (BOOL)connect {
	CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)server, port ? port : 6667, (CFReadStreamRef *)&iStream, (CFWriteStreamRef *)&oStream);
	[iStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[oStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[iStream setDelegate:self];
	[oStream setDelegate:self];
	if ([iStream streamStatus] == NSStreamStatusNotOpen)
		[iStream open];
	if ([oStream streamStatus] == NSStreamStatusNotOpen)
		[oStream open];
	if (wantsSSL) {
		[iStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
		[oStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
		NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], kCFStreamSSLAllowsExpiredCertificates,
								  [NSNumber numberWithBool:YES], kCFStreamSSLAllowsAnyRoot, [NSNumber numberWithBool:NO], 
								  kCFStreamSSLValidatesCertificateChain, kCFNull, kCFStreamSSLPeerName, nil];
		CFReadStreamSetProperty((CFReadStreamRef)iStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
		CFWriteStreamSetProperty((CFWriteStreamRef)oStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
		[settings release];
	}
    
    if (srvpass)
        [self sendMessage:[NSString stringWithFormat:@"PASS %@", srvpass]];
    
    [self sendMessage:@"USER ac3xx ac3xx ac3xx ac3xx"];
    [self sendMessage:@"NICK ac3xx-lolcake"];
    
	return YES;
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    uint8_t buffer[1024];
    long len;
    switch (eventCode) {
        case NSStreamEventHasBytesAvailable:
            
            while ([iStream hasBytesAvailable]) {
                len = [iStream read:buffer maxLength:sizeof(buffer)];
                if (len > 0) {
                    
                    NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding]; 
                    NSLog(@"%@", output);
                    if (output != nil) {
                        NSArray *msg = [self parseString:output];
                        NSString *antispoof = nil;
                        [[NSScanner scannerWithString:[msg objectAtIndex:0]] scanUpToString:@"!" intoString:&antispoof];
                        if ([[msg objectAtIndex:0] isEqualToString:@"PING"]) {
                            [self sendMessage:[@"PONG " stringByAppendingString:[msg objectAtIndex:1]]];
                        } else if([[msg objectAtIndex:1] isEqualToString:@"PRIVMSG"] && [[msg objectAtIndex:0] isEqualToString:antispoof]) {
                            [self sendMessage:[@"NOTICE " stringByAppendingString:[msg objectAtIndex:1]]];
                        }
                    }
                }
            }
            
            break;
            
        default:
            break;
    }
}

- (NSArray*)parseString:(NSString*)string {
    NSScanner* scan=[NSScanner scannerWithString:string];
    if([string hasPrefix:@":"]) {
        [scan setScanLocation:1];
    }
    NSString *sender = nil;
    
    NSString *command = nil;
    NSString *argument = nil;
    
    [scan scanUpToString:@" " intoString:&sender];
    [scan scanUpToString:@" " intoString:&command];
    [scan scanUpToString:@"\r\n" intoString:&argument];
    return [NSArray arrayWithObjects:sender, command, argument, nil];
}

- (void)sendMessage:(NSString*)command{
    NSString *msg  = [NSString stringWithFormat:@"%@\r\n", command];
    NSData *msgdata = [[NSData alloc] initWithData:[msg dataUsingEncoding:NSASCIIStringEncoding]];
    [oStream write:[msgdata bytes] maxLength:[msgdata length]];
}

- (void)dealloc {
	[super dealloc];
	[server release];
	[nick release];
	[iStream release];
	[oStream release];
}

@end
