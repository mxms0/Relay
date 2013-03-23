//
//  RCXLChatController.m
//  Relay
//
//  Created by Max Shavrick on 11/9/12.
//

#import "RCXLChatController.h"

@implementation RCXLChatController

- (CGRect)frameForChatPanel {
	return CGRectMake(0, DEFAULT_NAVIGATION_BAR_HEIGHT-1, [[UIScreen mainScreen] applicationFrame].size.width, 465);
}

- (CGFloat)suggestionLocation {
	return 272;
}

@end
