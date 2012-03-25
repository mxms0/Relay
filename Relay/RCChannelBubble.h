//
//  RCChannelBubble.h
//  Relay
//
//  Created by Max Shavrick on 2/25/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCChannelBubble : UIButton {
	BOOL _selected;
	BOOL hasNew;
	BOOL _highlighted;
	id delegate;
	int _index;
	int _rcount;
}
@property (nonatomic, readonly) BOOL _selected;
@property (nonatomic, assign) BOOL _highlighted;
@property (nonatomic, readonly) int _rcount;
- (void)setMentioned:(BOOL)mentioned;
- (void)setHasNewMessage:(BOOL)msgs;
- (void)_setSelected:(BOOL)_selected;
- (void)_classify:(int)f;
@end
