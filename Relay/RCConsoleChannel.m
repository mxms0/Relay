//
//  RCConsoleChannel.m
//  Relay
//
//  Created by Max Shavrick on 3/2/12.
//

#import "RCConsoleChannel.h"
#import "RCChatView.h"
#import "RCNetwork.h"

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

- (void)recievedMessage:(NSString *)message from:(NSString *)from type:(RCMessageType)type {
	NSString *msg = @"";
    NSString *time = @"";
	time = [[RCDateManager sharedInstance] currentDateAsString];
	if ([time hasSuffix:@" "])
		time = [time substringToIndex:time.length-1];
			//msg = [[NSString stringWithFormat:@"%c[%@]%c %@ sets mode +b %@",RCIRCAttributeBold, time, RCIRCAttributeBold, from, message] retain];
	if (type == RCMessageTypeAction) {
		msg = [[NSString stringWithFormat:@"%c[%@] \u2022 %@%c %@", RCIRCAttributeBold, time, from, RCIRCAttributeBold, message] retain];
	}
	else if (type == RCMessageTypeNormal) {
		if (from) {
			msg = [[NSString stringWithFormat:@"%c[%@]%@%c: %@", RCIRCAttributeBold, time, from, RCIRCAttributeBold, message] retain];
		}
		else {
			msg = [[NSString stringWithFormat:@"%c[%@]%c %@", RCIRCAttributeBold, time, RCIRCAttributeBold, message] retain];
		}
		type = RCMessageTypeNormalE;
	}
	else if (type == RCMessageTypeNotice) {
        msg = [[NSString stringWithFormat:@"%c[%@] -%@-%c %@", RCIRCAttributeBold, time, from, RCIRCAttributeBold, message] retain];
	}
	else if (type == RCMessageTypeJoin) {
		//	msg = [@"iPhone joined the channel." retain];
		// wat
		msg = [@"Wat." retain];
	}
	else {
		[super recievedMessage:message from:from type:type];
		return;
	}
	[panel postMessage:[msg autorelease] withType:type highlight:NO];
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

@end