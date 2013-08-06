//
//  RCChatsListViewCard.h
//  Relay
//
//  Created by Max Shavrick on 6/18/13.
//

#import <UIKit/UIKit.h>
#import "RCViewCard.h"
#import "RCSpecialTableView.h"

@interface RCChatsListViewCard : RCViewCard <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate> {
	RCSpecialTableView *datas;
	BOOL _reloading;
	BOOL isRearranging;
	NSTimer *holdTimer;
}
@property (nonatomic, readonly) BOOL isRearranging;
- (void)scrollToTop;
@end
