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
#import "RCBarGroup.h"
#import "RCPopoverWindow.h"

@interface RCNavigator : UIView <UIAlertViewDelegate, UIActionSheetDelegate> {
	RCNetwork *currentNetwork;
	RCNavigationBar *bar;
	RCChannelScrollView *scrollBar;
	RCChatPanel *currentPanel;
	RCUserListPanel *memberPanel;
	RCBarGroup *leftGroup;
	RCBarGroup *rightGroup;
	RCTitleLabel *titleLabel;
	RCPopoverWindow *window;
	BOOL _isLandscape;
	BOOL _isShowingList;
	int isFirstSetup;
	id _rcViewController;
}
@property (nonatomic, readonly) RCChatPanel *currentPanel;
@property (nonatomic, readonly) RCUserListPanel *memberPanel;
@property (nonatomic, readonly) BOOL _isLandscape;
@property (nonatomic, readonly) UILabel *titleLabel;
+ (id)sharedNavigator;
- (void)addNetwork:(RCNetwork *)net;
- (void)addRoom:(NSString *)room toServerAtIndex:(int)index;
- (void)removeChannel:(RCChannel *)room toServerAtIndex:(int)index;
- (void)channelSelected:(RCChannelBubble *)bubble;
- (void)tearDownForChannelList:(RCChannelBubble *)bubble;
- (void)setMentioned:(BOOL)m forIndex:(int)_index;
- (void)channelWantsSuicide:(RCChannelBubble *)bubble;
- (void)rotateToLandscape;
- (void)rotateToPortrait;
- (void)presentNetworkPopover;
- (void)dismissNetworkPopover;
- (RCChannelBubble *)channelBubbleWithChannelName:(NSString *)name;
@end
