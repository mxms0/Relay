//
//  RCScrollView.h
//  Relay
//
//  Created by Max Shavrick on 7/27/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCMessage;
@interface RCScrollView : UIScrollView {
	float y;
}

- (void)layoutMessage:(RCMessage *)ms;

@end
