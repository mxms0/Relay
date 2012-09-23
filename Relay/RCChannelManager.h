//
//  RCRoomsController.h
//  Relay
//
//  Created by Max Shavrick on 3/24/12.
//

#import "RCAddCell.h"
#import "RCNetwork.h"
#import "RCBasicViewController.h"
#import "RCChannelInfo.h"
#import "RCChannelManagementViewController.h"

@interface RCChannelManager : RCBasicViewController <UIAlertViewDelegate> {
    RCNetwork *network;
    NSMutableArray *channels;
    UIBarButtonItem *addBtn;
}

- (id)initWithStyle:(UITableViewStyle)style andNetwork:(RCNetwork *)net;
- (void)addStupidWarningView;
- (void)removeStupidWarningView;
@end
