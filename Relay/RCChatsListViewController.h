//
//  RCChatsListViewController.h
//  Relay
//
//  Created by Max Shavrick on 10/26/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCNetworkManager.h"
#import "RCNetworkHeaderButton.h"
#import "RCSpecialTableView.h"
#import "RCBaseNavigationViewController.h"
#import "RCNetworkCell.h"
#import "RCChatController.h"

@interface RCChatsListViewController : RCBaseNavigationViewController <UITableViewDataSource, UITableViewDelegate> {
	RCSpecialTableView *datas;
	BOOL _reloading;
}

@end
