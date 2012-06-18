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
#import "RCNewMessagesBubble.h"
#import "RCBarGroup.h"

@interface RCNavigator : UIView <UIScrollViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
	RCNavigationBar *bar;
	RCChannelScrollView *scrollBar;
	RCChatPanel *currentPanel;
	RCUserListPanel *memberPanel;
	RCNewMessagesBubble *leftBubble;
	RCNewMessagesBubble *rightBubble;
	RCBarGroup *leftGroup;
	RCBarGroup *rightGroup;
	UILabel *stupidLabel;
	RCTitleLabel *titleLabel;
	NSMutableDictionary *_notifications;
	BOOL draggingNets;
	BOOL draggingChans;
	BOOL _isLandscape;
	int isFirstSetup;
	int netCount;
	int currentIndex;
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
- (RCChannelBubble *)channelBubbleWithChannelName:(NSString *)name;
@end
