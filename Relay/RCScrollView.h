//
//  RCScrollView.h
//  Relay
//
//  Created by Max Shavrick on 7/27/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCMessageFormatter;
@interface RCScrollView : UIScrollView <UIScrollViewDelegate> {
	float y;
	NSMutableAttributedString *stringToDraw;
	BOOL shouldScroll;
}

- (void)layoutMessage:(RCMessageFormatter *)ms;

@end
