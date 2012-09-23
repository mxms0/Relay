//
//  RCAddNetworkController.h
//  Relay
//
//  Created by Max Shavrick on 3/4/12.
//

#import <UIKit/UIKit.h>
#import "RCNetwork.h"
#import "RCNetworkManager.h"
#import "RCTextField.h"
#import "RCBasicTextInputCell.h"
#import "RCChannelManager.h"
#import "RCBasicViewController.h"
#import "RCAlternateNicknamesManager.h"
#import "RCPrettyAlertView.h"

@interface RCAddNetworkController : RCBasicViewController <UITextFieldDelegate, UIScrollViewDelegate> {
	RCNetwork *network;
	NSString *name;
	BOOL isNew;
}
- (id)initWithNetwork:(RCNetwork *)net;
- (void)showStupidWarningsRegardingMichiganUniversity;
@end