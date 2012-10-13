//
//  RCNavigator.h
//  Relay
//
//  Created by Max Shavrick on 2/25/12.
//

#import <UIKit/UIKit.h>
#import "RCNavigationBar.h"
#import "RCNetwork.h"
#import "RCTitleLabel.h"
#import "RCChannelScrollView.h"
#import "RCChannelBubble.h"
#import "RCChannel.h"
#import "RCUserListPanel.h"
#import "RCPopoverWindow.h"
#import "RCBarButton.h"
#import "RCPrettyAlertView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import "RCCoverView.h"

@interface RCNavigator : UIView <UIAlertViewDelegate, UIActionSheetDelegate> {
	RCNetwork *currentNetwork;
	RCNavigationBar *bar;
	RCChannelScrollView *scrollBar;
	RCChatPanel *currentPanel;
	RCCoverView *cover;
	RCUserListPanel *memberPanel;
	RCTitleLabel *titleLabel;
	RCPopoverWindow *nWindow;
    RCBarButton *plus;
    RCBarButton *listr;
	BOOL _isLandscape;
	BOOL _isShowingList;
	BOOL isFirstSetup;
	BOOL isShowing;
	id _rcViewController;
}
@property (nonatomic, readonly) RCChatPanel *currentPanel;
@property (nonatomic, assign) RCNetwork *currentNetwork;
@property (nonatomic, readonly) RCUserListPanel *memberPanel;
@property (nonatomic, readonly) BOOL _isLandscape;
@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, retain) RCCoverView *cover;
@property (nonatomic, retain) RCPopoverWindow *nWindow;
+ (id)sharedNavigator;
- (void)addNetwork:(RCNetwork *)net;
- (void)addChannel:(NSString *)chan toServer:(RCNetwork *)net;
- (void)removeChannel:(RCChannel *)chan fromServer:(RCNetwork *)net;
- (void)channelSelected:(RCChannelBubble *)bubble;
- (void)tearDownForChannelList:(RCChannelBubble *)bubble;
- (void)channelWantsSuicide:(RCChannelBubble *)bubble;
- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)oi;
- (void)presentNetworkPopover;
- (void)dismissNetworkPopover;
- (void)refreshTitleBar:(RCNetwork *)net;
- (void)selectNetwork:(RCNetwork *)net;
- (CGRect)frameForListButton;
- (CGRect)frameForPlusButton;
- (CGRect)frameForInputField:(BOOL)activ;
- (void)doSuicideConfirmationAlert:(RCChannelBubble *)questionAble;
- (RCChannelBubble *)channelBubbleWithChannel:(id)channel;
- (void)scrollToBubble:(RCChannelBubble *)bubble;
- (void)displayOptionsForChannel:(RCChannelBubble *)bbz;
@end
