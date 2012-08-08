//
//  RCChannelManagementViewController.h
//  Relay
//
//  Created by Max Shavrick on 8/7/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCBasicViewController.h"
@class RCNetwork;
@interface RCChannelManagementViewController : RCBasicViewController {
	RCNetwork *net;
	NSString *chan;
}

- (id)initWithStyle:(UITableViewStyle)style network:(RCNetwork *)net channel:(NSString *)chan;
@end
