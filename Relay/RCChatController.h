//
//  RCChatController.h
//  Relay
//
//  Created by Max Shavrick on 10/26/12.
//

#import <Foundation/Foundation.h>
#import "RCViewController.h"
#import "RCViewCard.h"
#import "RCTopViewCard.h"
#import "RCChatsListViewCard.h"
#import "RCInitialSetupView.h"
#import "RCChannelListViewCard.h"
#import "RCCuteView.h"
#import "RCSettingsViewController.h"

@class RCChatViewController, RCChatsListViewController, RCUserListViewController;
@interface RCChatController : NSObject <UIAlertViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate> {
	RCChatsListViewCard *bottomView;
	RCViewCard *chatView;
	RCTopViewCard *infoView;
	RCViewController *rootView;
	RCChatPanel *currentPanel;
	RCTextFieldBackgroundView *_bar;
	RCTextField *field;
	CGFloat chatViewHeights[2];
	CGFloat suggestLocation;
	BOOL draggingUserList;
	BOOL nickSuggestionDisabled;
	BOOL canDragMainView;
	BOOL isLISTViewPresented;
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
- (void)presentInitialSetupView;
- (void)dismissChannelList:(UIView *)cl animated:(BOOL)anim;
- (void)nickSuggestionCancelled;
- (void)showNetworkListOptions;
- (void)showNetworkAddViewController;
- (void)showNetworkOptions:(id)ob;
- (void)menuButtonPressed:(id)obj;
- (void)popUserListWithDefaultDuration;
- (void)userSwiped_specialLikeAc3xx:(id)gest;
@end
