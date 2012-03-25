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
#import "RCBarManager.h"
#import "RCUserListPanel.h"
#import "RCNewMessagesBubble.h"

@interface RCNavigator : UIView <UIScrollViewDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
	RCNavigationBar *bar;
	RCChannelScrollView *scrollBar;
	RCChatPanel *currentPanel;
	RCUserListPanel *memberPanel;
	RCBarManager *manager;
	RCNewMessagesBubble *leftBubble;
	RCNewMessagesBubble *rightBubble;
	NSMutableDictionary *_notifications;
	UILabel *stupidLabel;
	NSMutableArray *rooms;
	BOOL draggingNets;
	BOOL draggingChans;
	int isFirstSetup;
	int netCount;
	int currentIndex;
}
@property (nonatomic, readonly) RCChatPanel *currentPanel;
@property (nonatomic, readonly) RCUserListPanel *memberPanel;
+ (id)sharedNavigator;
- (void)addNetwork:(RCNetwork *)net;
- (void)addRoom:(NSString *)room toServerAtIndex:(int)index;
- (void)removeChannel:(RCChannel *)room toServerAtIndex:(int)index;
- (void)channelSelected:(RCChannelBubble *)bubble;
- (void)tearDownForChannelList:(RCChannelBubble *)bubble;
- (void)setMentioned:(BOOL)m forIndex:(int)_index;
- (void)channelWantsSuicide:(RCChannelBubble *)bubble;
- (RCChannelBubble *)channelBubbleWithChannelName:(NSString *)name;
@end
