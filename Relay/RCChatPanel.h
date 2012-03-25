//
//  RCChatPanel.h
//  Relay
//
//  Created by Max Shavrick on 2/17/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCChatCell.h"
#import "RCTableView.h"
#import "RCMessage.h"

@interface UIKeyboardImpl : UIView 
+ (id)sharedInstance;
@end

@class RCChannel;
@interface RCChatPanel : UIView <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	NSMutableArray *messages;
	RCChannel *channel;
	RCTableView *tableView;
	NSThread *sendThread;
	NSMutableString *currentWord;
	NSString *prev;
	UITextField *field;
	UIView *_bar;
}
@property (nonatomic, retain) RCChannel *channel;
@property (nonatomic, retain) RCTableView *tableView;
@property (nonatomic, readonly) NSMutableArray *messages;
- (id)initWithStyle:(UITableViewStyle)style andChannel:(RCChannel *)chan;
- (void)postMessage:(NSString *)_message withFlavor:(RCMessageFlavor)flavor highlight:(BOOL)high;
- (void)postMessage:(NSString *)_message withFlavor:(RCMessageFlavor)flavor highlight:(BOOL)high isMine:(BOOL)mine;
- (void)repositionKeyboardForUse:(BOOL)key;
- (void)setHidesEntryField:(BOOL)entry;
@end
