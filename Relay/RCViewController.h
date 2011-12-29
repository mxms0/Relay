//
//  RCViewController.h
//  Relay
//
//  Created by Max Shavrick on 12/23/11.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCSocket.h"
#import "RCNetwork.h"
#import "RCNetworkManager.h"
#import "RCAddNetworkViewController.h"

@interface RCViewController : UITableViewController {
	RCNetworkManager *manager;
}

@end
