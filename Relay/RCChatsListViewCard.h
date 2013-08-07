//
//  RCChatsListViewCard.h
//  Relay
//
//  Created by Max Shavrick on 6/18/13.
//

#import <UIKit/UIKit.h>
#import "RCViewCard.h"
#import "RCSpecialTableView.h"

@interface RCChatsListViewCard : RCViewCard <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, RCRearrangeableTableViewDelegate> {
@public
	RCSpecialTableView *datas;
	BOOL _reloading;
	BOOL isRearranging;
	BOOL rearrangingHeaders;
	NSTimer *holdTimer;
}
@property (nonatomic, readonly) BOOL isRearranging;
- (void)scrollToTop;
- (BOOL)isPanning;
@end
