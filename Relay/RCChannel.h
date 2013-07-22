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

@class RCNetwork, RCNetworkCell;
@interface RCChannel : NSObject {
@public
	NSString *channelName;
	NSString *password;
	RCChatPanel *panel;
	RCUserListPanel *usersPanel;
	BOOL joined;
	BOOL joinOnConnect;
	BOOL temporaryJoinOnConnect;
	BOOL holdUserListUpdates;
	BOOL hasHighlights;
	unsigned newMessageCount;
	RCNetwork *delegate;
	RCNetworkCell *cellRepresentation;
    NSMutableArray *fullUserList;
	NSMutableArray *fakeUserList;
    NSMutableDictionary *userRanksAdv;
}
@property (nonatomic, retain) NSString *channelName;
@property (nonatomic, assign) BOOL joinOnConnect;
@property (nonatomic, assign) BOOL temporaryJoinOnConnect;
@property (nonatomic, assign) BOOL hasHighlights;
@property (nonatomic, assign) RCChatPanel *panel;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, assign) RCUserListPanel *usersPanel;
@property (nonatomic, readonly) NSMutableArray *fullUserList;
@property (nonatomic, retain) RCNetworkCell *cellRepresentation;
@property (nonatomic, assign) unsigned newMessageCount;
- (void)disconnected:(NSString *)msg;
- (void)changeNick:(NSString *)old toNick:(NSString *)new_;
- (id)initWithChannelName:(NSString *)_name;
- (void)setDelegate:(RCNetwork *)delegate;
- (RCNetwork *)delegate;
- (void)recievedMessage:(NSString *)message from:(NSString *)from type:(RCMessageType)type;
- (void)setUserJoined:(NSString *)joined;
- (void)setUserJoinedBatch:(NSString *)join cnt:(int)ct;
- (void)setSuccessfullyJoined:(BOOL)success;
- (void)setUserLeft:(NSString *)left;
- (void)setMode:(NSString *)modes forUser:(NSString *)user;
- (void)setJoined:(BOOL)joind withArgument:(NSString *)arg1;
- (void)userWouldLikeToPartakeInThisConversation:(NSString *)message;
- (BOOL)joined;
- (NSMutableArray *)usersMatchingWord:(NSString *)word;
- (void)parseAndHandleSlashCommand:(NSString *)cmd;
- (void)setMyselfParted;
- (BOOL)isUserInChannel:(NSString *)user;
- (BOOL)isPrivate;
- (void)clearAllMessages;
- (void)setJoined:(BOOL)joind;
- (void)setShouldHoldUserListUpdates:(BOOL)bn;
inline NSString *RCUserRank(NSString *user, RCNetwork *network);
inline NSString *RCNickWithoutRank(NSString *nick, RCNetwork *self);
inline NSInteger RCRankToNumber(unichar rank, RCNetwork *network);
inline NSInteger RCRankSort(id u1, id u2, RCNetwork *network);
inline void RCRefreshTable(NSString *or, NSString *nnr, NSArray *current, RCChannel *self);
inline BOOL RCIsRankHigher(NSString *rank, NSString *rank2, RCNetwork *network);
inline BOOL RCHighlightCheck(RCChannel *self, NSString **message);
inline char RCUserHash(NSString *from);
@end
