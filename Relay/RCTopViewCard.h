//
//  RCTopViewCard.h
//  Relay
//
//  Created by Max Shavrick on 6/17/13.
//

#import <UIKit/UIKit.h>
#import "RCViewCard.h"
#import "RCChannel.h"
#import "RCSuperSpecialTableView.h"

@interface RCTopViewCard : RCViewCard <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate> {
	RCSuperSpecialTableView *tableView;
	BOOL showingUserInfo;
	RCChannel *currentChan;
}
@property (nonatomic, assign) RCChannel *currentChan;
- (void)setChannel:(RCChannel *)chan;
- (void)reloadData;
@end
