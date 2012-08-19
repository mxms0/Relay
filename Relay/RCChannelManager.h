//
//  RCRoomsController.h
//  Relay
//
//  Created by Max Shavrick on 3/24/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCAddCell.h"
#import "RCNetwork.h"
#import "RCBasicViewController.h"
#import "RCChannelInfo.h"
#import "RCChannelManagementViewController.h"

@interface RCChannelManager : RCBasicViewController <UIAlertViewDelegate> {
    RCNetwork *network;
	BOOL _rEditing;
    NSMutableArray *channels;
    UIBarButtonItem *addBtn;
}

- (id)initWithStyle:(UITableViewStyle)style andNetwork:(RCNetwork *)net;
@end
