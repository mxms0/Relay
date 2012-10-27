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

@interface RCViewController : UIViewController {
	UIViewController *rootView;
	UINavigationController *navigationController;
	RCChatsListViewController *leftView;
}
@end
