//
//  RCScrollView.h
//  Relay
//
//  Created by Max Shavrick on 7/27/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>

static BOOL readNumber(int* num, BOOL* isThereComma, unsigned int* size_of_num, NSString* istring);

enum RCIRCAttribute {
    RCIRCAttributeColor = 0x03,
    RCIRCAttributeBold = 0x02,
    RCIRCAttributeReset = 0x0F,
    RCIRCAttributeItalic = 0x16,
    RCIRCAttributeUnderline = 0x1F
};

@class RCMessageFormatter;
@interface RCScrollView : UIWebView <UIScrollViewDelegate> {
	float y;
	NSMutableAttributedString *stringToDraw;
	BOOL shouldScroll;
    dispatch_queue_t scrollViewMessageQueue;
    int msgs;
    BOOL isModifying;
    BOOL canModify;
    id chatpanel;
}
@property(assign) id chatpanel;

- (void)layoutMessage:(RCMessageFormatter *)ms;
- (void)scrollToBottom;
@end
