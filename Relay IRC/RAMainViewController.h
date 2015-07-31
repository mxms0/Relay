//
//  RAMainViewController.h
//  Relay IRC
//
//  Created by Max Shavrick on 7/20/15.
//  Copyright (c) 2015 Mxms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RATableView.h"
#import "RCNetwork.h"
#import "RANavigationBar.h"

@class RAChatController;
@interface RAMainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIToolbarDelegate, RANavigationBarButtonDelegate> {
	RATableView *networks;
	RAChatController *controller;
}


@end

