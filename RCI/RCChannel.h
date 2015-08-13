//
//  RCChannel.h
//  Relay
//
//  Created by Max Shavrick on 1/23/12.
//

#import <Foundation/Foundation.h>
#import "NSString+Utils.h"
#import "RCI.h"

@class RCNetwork, RCMessage;
@interface RCChannel : NSObject {
	BOOL _joined;
	NSString *_channelName;
	NSString *_password;
	BOOL holdUserListUpdates;
	RCNetwork *_network;
    NSMutableArray *fullUserList;
	NSMutableArray *fakeUserList;
    NSMutableDictionary *userRanksAdv;
}
@property (nonatomic, retain) NSString *channelName;
@property (nonatomic, assign) BOOL joined;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, readonly) NSMutableArray *fullUserList;
@property (nonatomic, assign) RCNetwork *network;
- (instancetype)initWithChannelName:(NSString *)_name;
// network chain

- (void)disconnected:(NSString *)msg;
- (void)changeNickForUser:(NSString *)user toNick:(NSString *)nick;

- (void)receivedMessage:(id)_message from:(NSString *)from time:(NSString *)time_ type:(RCMessageType)type;
- (void)receivedMessage:(RCMessage *)message;
- (void)setUserJoined:(NSString *)joined;
- (void)setUserJoinedBatch:(NSString *)join cnt:(int)ct;
- (void)setSuccessfullyJoined:(BOOL)success;
- (void)setUserLeft:(NSString *)left;

- (NSArray *)usersMatchingWord:(NSString *)word;

- (void)join;
- (void)part;
- (void)partWithMessage:(NSString *)message;

- (BOOL)isUserInChannel:(NSString *)user;
- (BOOL)isPrivate;

- (void)kickUser:(NSString *)user;
- (void)banUser:(NSString *)user;

- (void)kickUserAtIndex:(int)index;
- (void)banUserAtIndex:(int)index;
- (void)setMode:(NSString *)modes forUser:(NSString *)user;

- (void)setShouldHoldUserListUpdates:(BOOL)bn;

NSString *RCUserRank(NSString *user, RCNetwork *network);
NSString *RCNickWithoutRank(NSString *nick, RCNetwork *network);
NSInteger RCRankToNumber(unichar rank, RCNetwork *network);
NSInteger RCRankSort(id u1, id u2, RCNetwork *network);
NSInteger RCUserIntegerRank(NSString *prefix, RCNetwork *network);
void RCRefreshTable(NSString *or, NSString *nnr, NSArray *current, RCChannel *self);
BOOL RCIsRankHigher(NSString *rank, NSString *rank2, RCNetwork *network);
char RCUserHash(NSString *from);

@end
