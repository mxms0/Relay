//
//  RCSettingsViewController.h
//  Relay
//
//  Created by Max Shavrick on 7/12/13.
//

/*
 [17:54:27] <Fudgetta>	 Global Settings
 [17:54:30] <Fudgetta>	 - nickname
 [17:54:32] <Fudgetta>	 - username
 [17:54:35] <Fudgetta>	 - realname
 [17:54:38] <Fudgetta>	 - quit message
 [17:54:41] <Fudgetta>	 etc.
 [17:55:18] <Fudgetta>	 include miliseconds
 [17:55:25] <Fudgetta>	 font size
*/

#import <UIKit/UIKit.h>
#import "RCBasicViewController.h"
#import "RCBarButtonItem.h"
#import "RCBasicTextInputCell.h"

@interface RCSettingsViewController : RCBasicViewController

- (void)dismiss;
- (void)cancelChanges;
- (void)saveChanges;

@end
