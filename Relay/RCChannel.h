//
//  RCChannel.h
//  Relay
//
//  Created by Max Shavrick on 1/23/12.
//

#import <Foundation/Foundation.h>

typedef enum RCMessageType {
	RCMessageTypeAction,
	RCMessageTypeNormal,
	RCMessageTypeNotice,
} RCMessageType;

typedef enum RCEventType {
	RCEventTypeKick,
	RCEventTypeBan,
	RCEventTypePart,
	RCEventTypeJoin
} RCEventType;

@class RCNetwork;
@interface RCChannel : NSObject {
	NSMutableDictionary *users;
	NSString *channelName;
	NSString *lastMessage;
	BOOL joined;
	BOOL joinOnConnect;
	RCNetwork *delegate;
}
@property (nonatomic, retain) NSString *channelName;
@property (nonatomic, retain) NSString *lastMessage;
@property (nonatomic, assign) BOOL joinOnConnect;
@property (nonatomic, retain) RCNetwork *delegate;
- (void)recievedMessage:(NSString *)message from:(NSString *)from type:(RCMessageType)type;
- (void)recievedEvent:(RCEventType)type from:(NSString *)from message:(NSString *)msg;
- (void)setUserJoined:(NSString *)joined;
- (void)setUserLeft:(NSString *)left;
- (void)setMode:(NSString *)modes forUser:(NSString *)user;
- (void)setJoined:(BOOL)joind withArgument:(NSString *)arg1;
@end
