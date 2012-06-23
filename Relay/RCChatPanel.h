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

@interface NSObject (Stuff)
- (id)performSelector:(SEL)selector onThread:(NSThread *)aThread withObject:(id)p1 withObject:(id)p2 withObject:(id)p3 withObject:(id)p4;
@end

@class RCChannel;
@interface RCChatPanel : UIView <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate> {
	NSMutableArray *messages;
	RCChannel *channel;
	RCTableView *tableView;
	NSMutableString *currentWord;
	NSString *prev;
	UITextField *field;
	UIView *_bar;
	BOOL isScrolling;
}
@property (nonatomic, retain) RCTableView *tableView;
@property (nonatomic, readonly) NSMutableArray *messages;
- (void)setChannel:(RCChannel *)channel;
- (RCChannel *)channel;
- (id)initWithStyle:(UITableViewStyle)style andChannel:(RCChannel *)chan;
- (void)postMessage:(NSString *)_message withFlavor:(RCMessageFlavor)flavor highlight:(BOOL)high;
- (void)postMessage:(NSString *)_message withFlavor:(RCMessageFlavor)flavor highlight:(BOOL)high isMine:(BOOL)mine;
- (void)repositionKeyboardForUse:(BOOL)key;
- (void)setHidesEntryField:(BOOL)entry;
@end
