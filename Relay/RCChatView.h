//
//  RCScrollView.h
//  Relay
//
//  Created by Max Shavrick on 7/27/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>

static inline BOOL readNumber(int* num, BOOL* isThereComma, unsigned int* size_of_num, NSString* istring);

static inline BOOL readNumber(int* num, BOOL* isThereComma, unsigned int* size_of_num, NSString* istring) {
	if ([istring length] - *size_of_num) {
		unichar n1 = [istring characterAtIndex:*size_of_num];
		NSLog(@"%c!", n1);
		if ('0' <= n1 && n1 <= '9' && (n1 & 0xFF00) == 0) {
			NSLog(@"-> %c!", n1);
			*size_of_num = (*size_of_num) + 1;
			*num = n1 - '0';
			if ([istring length] - *size_of_num) {
				unichar n2 = [istring characterAtIndex:*size_of_num];
				if ('0' <= n2 && n2 <= '9' && (n2 & 0xFF00) == 0) {
					*size_of_num = (*size_of_num) + 1;
					*num =  (n1 - '0') * 10 +  (n2 - '0');
					if ([istring length] - *size_of_num) {
						unichar n3 = [istring characterAtIndex:*size_of_num];
						if ( n3 == ','  && (n3 & 0xFF00) == 0 && *isThereComma == YES) {
							*size_of_num = (*size_of_num) + 1;
							*isThereComma = YES; // nullop basically.
							return YES;
						}
						else {
							*isThereComma = NO;
							return YES;
						}
					}
				}
				else if ( n2 == ',' && *isThereComma == YES) {
					*size_of_num = (*size_of_num) + 1;
					*isThereComma = YES; // nullop basically.
					return YES;
				}
				else {
					*isThereComma = NO;
					return YES;
				}
			}
		}
		else {
			NSLog(@"no numbers here!");
			*isThereComma = NO;
			return NO;
		}
	}
	else {
		NSLog(@"no numbers here!");
		*isThereComma = NO;
		return NO;
	}
	return NO;
}

enum RCIRCAttribute {
    RCIRCAttributeColor = 0x03,
    RCIRCAttributeBold = 0x02,
    RCIRCAttributeReset = 0x0F,
    RCIRCAttributeItalic = 0x16,
    RCIRCAttributeUnderline = 0x1F,
    RCIRCAttributeInternalNickname = 0x04
};

@class RCMessageFormatter;
@interface RCChatView : UIWebView <UIScrollViewDelegate> {
    int msgs;
    BOOL isModifying;
    BOOL canModify;
    id chatpanel;
    NSMutableArray *preloadPool;
}
@property(assign) id chatpanel;

- (void)layoutMessage:(RCMessageFormatter *)ms;
- (void)scrollToBottom;
NSString *colorForIRCColor(char irccolor);
@end
