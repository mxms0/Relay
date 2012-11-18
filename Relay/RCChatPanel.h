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
#import "RCChatView.h"

@class RCChannel;
@interface RCChatPanel : UIView <UITextFieldDelegate> {
	@public
	RCChatView *mainView;
	RCChannel *channel;
	NSMutableString *currentWord;
	NSString *prev;
	UITextField *field;
	RCTextFieldBackgroundView *_bar;
	CGFloat chatViewHeights[2];
}
@property (nonatomic, assign) RCChannel *channel;
@property (nonatomic, readonly) NSMutableArray *messages;
@property (nonatomic, readonly) RCChatView *mainView;

- (id)initWithStyle:(UITableViewStyle)style andChannel:(RCChannel *)chan;
- (void)postMessage:(NSString *)_message withType:(RCMessageType)tr highlight:(BOOL)high;
- (void)postMessage:(NSString *)_message withType:(RCMessageType)rr highlight:(BOOL)high isMine:(BOOL)mine;
- (void)repositionKeyboardForUse:(BOOL)key animated:(BOOL)an;
- (void)setHidesEntryField:(BOOL)entry;
- (void)becomeFirstResponderNoAnimate;
- (void)setEntryFieldEnabled:(BOOL)en;
- (void)didPresentView;
@end
