//
//  RCAboutViewController.h
//  Relay
//
//  Created by Fionn Kelleher on 15/08/2013.
//

#import "RCBasicViewController.h"
#import "RCAboutInfoView.h"
#import "RCActionSheetButton.h"
#import "RCNetworkManager.h"
#import "RCChatController.h"

@interface RCAboutViewController : UIViewController {
    UILabel *titleView;
	NSMutableAttributedString *attributedString;
}

@end
