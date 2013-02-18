//
//  RCChatController.h
//  Relay
//
//  Created by Max Shavrick on 10/26/12.
//

#import <Foundation/Foundation.h>
#import "RCViewController.h"

@class RCChatViewController, RCChatsListViewController, RCUserListViewController;
@interface RCChatController : NSObject <UIAlertViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate> {
	RCViewController *rootView;
	RCChatViewController *navigationController;
	RCChatsListViewController *leftView;
	RCChatPanel *currentPanel;
	RCUserListViewController *topView;
	RCTextFieldBackgroundView *_bar;
	RCTextField *field;
	CGFloat chatViewHeights[2];
	CGFloat suggestLocation;
	BOOL draggingUserList;
	BOOL nickSuggestionDisabled;
	BOOL canDragMainView;
}
@property (nonatomic, retain) RCChatPanel *currentPanel;
@property (nonatomic, assign) BOOL canDragMainView;
- (id)initWithRootViewController:(RCViewController *)rc;
+ (id)sharedController;
- (CGFloat)suggestionLocation;
- (BOOL)isLandscape;
- (BOOL)isShowingChatListView;
- (void)setEntryFieldEnabled:(BOOL)en;
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
