//
//  RCChannelListViewCard.h
//  Relay
//
//  Created by Max Shavrick on 6/29/13.
//

#import "RCViewCard.h"
#import "RCSuperSpecialTableView.h"
#import "RCChannelInfo.h"
#import "RCChannelInfoTableViewCell.h"
#import "NSString+IRCStringSupport.h"
#import "RCOperationQueue.h"
#import "RCHoverViewCard.h"
#import <CoreText/CoreText.h>

@interface RCChannelListViewCard : RCHoverViewCard <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
	UITableView *channels;
	NSMutableArray *channelDatas;
	NSMutableArray *searchArray;
	NSMutableArray *currentChannels;
	NSMutableDictionary *unsortedChannels;
	RCNetwork *currentNetwork;
	NSString *searchTerm;
	RCOperationQueue *queue;
	BOOL isSearching;
	BOOL shouldBeIterating;
	BOOL updating;
	int count;
}
@property (nonatomic, assign) RCNetwork *currentNetwork;
- (void)setUpdating:(BOOL)ud;
- (void)recievedChannel:(NSString *)chan withCount:(int)cc andTopic:(NSString *)topics;
- (void)presentErrorNotificationAndDismiss;
- (void)scrollToTop;
- (void)searchForKeyword:(id)oper;
@end
