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

@interface RCChannelListViewCard : RCViewCard <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
	UITableView *channels;
	NSMutableArray *channelDatas;
	NSMutableArray *searchArray;
	NSMutableArray *currentChannels;
	RCNetwork *currentNetwork;
	BOOL isSearching;
	BOOL updating;
}
@property (nonatomic, assign) RCNetwork *currentNetwork;
- (void)setUpdating:(BOOL)ud;
- (void)recievedChannel:(NSString *)chan withCount:(int)cc andTopic:(NSString *)topics;
- (void)presentErrorNotificationAndDismiss;
- (void)scrollToTop;
@end
