//
//  RCAlternateNicknamesManager.h
//  Relay
//
//  Created by David Murray on 12-07-10.
//

#import "RCBasicViewController.h"
#import "RCNetwork.h"
#import "RCAddCell.h"

@interface RCAlternateNicknamesManager : RCBasicViewController {
    RCNetwork *network;
    NSMutableArray *nicknames;
    UIBarButtonItem *addBtn;
}
- (id)initWithStyle:(UITableViewStyle)style andNetwork:(RCNetwork *)net;
@end
