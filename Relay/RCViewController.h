//
//  RCViewController.h
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import <UIKit/UIKit.h>
#import "RCChannel.h"
#import "RCChatController.h"
#import "RCChatsListViewController.h"
#import "RCChatNavigationBar.h"
#import "RCChatViewController.h"

@interface RCViewController : UIViewController {
	UIViewController *rootView;
	RCChatViewController *navigationController;
	RCChatsListViewController *leftView;
}
@end
