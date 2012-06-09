//
//  RCRoomsController.h
//  Relay
//
//  Created by David Murray on 12-06-05.
//  Copyright (c) 2012 École Secondaire De Mortagne. All rights reserved.
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
