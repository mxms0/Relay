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
#import "RCTextField.h"
#import "RCBasicTextInputCell.h"
#import "RCChannelManager.h"
#import "RCBasicViewController.h"
#import "RCAlternateNicknamesManager.h"

@interface RCAddNetworkController : RCBasicViewController <UITextFieldDelegate, UIScrollViewDelegate> {
	RCNetwork *network;
	BOOL isNew;
}
- (id)initWithNetwork:(RCNetwork *)net;

@end

@interface UIView (FindAndResignFirstResponder)
- (BOOL)findAndResignFirstResponder;
@end
