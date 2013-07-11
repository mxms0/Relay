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

@interface RCChannelListViewCard : RCViewCard <UITableViewDataSource, UITableViewDelegate> {
	UITableView *channels;
	NSMutableArray *channelDatas;
	BOOL updating;
}
- (void)setUpdating:(BOOL)ud;
- (void)recievedChannel:(NSString *)chan withCount:(int)cc andTopic:(NSString *)topics;
- (void)presentErrorNotificationAndDismiss;
@end
