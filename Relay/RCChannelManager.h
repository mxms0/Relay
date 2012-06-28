//
//  RCRoomsController.h
//  Relay
//
//  Created by Max Shavrick on 3/24/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCAddCell.h"
#import "RCNetwork.h"

@interface RCChannelManager : UITableViewController <UIAlertViewDelegate> {
    UIImageView *r_shadow;
    RCNetwork *network;
    NSMutableArray *channels;
    UIBarButtonItem *addBtn;
}


- (id)initWithStyle:(UITableViewStyle)style andNetwork:(RCNetwork *)net;
- (void)addNewItem;

@end
