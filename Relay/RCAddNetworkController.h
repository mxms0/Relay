//
//  RCAddNetworkController.h
//  Relay
//
//  Created by Max Shavrick on 3/4/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCNetwork.h"
#import "RCNetworkManager.h"

@interface RCAddNetworkController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIScrollViewDelegate> {
	RCNetwork *network;
	UITableView *tableView;
	NSString *_user;
	NSString *_nick;
	NSString *_name;
	NSString *_sPass;
	NSString *_nPass;
	NSString *_description;
	NSString *_server;
	NSString *_port;
    BOOL hasSSL;
	BOOL existingConnection;
	BOOL connectAtLaunching;
}
@property (nonatomic, retain) NSString *_user;
@property (nonatomic, retain) NSString *_nick;
@property (nonatomic, retain) NSString *_name;
@property (nonatomic, retain) NSString *_sPass;
@property (nonatomic, retain) NSString *_nPass;
@property (nonatomic, retain) NSString *_description;
@property (nonatomic, retain) NSString *_server;
@property (nonatomic, retain) NSString *_port;
@property (nonatomic, assign) BOOL hasSSL;
@property (nonatomic, assign) BOOL connectAtLaunch;
@property (nonatomic, readonly) UITableView *tableView;

- (id)initWithNetwork:(RCNetwork *)net;

@end

@interface UIView (FindAndResignFirstResponder)
- (BOOL)findAndResignFirstResponder;
@end
