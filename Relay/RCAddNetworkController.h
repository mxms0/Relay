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
#import "RCSwitch.h"
#import "RCTextField.h"
#import "RCAddCell.h"
#import "RCChannelManager.h"

@interface RCAddNetworkController : UITableViewController <UITextFieldDelegate, UIScrollViewDelegate> {
	RCNetwork *network;
	BOOL isNew;
	UIImageView *r_shadow;
    NSString *titleString;
}
@property (nonatomic, retain) NSString *titleString;
- (id)initWithNetwork:(RCNetwork *)net;

@end

@interface UIView (FindAndResignFirstResponder)
- (BOOL)findAndResignFirstResponder;
@end
