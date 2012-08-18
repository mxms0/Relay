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
	NSString *channel;
	NSString *originalChannel;
	NSString *pass;
	BOOL jOC;
}
@property (nonatomic, retain) NSString *channel;
@property (nonatomic, retain) NSString *originalChannel;
- (id)initWithStyle:(UITableViewStyle)style network:(RCNetwork *)net channel:(NSString *)chan;
@end
