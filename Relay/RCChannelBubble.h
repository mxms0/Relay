//
//  RCChannelBubble.h
//  Relay
//
//  Created by Max Shavrick on 2/25/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RCChannel;
@interface RCChannelBubble : UIButton {
	BOOL isSelected;
	BOOL hasNewMessages;
	BOOL hasNewHighlights;
	id delegate;
	int _rcount;
	BOOL longPressed;
    RCChannel* channel;
}
@property (nonatomic, readonly) BOOL isSelected;
@property (nonatomic, assign) BOOL hasNewHighlights;
@property (nonatomic, readonly) int _rcount;
@property (nonatomic, assign) RCChannel* channel; // weak ref
- (id)initWithFrame:(CGRect)frame andChan:(RCChannel*)channel_;
- (void)setMentioned:(BOOL)mentioned;
- (void)setHasNewMessage:(BOOL)msgs;
- (void)_setSelected:(BOOL)_selected;
- (RCChannel*)channel;
- (void) fixColors;
@end
