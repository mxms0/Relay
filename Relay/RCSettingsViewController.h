//
//  RCSettingsViewController.h
//  Relay
//
//  Created by Max Shavrick on 7/12/13.
//

#import <UIKit/UIKit.h>
#import "RCBasicViewController.h"
#import "RCBarButtonItem.h"
#import "RCBasicTextInputCell.h"
#import "RCSettingsTableViewCell.h"
#import "RCNetworkManager.h"
#import "RCOpaqueHeaderView.h"

@interface RCSettingsViewController : RCBasicViewController {
	NSDictionary *keyValues;
	NSMutableDictionary *managedPreferences;
	NSArray *sectionalArrays;
	BOOL madeChanges;
	BOOL themeChanged;
}

- (void)dismiss;
- (void)cancelChanges;
- (void)saveChanges;
@end
