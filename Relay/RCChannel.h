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
#import "RCUserListPanel.h"
#import "RCUserTableCell.h"

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
	RCEventTypeTopic,
	RCEventTypeQuit,
	RCEventTypeMode,
} RCEventType;

@class RCNetwork;
@class RCNavigator;
@interface RCChannel : NSObject <UITableViewDelegate, UITableViewDataSource> {
	NSMutableDictionary *users;
	NSString *channelName;
	NSString *topic;
	RCChatPanel *panel;
	RCUserListPanel *usersPanel;
	BOOL joined;
	BOOL joinOnConnect;
	BOOL shouldUpdate;
	RCNetwork *delegate;
	RCChannelBubble *bubble;
}
@property (nonatomic, retain) NSString *channelName;
@property (nonatomic, assign) BOOL joinOnConnect;
@property (nonatomic, retain) RCNetwork *delegate;
@property (nonatomic, assign) RCChatPanel *panel;
@property (nonatomic, readonly) NSString *topic;
@property (nonatomic, retain) RCChannelBubble *bubble;
@property (nonatomic, retain) RCUserListPanel *usersPanel;
- (id)initWithChannelName:(NSString *)_name;
- (void)recievedMessage:(NSString *)message from:(NSString *)from type:(RCMessageType)type;
- (void)recievedEvent:(RCEventType)type from:(NSString *)from message:(NSString *)msg;
- (void)setUserJoined:(NSString *)joined;
- (void)setUserLeft:(NSString *)left;
- (void)setMode:(NSString *)modes forUser:(NSString *)user;
- (void)setJoined:(BOOL)joind withArgument:(NSString *)arg1;
- (void)userWouldLikeToPartakeInThisConversation:(NSString *)message;
- (void)peopleParticipateInConversationsNotPartake:(id)hai wtfWasIThinking:(BOOL)thinking;
- (void)parseAndHandleSlashCommand:(NSString *)cmd;
- (NSString *)userWithPrefix:(NSString *)prefix pastUser:(NSString *)user;
// yes, seriously. :P spent like 15 minutes and felt this was best suited. 
- (void)setSuccessfullyJoined:(BOOL)success;
NSString *RCUserRank(NSString *user);
UIImage *RCImageForRank(NSString *rank);
UIImage *RCImageForRanks(NSString *ranks, NSString *possible);
NSString *RCMergeModes(NSString *arg1, NSString *arg2);
NSString *RCSymbolRepresentationForModes(NSString *modes);
NSString *RCSterilizeModes(NSString *modes);
BOOL RCIsRankHigher(NSString *rank, NSString *rank2);
@end
