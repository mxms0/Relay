//
//  RCChannel.h
//  Relay
//
//  Created by Max Shavrick on 1/23/12.
//

#import <Foundation/Foundation.h>
#import "RCChatPanel.h"
#import "RCAppDelegate.h"
#import "NSString+Comparing.h"
#import "RCChannelBubble.h"

typedef enum RCMessageType {
	RCMessageTypeAction,
	RCMessageTypeNormal,
	RCMessageTypeNotice,
} RCMessageType;

typedef enum RCEventType {
	RCEventTypeKick,
	RCEventTypeBan,
	RCEventTypePart,
	RCEventTypeJoin,
	RCEventTypeTopic
} RCEventType;

@class RCNetwork;
@interface RCChannel : NSObject {
	NSMutableDictionary *users;
	NSString *channelName;
	NSString *lastMessage;
	NSString *topic;
	RCChatPanel *panel;
	BOOL joined;
	BOOL joinOnConnect;
	BOOL shouldUpdate;
	RCNetwork *delegate;
	RCChannelBubble *bubble;
}
@property (nonatomic, retain) NSString *channelName;
@property (nonatomic, retain) NSString *lastMessage;
@property (nonatomic, assign) BOOL joinOnConnect;
@property (nonatomic, retain) RCNetwork *delegate;
@property (nonatomic, readonly) RCChatPanel *panel;
@property (nonatomic, readonly) NSString *topic;
@property (nonatomic, retain) RCChannelBubble *bubble;
- (id)initWithChannelName:(NSString *)_name;
- (void)recievedMessage:(NSString *)message from:(NSString *)from type:(RCMessageType)type;
- (void)recievedEvent:(RCEventType)type from:(NSString *)from message:(NSString *)msg;
- (void)setUserJoined:(NSString *)joined;
- (void)setUserLeft:(NSString *)left;
- (void)setMode:(NSString *)modes forUser:(NSString *)user;
- (void)setJoined:(BOOL)joind withArgument:(NSString *)arg1;
- (void)userWouldLikeToPartakeInThisConversation:(NSString *)message;
// yes, seriously. :P spent like 15 minutes and felt this was best suited. 
- (void)setSuccessfullyJoined:(BOOL)success;
- (void)updateMainTableIfNeccessary;
@end
