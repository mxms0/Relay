//
//  RCResponseParser.m
//  Relay
//
//  Created by Max Shavrick on 12/23/11.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import "RCResponseParser.h"
#import "RCSocket.h"

@implementation RCResponseParser
@synthesize delegate;

- (id)init {
	if ((self = [super init])) {
		queue = [[NSOperationQueue alloc] init];
	}
	return self;
}

- (void)messageRecieved:(NSString *)_message {
	if (delegate == nil) return;
	NSLog(@"MSG: %@ ", _message);
	NSScanner *_s = [[NSScanner alloc] initWithString:_message];
	NSString *sender;
	NSString *cmd;
	[_s scanUpToString:@" " intoString:&sender];
	NSLog(@"Sender: %@", sender);
	[_s scanUpToString:@" " intoString:&cmd];
	NSLog(@"CMD: %@",cmd);
	SEL c_call = NSSelectorFromString([NSString stringWithFormat:@"perform%@:", cmd]);
	
	if ([self respondsToSelector:c_call]) {
		NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:c_call object:_message];
		[queue addOperation:operation];
		[operation release];
	}
	else {
		NSLog(@"Hax: %@ %@", NSStringFromSelector(c_call), _message);
	}
	[_s release];
}

- (void)performJOIN:(NSString *)join {
	NSLog(@"SHOULD BE JOINING SOME FUCKER %@",join);
	join = [join substringWithRange:NSMakeRange(1, join.length-1)];
	[delegate addRoom:join];
}

- (void)perform001:(NSString *)reg {
	@autoreleasepool {
		NSLog(@"Registered.");
	}
}

- (void)performPRIVMSG:(NSString *)privmsg {
	NSLog(@"Yay! %@", privmsg);
	NSScanner *_scan = [[NSScanner alloc] initWithString:privmsg];
	[_scan setScanLocation:(int)[privmsg hasPrefix:@":"]];
	NSString *sender = nil;
	NSString *command = nil;
	NSString *argument = nil;
    [_scan scanUpToString:@" " intoString:&sender];
    [_scan scanUpToString:@" " intoString:&command];
	[_scan scanUpToString:@"\r\n" intoString:&argument];
	[_scan release];
	_scan = nil;
	_scan = [[NSScanner alloc] initWithString:argument];
	NSString *nick = nil;
	NSString *user = nil;
	NSString *hostmask = nil;
	NSString *channel = nil;
	NSString *message = nil;
	[self parseHostmask:sender intoNick:&nick intoUser:&user intoHostmask:&hostmask];
	[_scan scanUpToString:@" " intoString:&channel];
//	if (argument.length <= _scan.scanLocation+2)
//		[_scan setScanLocation:_scan.scanLocation+2];
//	else NSLog(@"0.o.. idk what to do here....");
	[_scan setScanLocation:_scan.scanLocation+2];
	[_scan scanUpToString:@"" intoString:&message];
	if ([message hasPrefix:@"\x01"] && [message hasSuffix:@"\x01"]) {
		NSLog(@"WWEEEEEEEEEEE");
		NSString *command = nil;
		NSString *argument = nil;
		[_scan release];
		_scan = nil;
		_scan = [[NSScanner alloc] initWithString:message];
		[_scan setScanLocation:1];
		[_scan scanUpToString:@"\x01" intoString:&command];
		if ([command hasSuffix:@"\x01"]) {
			[_scan setScanLocation:1];
			[_scan scanUpToString:@"\x01" intoString:&command];
		}
		[_scan scanUpToString:@"\x01" intoString:&argument];
		if ([command isEqualToString:@"ACTION"]) {
			NSLog(@"wahhhhhhhh?");
			NSLog(@"Action Recieved From:%@ with:%@", nick, argument);
		}
		else if ([command isEqualToString:@"VERSION"]) {
			[delegate sendMessage:[@"NOTICE " stringByAppendingFormat:@"%@ :\x01Relay 1.0\x01\r\n", nick]];
		}
	}
}

- (void)perform005:(NSString *)infos {
	
}

- (void)perform422:(NSString *)MODT {
	@autoreleasepool {
		NSLog(@"MOTD. DON'T WANT. <3");
	}
}

- (void)parseHostmask:(NSString *)mask intoNick:(NSString **)nick intoUser:(NSString **)user intoHostmask:(NSString **)hostmask {
	if (nick) *nick = nil;
	if (user) *user = nil;
    if (hostmask) *hostmask = nil;
	NSScanner *scan = [NSScanner scannerWithString:mask];
	[scan scanUpToString:@"!" intoString:nick];
	if ([scan isAtEnd]) return;
	[scan setScanLocation:((int)[scan scanLocation])+1];
	[scan scanUpToString:@"@" intoString:user];
	[scan setScanLocation:((int)[scan scanLocation])+1];
	if ([scan isAtEnd]) return;
	[scan scanUpToString:@"" intoString:hostmask];
}

- (void)dealloc {
	[super dealloc];
	[queue release];
}

@end
