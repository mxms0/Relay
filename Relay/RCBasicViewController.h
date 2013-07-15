//
//  RCBasicViewController.h
//  Relay
//
//  Created by Max Shavrick on 7/1/12.
//

#import <UIKit/UIKit.h>
#import "RCBarButtonItem.h"

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
- (void)edit;
@end
