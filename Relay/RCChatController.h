//
//  RCChatController.h
//  Relay
//
//  Created by Max Shavrick on 10/26/12.
//

#import <Foundation/Foundation.h>
#import "RCViewController.h"

@class RCChatViewController, RCChatsListViewController, RCUserListViewController;
@interface RCChatController : NSObject <UIAlertViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate> {
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
- (CGFloat)suggestionLocation;
- (BOOL)isLandscape;
- (BOOL)isShowingChatListView;
- (void)selectChannel:(NSString *)channel fromNetwork:(RCNetwork *)net;
- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)oi;
- (void)pushUserListWithDefaultDuration;
- (void)showMenuOptions:(id)unused;
- (void)reloadUserCount;
- (void)correctSubviewFrames;
- (void)closeWithDuration:(NSTimeInterval)dur;
- (void)setDefaultTitleAndSubtitle;
- (void)layoutWithRootViewController:(RCViewController *)rc;
@end
