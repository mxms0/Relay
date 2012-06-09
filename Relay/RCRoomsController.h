//
//  RCRoomsController.h
//  Relay
//
//  Created by David Murray on 12-06-05.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCAddCell.h"
#import "RCNetwork.h"

@interface RCRoomsController : UITableViewController <UIAlertViewDelegate>
{
    UIImageView *r_shadow;
    RCNetwork *network;
    NSMutableArray *channels;
    UIBarButtonItem *addBtn;
}
@property (nonatomic, retain) RCNetwork *network;
@property (nonatomic, retain) NSMutableArray *channels;

- (id)initWithStyle:(UITableViewStyle)style andNetwork:(RCNetwork *)net;
- (void)addNewItem;
@end
