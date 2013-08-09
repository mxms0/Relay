//
//  RCChatPanel.h
//  Relay
//
//  Created by Max Shavrick on 2/17/12.
//

#import <UIKit/UIKit.h>
#import "RCMessageFormatter.h"
#import "RCTextFieldBackgroundView.h"
#import "RCNickSuggestionView.h"

@class RCChannel;
@interface RCChatPanel : UIWebView <UITextFieldDelegate> {
	RCChannel *channel;
	NSMutableArray *preloadPool;
	CGFloat suggestionLocation;
}
@property (nonatomic, assign) RCChannel *channel;
- (id)initWithChannel:(RCChannel *)chan;
- (void)postMessage:(NSString *)_message withType:(RCMessageType)tr highlight:(BOOL)high;
- (void)postMessage:(NSString *)_message withType:(RCMessageType)rr highlight:(BOOL)high isMine:(BOOL)mine;
- (void)scrollToBottom;
- (void)scrollToTop;
@end
