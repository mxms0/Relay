//
//  RCChannel.h
//  Relay
//
//  Created by Max Shavrick on 1/23/12.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "RCChatPanel.h"
#import "RCAppDelegate.h"
#import "NSString+Utils.h"
#import "RCUserListPanel.h"
#import "RCUserTableCell.h"
#import "RCDateManager.h"
#import "RCCommandEngine.h"

@class RCNetwork;
@class RCNavigator;
@interface RCChannel : NSObject <UITableViewDelegate, UITableViewDataSource> {
@public
	NSString *channelName;
	NSString *topic;
	NSString *password;
	RCChatPanel *panel;
	RCUserListPanel *usersPanel;
	BOOL joined;
	BOOL joinOnConnect;
    BOOL shouldJoin;
	BOOL temporaryJoinOnConnect;
	RCNetwork *delegate;
    NSMutableArray *fullUserList;
    NSMutableDictionary *userRanksAdv;
}
@property (nonatomic, retain) NSString *channelName;
@property (nonatomic, assign) BOOL joinOnConnect;
@property (nonatomic, assign) BOOL temporaryJoinOnConnect;
@property (nonatomic, assign) RCChatPanel *panel;
@property (nonatomic, retain) NSString *topic;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, assign) RCUserListPanel *usersPanel;
@property (nonatomic, readonly) NSMutableArray *fullUserList;
- (void)disconnected:(NSString *)msg;
- (void)changeNick:(NSString *)old toNick:(NSString *)new_;
- (id)initWithChannelName:(NSString *)_name;
- (void)setDelegate:(RCNetwork *)delegate;
- (RCNetwork *)delegate;
- (void)recievedMessage:(NSString *)message from:(NSString *)from type:(RCMessageType)type;
- (void)setUserJoined:(NSString *)joined;
- (void)setSuccessfullyJoined:(BOOL)success;
- (void)setUserLeft:(NSString *)left;
- (void)setMode:(NSString *)modes forUser:(NSString *)user;
- (void)setJoined:(BOOL)joind withArgument:(NSString *)arg1;
- (void)userWouldLikeToPartakeInThisConversation:(NSString *)message;
- (BOOL)joined;
- (NSMutableArray *)usersMatchingWord:(NSString *)word;
- (void)parseAndHandleSlashCommand:(NSString *)cmd;
- (void)setMyselfParted;
- (BOOL)isUserInChannel:(NSString*)user;
- (void)setSuccessfullyJoined:(BOOL)success;
- (BOOL)isPrivate;
- (void)setJoined:(BOOL)joind;
NSString *RCUserRank(NSString *user, RCNetwork* network);
UIImage *RCImageForRank(NSString *rank, RCNetwork* network);
BOOL RCIsRankHigher(NSString *rank, NSString *rank2, RCNetwork* network);
inline BOOL RCHighlightCheck(RCChannel *self, NSString **message);
char user_hash(NSString *from);
@end
