//
//  RCChatViewController.h
//  Relay
//
//  Created by Max Shavrick on 10/28/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "RCBaseNavigationViewController.h"
#import "RCChatController.h"
#import "RCPrettyActionSheet.h"
#import "RCAddNetworkController.h"

@interface RCChatViewController : RCBaseNavigationViewController <UIActionSheetDelegate> {
	RCNetwork *currentNetwork; // only exists during options period.
}
- (void)setFrame:(CGRect)frame;
- (void)setCenter:(CGPoint)centr;
@end
