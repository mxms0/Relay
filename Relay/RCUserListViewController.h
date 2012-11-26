//
//  RCUserListViewController.h
//  Relay
//
//  Created by Max Shavrick on 11/23/12.
//

#import "RCBaseNavigationViewController.h"
#import "RCSuperSpecialTableView.h"
#import "RCUserTableCell.h"

@class RCChannel;
@interface RCUserListViewController : RCBaseNavigationViewController <UITableViewDataSource, UITableViewDelegate> {
	RCSuperSpecialTableView *tableView;
	RCChannel *currentChan;
}
@property (nonatomic, retain) RCChannel *currentChan;
- (void)findShadowAndDoStuffToIt;
- (void)setCenter:(CGPoint)cc;
- (void)setFrame:(CGRect)frm;
- (void)setChannel:(id)chan;
@end
