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
#import "RAChannelProxy.h"
#import "RAChatController.h"

@class RAChatController;
@protocol RAChatControllerDelegate;
@interface RAMainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, RANavigationBarButtonDelegate, RAChatControllerDelegate> {
	RATableView *conversationView;
	RAChatController *controller;
	RAChannelProxy *currentChannel;
}

@end
