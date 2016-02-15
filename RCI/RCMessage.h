//
//  RCMessage.h
//  Relay
//
//  Created by Max Shavrick on 7/18/13.
//	no correlation to RCMessageFormatter

#import <Foundation/Foundation.h>

typedef enum RCMessageType {
	RCMessageTypeAction = 0,
	RCMessageTypeNormal,
	RCMessageTypeNotice,
	RCMessageTypeKick,
	RCMessageTypeBan,
	RCMessageTypePart,
	RCMessageTypeJoin,
	RCMessageTypeTopic,
	RCMessageTypeQuit,
	RCMessageTypeMode,
	RCMessageTypeError,
	RCMessageTypeEvent,
	RCMessageTypeUnknown
} RCMessageType;

@interface RCMessage : NSObject {
	NSString *_numeric;
	NSString *_sender;
	NSString *_destination;
	NSString *_message;
}
@property (nonatomic, retain) NSString *numeric;
@property (nonatomic, retain) NSString *sender;
@property (nonatomic, retain) NSString *destination;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, assign) RCMessageType messageType;
// message is the segment after the ":" character
@property (nonatomic, retain) NSDictionary *messageTags;
- (id)initWithString:(NSString *)string;
- (void)parse;
- (NSString *)parameterAtIndex:(int)index;
@end
