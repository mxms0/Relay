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
@public
	NSString *_channelName;
	NSString *_password;
	BOOL holdUserListUpdates;
	BOOL hasHighlights;
	unsigned newMessageCount;
	RCNetwork *_network;
    NSMutableArray *fullUserList;
	NSMutableArray *fakeUserList;
    NSMutableDictionary *userRanksAdv;
}
@property (nonatomic, retain) NSString *channelName;
@property (nonatomic, assign) BOOL hasHighlights;
@property (nonatomic, assign) BOOL joined;
@property (nonatomic, retain) NSString *password;
@property (nonatomic, readonly) NSMutableArray *fullUserList;
@property (nonatomic, assign) unsigned newMessageCount;
@property (nonatomic, assign) RCNetwork *network;
- (void)disconnected:(NSString *)msg;
- (void)changeNick:(NSString *)old toNick:(NSString *)new_;
- (id)initWithChannelName:(NSString *)_name;
- (void)receivedMessage:(id)_message from:(NSString *)from time:(NSString *)time_ type:(RCMessageType)type;
- (void)receivedMessage:(RCMessage *)message;
- (void)setUserJoined:(NSString *)joined;
- (void)setUserJoinedBatch:(NSString *)join cnt:(int)ct;
- (void)setSuccessfullyJoined:(BOOL)success;
- (void)setUserLeft:(NSString *)left;
- (void)setMode:(NSString *)modes forUser:(NSString *)user;
- (NSMutableArray *)usersMatchingWord:(NSString *)word;

- (void)join;
- (void)part;
- (void)partWithMessage:(NSString *)message;
- (BOOL)isUserInChannel:(NSString *)user;
- (BOOL)isPrivate;
- (void)setJoined:(BOOL)joind;
- (void)kickUserAtIndex:(int)index;
- (void)banUserAtIndex:(int)index;
- (void)setShouldHoldUserListUpdates:(BOOL)bn;
NSString *RCUserRank(NSString *user, RCNetwork *network);
int RCUserIntegerRank(NSString *prefix, RCNetwork *network);
NSString *RCNickWithoutRank(NSString *nick, RCNetwork *self);
NSInteger RCRankToNumber(unichar rank, RCNetwork *network);
NSInteger RCRankSort(id u1, id u2, RCNetwork *network);
void RCRefreshTable(NSString *or, NSString *nnr, NSArray *current, RCChannel *self);
BOOL RCIsRankHigher(NSString *rank, NSString *rank2, RCNetwork *network);
char RCUserHash(NSString *from);
@end
