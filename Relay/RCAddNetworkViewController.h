//
//  RCAddNetwork.h
//  Relay
//
//  Created by Max Shavrick on 12/23/11.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCAddNetworkViewController : UITableViewController <UITextFieldDelegate> {
    UITextField *user;
	NSString *_user;
    UITextField *nick;
	NSString *_nick;
    UITextField *name;
	NSString *_name;
    UITextField *sPass;
	NSString *_sPass;
    UITextField *nPass;
	NSString *_nPass;
    UITextField *description;
	NSString *_description;
    UITextField *server;
	NSString *_server;
    UITextField *port;
	NSString *_port;
    BOOL hasSSL;
	BOOL existingConnection;
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
@end
