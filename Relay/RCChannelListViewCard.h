//
//  RCChannelListViewCard.h
//  Relay
//
//  Created by Max Shavrick on 6/29/13.
//

#import "RCViewCard.h"
#import "RCChannelInfo.h"
#import "RCChannelInfoTableViewCell.h"
#import "NSString+IRCStringSupport.h"
#import "RCOperationQueue.h"
#import "RCHoverViewCard.h"
#import "RCSearchBar.h"

@interface RCChannelListViewCard : RCHoverViewCard <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
	UITableView *channels;
	NSMutableArray *channelDatas;
	NSMutableArray *searchArray;
	NSMutableDictionary *currentChannels;
	NSMutableDictionary *unsortedChannels;
	RCNetwork *currentNetwork;
	NSString *searchTerm;
	RCOperationQueue *queue;
	UIImageView *_shadow;
	BOOL isSearching;
	BOOL shouldBeIterating;
	BOOL updating;
	CGFloat imageHeight;
	int count;
	int max;
}
@property (nonatomic, assign) RCNetwork *currentNetwork;
- (void)setUpdating:(BOOL)ud;
- (void)recievedChannel:(NSString *)chan withCount:(int)cc andTopic:(NSString *)topics;
- (void)presentErrorNotification:(NSString *)errorString;
- (void)scrollToTop;
- (void)searchForKeyword:(id)oper;
@end
