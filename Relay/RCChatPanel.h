//
//  RCChatPanel.h
//  Relay
//
//  Created by Max Shavrick on 2/17/12.
//

#import <UIKit/UIKit.h>
#import "RCTableView.h"
#import "RCTextField.h"
#import "RCMessageFormatter.h"
#import "RCTextFieldBackgroundView.h"
#import "RCNickSuggestionView.h"

@class RCChannel;
@interface RCChatPanel : UIWebView <UITextFieldDelegate> {
	RCChannel *channel;
	UITextField *field;
	NSMutableArray *preloadPool;
	RCTextFieldBackgroundView *_bar;
	CGFloat chatViewHeights[2];
	CGFloat suggestionLocation;
}
@property (nonatomic, assign) RCChannel *channel;
@property (nonatomic, readonly) NSMutableArray *messages;

- (id)initWithChannel:(RCChannel *)chan;
- (void)postMessage:(NSString *)_message withType:(RCMessageType)tr highlight:(BOOL)high;
- (void)postMessage:(NSString *)_message withType:(RCMessageType)rr highlight:(BOOL)high isMine:(BOOL)mine;
- (void)scrollToBottom;
- (void)scrollToTop;
- (void)setScrollingEnabled:(BOOL)en;
@end
