//
//  RCPopoverWindow.h
//  Relay
//
//  Created by Max Shavrick on 6/18/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCNetworkCell.h"

@interface RCPopoverWindow : UIView <UITableViewDelegate, UITableViewDataSource> {
	UIImageView *_pImg;
	id applicationDelegate;
	UITableView *networkTable;
	BOOL shouldRePresentKeyboardOnDismiss;
}
@property (nonatomic, assign) BOOL shouldRePresentKeyboardOnDismiss;
- (void)reloadData;
- (void)animateIn;
- (void)animateOut;
- (void)correctAndRotateToInterfaceOrientation:(UIInterfaceOrientation)oi;
@end
