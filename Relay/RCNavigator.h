//
//  RCNavigator.h
//  Relay
//
//  Created by Max Shavrick on 2/25/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
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

@interface RCNavigator : UIView <UIAlertViewDelegate, UIActionSheetDelegate> {
	RCNetwork *currentNetwork;
	RCNavigationBar *bar;
	RCChannelScrollView *scrollBar;
	RCChatPanel *currentPanel;
	RCUserListPanel *memberPanel;
	RCTitleLabel *titleLabel;
	RCPopoverWindow *window;
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
- (void)selectNetwork:(RCNetwork *)net;
- (CGRect)frameForListButton;
- (CGRect)frameForPlusButton;
- (RCChannelBubble *)channelBubbleWithChannel:(id)channel;
@end
