//
//  RCDefaultMessageFormatter.m
//  Relay
//
//  Created by Max Shavrick on 6/10/14
//

#import "RCDefaultMessageFormatter.h"
#import "RCMessage.h"

@implementation RCDefaultMessageFormatter
@synthesize message=_message;

- (instancetype)initWithMessage:(RCMessage *)messageParam {
	if ((self = [super init])) {
		self.message = messageParam;
	}
	return self;
}

- (NSString *)formattedMessage {
	if ([self.message messageType] == RCMessageTypeUnknown) {
		int numeric = [[self.message numeric] intValue];
	
		switch (numeric) {
		
		}
	}
	else {
		switch ([self.message messageType]) {
			case RCMessageTypeKick:
			case RCMessageTypeBan:
			case RCMessageTypePart:
			case RCMessageTypeJoin:
			case RCMessageTypeEvent:
			case RCMessageTypeTopic:
			case RCMessageTypeQuit:
			case RCMessageTypeMode:
			case RCMessageTypeError:
			case RCMessageTypeAction:
				break;
			case RCMessageTypeNormal: {
				NSLog(@"normal msg %@:%@", self.message.sender, self.message.message);
				break;
			}
			case RCMessageTypeNotice:
			case RCMessageTypeUnknown:
			default:
				break;
		}
		// do normal formatting like in RCChannel
	}
	return [NSString stringWithFormat:@"%@ %@", [self.message sender], [self.message message]];
}

//	[self.delegate.channelDelegate channel:self receivedMessage:message from:from time:0];

//	NSString *msg = @"";
//	char uhash = ([from isEqualToString:[delegate nickname]]) ? 1 : RCUserHash(from);
//	BOOL isHighlight = NO;
//	switch (type) {
//		case RCMessageTypeKick: {
//			NSArray *components = (NSArray *)_message;
//			NSString *kickReason = [components objectAtIndex:1];
//			if (![kickReason isEqualToString:@""])
//				kickReason = [NSString stringWithFormat:@" (%@)", kickReason];
//			msg = [NSString stringWithFormat:@"%c%@%c has kicked %c%@%c%@", RCIRCAttributeBold, from, RCIRCAttributeBold, RCIRCAttributeBold, [components objectAtIndex:0], RCIRCAttributeBold, kickReason];
//			from = @"";
//			dispatch_sync(dispatch_get_main_queue(), ^ {
//				[fullUserList removeAllObjects];
//			});
//			break;
//		}
//		case RCMessageTypeBan:
//			msg = [NSString stringWithFormat:@"%c%@%c sets mode %c+b %@%c", RCIRCAttributeBold, from, RCIRCAttributeBold, RCIRCAttributeBold, message, RCIRCAttributeBold];
//			break;
//		case RCMessageTypePart:
//			if (![self isUserInChannel:from]) {
//				return;
//			}
//			if (![message isEqualToString:@""] && !!(msg)) {
//				msg = [NSString stringWithFormat:@"%c%@%c left the channel. (%@)", RCIRCAttributeBold, from, RCIRCAttributeBold, message];
//			}
//			else {
//				msg = [NSString stringWithFormat:@"%c%@%c left the channel.", RCIRCAttributeBold, from, RCIRCAttributeBold];
//			}
//			from = @"";
//			break;
//		case RCMessageTypeJoin:
//			msg = [NSString stringWithFormat:@"%c%@%c joined the channel.", RCIRCAttributeBold, from, RCIRCAttributeBold];
//			from = @"";
//			break;
//		case RCMessageTypeEvent:
//			msg = [NSString stringWithFormat:@"%@%@", from, message];
//			break;
//		case RCMessageTypeTopic:
//			if (from) msg = [[NSString stringWithFormat:@"%@ changed the topic to: %@", from, message] retain];
//			else msg = [message copy];
//			break;
//		case RCMessageTypeQuit:
//			if ([self isUserInChannel:from]) {
//				[self setUserLeft:from];
//				if (![message isEqualToString:@""]) {
//					msg = [NSString stringWithFormat:@"%c%@%c left IRC. (%@)", RCIRCAttributeBold, from, RCIRCAttributeBold, message];
//				}
//				else {
//					msg = [NSString stringWithFormat:@"%c%@%c left IRC.", RCIRCAttributeBold, from, RCIRCAttributeBold];
//				}
//				from = @"";
//			}
//			else {
//				return;
//			}
//			break;
//		case RCMessageTypeMode:
//			msg = [NSString stringWithFormat:@"%@ sets mode %c%@%c", from, RCIRCAttributeBold, message, RCIRCAttributeBold];
//			break;
//		case RCMessageTypeError:
//			msg = message;
//			break;
//		case RCMessageTypeAction:
//			isHighlight = [self performHighlightCheck:&message];
//			msg = [NSString stringWithFormat:@"%c%02d\u2022 %@%c %@", RCIRCAttributeInternalNickname, uhash, from, RCIRCAttributeInternalNickname, message];
//			from = @"";
//			break;
//		case RCMessageTypeNormal:
//			if (from) {
//				isHighlight = [self performHighlightCheck:&message];
//				msg = [NSString stringWithFormat:@"%@", message];
//			}
//			else {
//				type = RCMessageTypeNormalEx;
//			}
//			break;
//		case RCMessageTypeNotice:
//			isHighlight = [self performHighlightCheck:&message];
//			msg = [NSString stringWithFormat:@"-%c%02d%@%c-%@", RCIRCAttributeInternalNickname, uhash, from, RCIRCAttributeInternalNickname, message];
//			from = @"";
//			break;
//		case RCMessageTypeNormalEx:
//			msg = message;
//			break;
//			break;
//		default:
//			msg = @"unk_event";
//			break;
//	}
//	RCMessageFormatter *construct = [[RCMessageFormatter alloc] initWithMessage:msg];
//	[construct formatWithHighlight:isHighlight];
//	[pool addObject:construct];
//	[construct release];
//
//	if (type == RCMessageTypeNormal || type == RCMessageTypeNormalEx || type == RCMessageTypeAction)
//		[self shouldPost:isHighlight withMessage:[NSString stringWithFormat:@"%@: %@", from, RCStripIRCMetadataFromString(msg)]];

- (void)dealloc {
	self.message = nil;
	[super dealloc];
}

@end
