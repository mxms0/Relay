//
//  RCMessage.m
//  Relay
//
//  Created by Max Shavrick on 2/20/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCMessageFormatter.h"
#import "NSString+IRCStringSupport.h"
@implementation RCMessageFormatter
@synthesize string;
- (id)initWithMessage:(NSString *)_message isOld:(BOOL)old isMine:(BOOL)m isHighlight:(BOOL)hh type:(RCMessageType)_flavor {
	if (![_message hasSuffix:@"\n"])
		_message = [_message stringByAppendingString:@"\n"];
	switch (_flavor) {
		case RCMessageTypeAction:
            self.string = [@"ACTION-" stringByAppendingString:_message];
            goto isMnt;
			break;
		case RCMessageTypeNormal:
            self.string = [@"NORMAL-" stringByAppendingString:_message];
            goto isMnt;
			break;
		case RCMessageTypeNotice:
            self.string = [@"NOTICE-" stringByAppendingString:_message];
            goto isMnt;
			break;
		case RCMessageTypeTopic:
            self.string = [@"TOPIC-" stringByAppendingString:_message];
			break;
		case RCMessageTypeJoin:
            self.string = [@"JOIN-" stringByAppendingString:_message];
			break;
		case RCMessageTypePart:
            self.string = [@"PART-" stringByAppendingString:_message];
			break;
		case RCMessageTypeNormalE:
            self.string = [@"EXCEPTION-" stringByAppendingString:_message];
			break;
        default:
            break;
	}
out_:
	return self;
isMnt:
    if (hh) {
        [self setString:[@"H:" stringByAppendingString:[self string]]];
    }
    goto out_;
}

- (void)dealloc {
    [self setString:nil];
	[super dealloc];
}
@end
