//
//  RCBasicViewController.h
//  Relay
//
//  Created by Max Shavrick on 7/1/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIView (FindAndResignFirstResponder)
- (BOOL)findAndResignFirstResponder;
@end

@interface RCBasicViewController : UITableViewController {
	UILabel *titleView;
	UIImageView *r_shadow;
	BOOL _rEditing;
}
- (NSString *)titleText;
- (void)setupDoneButton;
- (void)setupEditButton;
@end
