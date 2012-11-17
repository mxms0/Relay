//
//  RCXLChatController.m
//  Relay
//
//  Created by Max Shavrick on 11/9/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCXLChatController.h"

@implementation RCXLChatController

- (CGRect)frameForChatPanel {
	if ([self isLandscape])
		return CGRectMake(0, 43, 480, 213);
	else
		return CGRectMake(0, 43, 320, 465);
}

@end
