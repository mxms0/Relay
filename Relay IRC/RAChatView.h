//
//  RCChatPanel.h
//  Relay
//
//  Created by Max Shavrick on 2/17/12.
//

#import <UIKit/UIKit.h>

@class RCChannel, RCMessageConstruct;
@interface RAChatView : UITableView <UIGestureRecognizerDelegate> {
	RCChannel *channel;
	NSMutableArray *pool;
}
@property (nonatomic, assign) RCChannel *channel;
- (id)init;
- (void)switchToChannel:(RCChannel *)channel;
- (void)scrollToBottom;
- (void)scrollToTop;
- (void)scrollToBottomAnimated:(BOOL)anim;
@end
