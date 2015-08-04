//
//  RCChannel.h
//  Relay
//
//  Created by Max Shavrick on 1/23/12.
//

#import <Foundation/Foundation.h>
#import "NSString+Utils.h"
#import "RCMessageConstruct.h"
#import "RCI.h"
#import "RCCommandEngine.h"

@class RCNetwork, RCChannelCell, RCMessage;
@interface RCChannel : NSObject {
@public
	NSString *channelName;
	NSString *password;
	id panel;
	id usersPanel;
	BOOL joinOnConnect;
	BOOL temporaryJoinOnConnect;
	BOOL holdUserListUpdates;
	BOOL hasHighlights;
	unsigned newMessageCount;
	RCNetwork *delegate;
	RCChannelCell *cellRepresentation;
    NSMutableArray *fullUserList;
	NSMutableArray *fakeUserList;
    NSMutableDictionary *userRanksAdv;
	NSMutableArray *pool;
}
@property (nonatomic, copy) NSString *channelName;
@property (nonatomic, assign) BOOL joinOnConnect;
@property (nonatomic, assign) BOOL temporaryJoinOnConnect;
@property (nonatomic, assign) BOOL hasHighlights;
@property (nonatomic, assign) BOOL joined;
@property (nonatomic, assign) id panel;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, assign) id usersPanel;
@property (nonatomic, readonly) NSMutableArray *fullUserList;
@property (nonatomic, retain) RCChannelCell *cellRepresentation;
@property (nonatomic, assign) unsigned newMessageCount;
- (void)disconnected:(NSString *)msg;
- (void)changeNick:(NSString *)old toNick:(NSString *)new_;
- (id)initWithChannelName:(NSString *)_name;
- (void)setDelegate:(RCNetwork *)delegate;
- (RCNetwork *)delegate;
- (void)recievedMessage:(id)_message from:(NSString *)from time:(NSString *)time_ type:(RCMessageType)type;
- (void)setUserJoined:(NSString *)joined;
- (void)setUserJoinedBatch:(NSString *)join cnt:(int)ct;
- (void)setSuccessfullyJoined:(BOOL)success;
- (void)setUserLeft:(NSString *)left;
- (void)setMode:(NSString *)modes forUser:(NSString *)user;
- (void)userWouldLikeToPartakeInThisConversation:(NSString *)message;
- (NSMutableArray *)usersMatchingWord:(NSString *)word;
- (void)parseAndHandleSlashCommand:(NSString *)cmd;
- (void)setMyselfParted;

- (void)join;
- (void)part;
- (void)partWithMessage:(NSString *)message;
- (BOOL)isUserInChannel:(NSString *)user;
- (BOOL)isPrivate;
- (void)clearAllMessages;
- (void)setJoined:(BOOL)joind;
- (void)kickUserAtIndex:(int)index;
- (void)banUserAtIndex:(int)index;
- (void)setShouldHoldUserListUpdates:(BOOL)bn;
- (NSArray *)allMessages;
NSString *RCUserRank(NSString *user, RCNetwork *network);
int RCUserIntegerRank(NSString *prefix, RCNetwork *network);
NSString *RCNickWithoutRank(NSString *nick, RCNetwork *self);
NSInteger RCRankToNumber(unichar rank, RCNetwork *network);
NSInteger RCRankSort(id u1, id u2, RCNetwork *network);
void RCRefreshTable(NSString *or, NSString *nnr, NSArray *current, RCChannel *self);
BOOL RCIsRankHigher(NSString *rank, NSString *rank2, RCNetwork *network);
char RCUserHash(NSString *from);
@end
