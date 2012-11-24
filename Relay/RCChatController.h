//
//  RCChatController.h
//  Relay
//
//  Created by Max Shavrick on 10/26/12.
//

#import <Foundation/Foundation.h>
#import "RCViewController.h"

@class RCChatViewController, RCChatsListViewController, RCUserListViewController;
@interface RCChatController : NSObject <UIAlertViewDelegate> {
	RCViewController *rootView;
	RCChatViewController *navigationController;
	RCChatsListViewController *leftView;
	RCChatPanel *currentPanel;
	RCUserListViewController *topView;
	BOOL draggingUserList;
	BOOL canDragMainView;
}
@property (nonatomic, retain) RCChatPanel *currentPanel;
@property (nonatomic, assign) BOOL canDragMainView;
- (id)initWithRootViewController:(RCViewController *)rc;
+ (id)sharedController;
- (CGRect)frameForChatPanel;
- (BOOL)isLandscape;
- (void)selectChannel:(NSString *)channel fromNetwork:(RCNetwork *)net;
- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)oi;
- (void)showMenuOptions:(id)unused;
@end
