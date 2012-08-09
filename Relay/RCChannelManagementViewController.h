//
//  RCChannelManagementViewController.h
//  Relay
//
//  Created by Max Shavrick on 8/7/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCBasicViewController.h"
#import "RCBasicTextInputCell.h"
#import "RCBasicTableViewCell.h"
#import "RCChannelManager.h"
#import "RCKeychainItem.h"

@class RCNetwork;
@interface RCChannelManagementViewController : RCBasicViewController <UITextFieldDelegate> {
	RCNetwork *net;
	NSString *chan;
	NSString *orig;
	NSString *pass;
	BOOL jOC;
}

- (id)initWithStyle:(UITableViewStyle)style network:(RCNetwork *)net channel:(NSString *)chan;
@end
