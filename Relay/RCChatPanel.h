//
//  RCChatPanel.h
//  Relay
//
//  Created by Max Shavrick on 2/17/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCTableView.h"
#import "RCTextField.h"
#import "RCMessageFormatter.h"
#import "RCTextFieldBackgroundView.h"
#import "RCScrollView.h"

@class RCChannel;
@interface RCChatPanel : UIView <UITextFieldDelegate> {
	RCScrollView *mainView;
	RCChannel *channel;
	NSMutableString *currentWord;
	NSString *prev;
	UITextField *field;
	RCTextFieldBackgroundView *_bar;
}
@property (nonatomic, assign) RCChannel *channel;
@property (nonatomic, readonly) NSMutableArray *messages;

- (id)initWithStyle:(UITableViewStyle)style andChannel:(RCChannel *)chan;
- (void)postMessage:(NSString *)_message withType:(RCMessageType)tr highlight:(BOOL)high;
- (void)postMessage:(NSString *)_message withType:(RCMessageType)rr highlight:(BOOL)high isMine:(BOOL)mine;
- (void)repositionKeyboardForUse:(BOOL)key animated:(BOOL)an;
- (void)setHidesEntryField:(BOOL)entry;
- (void)becomeFirstResponderNoAnimate;
- (void)didPresentView;
@end
