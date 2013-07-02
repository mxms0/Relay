//
//  RCChannelListViewCard.h
//  Relay
//
//  Created by Siberia on 6/29/13.
//

#import "RCViewCard.h"
#import "RCSuperSpecialTableView.h"
#import "RCChannelInfo.h"

@interface RCChannelListViewCard : RCViewCard <UITableViewDataSource, UITableViewDelegate> {
	RCSuperSpecialTableView *channels;
	NSMutableArray *channelDatas;
	BOOL updating;
}
- (void)setUpdating:(BOOL)ud;
- (void)recievedChannel:(NSString *)chan withCount:(int)cc andTopic:(NSString *)topics;
@end
