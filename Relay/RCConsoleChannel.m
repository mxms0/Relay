//
//  RCConsoleChannel.m
//  Relay
//
//  Created by Max Shavrick on 3/2/12.
//

#import "RCConsoleChannel.h"
#import "RCNetwork.h"
#import "NSString+IRCStringSupport.h"

@implementation RCConsoleChannel

- (id)initWithChannelName:(NSString *)_name {
    if ((self = [super initWithChannelName:_name])) {
        joined = YES;
    }
    return self;
}

- (BOOL)joined {
    return YES;
}

- (void)setSuccessfullyJoined:(BOOL)success {
    joined = YES;
}

- (void)userWouldLikeToPartakeInThisConversation:(NSString *)message {
	@autoreleasepool {
		if ([message hasPrefix:@"/"]) {
			[self parseAndHandleSlashCommand:[message substringFromIndex:1]];
			return;
		}
		else {
			[(RCNetwork *)delegate sendMessage:message];
			[self recievedMessage:message from:@"" type:RCMessageTypeNormalE];
		}
	}
}

- (void)recievedMessage:(NSString *)message from:(NSString *)from time:(NSString *)time type:(RCMessageType)type {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	NSString *msg = @"";
	if (!time) time = [[RCDateManager sharedInstance] currentDateAsString];
	message = [[[message stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByEncodingHTMLEntities:YES];
	message = [message stringByReplacingOccurrencesOfString:@"\x04" withString:@""];
	message = [message stringByReplacingOccurrencesOfString:@"\x05" withString:@""];
	from = [from stringByReplacingOccurrencesOfString:@"\x04" withString:@""];
	from = [from stringByReplacingOccurrencesOfString:@"\x05" withString:@""];
	time = [time stringByAppendingString:@" <div></div>"];
	if ([time hasSuffix:@" "])
		time = [time substringToIndex:time.length-1];
	if (type == RCMessageTypeAction) {
		msg = [NSString stringWithFormat:@"%c\u2022 %@%c%@", RCIRCAttributeBold, from, RCIRCAttributeBold, message];
	}
	else if (type == RCMessageTypeNormal) {
		if (from) {
			msg = [NSString stringWithFormat:@"%c%@%c%@", RCIRCAttributeBold, from, RCIRCAttributeBold, message];
		}
		else {
			msg = [NSString stringWithFormat:@" %@", message];
		}
		type = RCMessageTypeNormalE;
	}
	else if (type == RCMessageTypeNotice) {
        msg = [NSString stringWithFormat:@"%c-%@-%c %@", RCIRCAttributeBold, from, RCIRCAttributeBold, message];
	}
	else if (type == RCMessageTypeJoin) {
		msg = @"Someone shouldn't be joining here.. Wat.";
	}
	else {
		[super recievedMessage:message from:from time:time type:type];
		[p drain];
		return;
	}
	msg = [[time stringByAppendingFormat:@"<div class=\"msg\">%@</div>", msg] copy];
	[panel postMessage:[msg autorelease] withType:type highlight:NO];
	[p drain];
	/* if ([delegate isRegistered] && type == RCMessageTypeNormalE) {
	 [cellRepresentation setNewMessageCount:(newMessageCount++)];
	 [cellRepresentation performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
	 } */
	// don't really know how to handle this. it's kind of an awkward situation per-se.
	// don't want the users having a number notifying them of ircd spam always.
	// but don't know how to detect wether or not it's ircd spam or some kind of notification.
	// if the error messages go to the console channel, i mean, this should be easy, but i send them as normal messages
	// since well, this is the console channel.
}

- (void)recievedMessage:(NSString *)message from:(NSString *)from type:(RCMessageType)type {
	NSAutoreleasePool *p = [[NSAutoreleasePool alloc] init];
	NSString *time = [[RCDateManager sharedInstance] currentDateAsString];
	[self recievedMessage:message from:from time:time type:type];
	[p drain];
}

@end
