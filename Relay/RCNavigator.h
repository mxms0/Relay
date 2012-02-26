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

@interface RCNavigator : UIView <UIScrollViewDelegate> {
	RCNavigationBar *bar;
	RCChannelScrollView *scrollBar;
	RCChatPanel *currentPanel;
	NSMutableArray *rooms;
	int netCount;
	int currentIndex;
}
+ (id)sharedNavigator;
- (void)addNetwork:(RCNetwork *)net;
- (void)addRoom:(NSString *)room toServerAtIndex:(int)index;
@end