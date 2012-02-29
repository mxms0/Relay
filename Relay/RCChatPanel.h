//
//  RCChatPanel.h
//  Relay
//
//  Created by Max Shavrick on 2/17/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCChatCell.h"
#import "RCMessage.h"

@class RCChannel;
@interface RCChatPanel : UIView <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	NSMutableArray *messages;
	RCChannel *channel;
	UITableView *tableView;
	UITextField *field;
	UIToolbar *_bar;
}
@property (nonatomic, retain) RCChannel *channel;
@property (nonatomic, retain) UITableView *tableView;
- (id)initWithStyle:(UITableViewStyle)style andChannel:(RCChannel *)chan;
- (void)postMessage:(NSString *)message withFlavor:(RCMessageFlavor)flavor isHighlight:(BOOL)high;
- (void)repositionKeyboardForUse:(BOOL)key;
- (void)setHidesEntryField:(BOOL)entry;
@end
