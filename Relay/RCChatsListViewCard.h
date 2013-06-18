//
//  RCChatsListViewCard.h
//  Relay
//
//  Created by Max Shavrick on 6/18/13.
//

#import <UIKit/UIKit.h>
#import "RCViewCard.h"
#import "RCSpecialTableView.h"

@interface RCChatsListViewCard : RCViewCard <UITableViewDataSource, UITableViewDelegate> {
	RCSpecialTableView *datas;
	BOOL _reloading;
}

@end
