//
//  RCUserListViewController.h
//  Relay
//
//  Created by Max Shavrick on 11/23/12.
//

#import "RCBaseNavigationViewController.h"
#import "RCSuperSpecialTableView.h"
#import "RCUserTableCell.h"

@interface RCUserListViewController : RCBaseNavigationViewController <UITableViewDataSource, UITableViewDelegate> {
	RCSuperSpecialTableView *tableView;
}
- (void)findShadowAndDoStuffToIt;
- (void)setCenter:(CGPoint)cc;
- (void)setFrame:(CGRect)frm;
@end
