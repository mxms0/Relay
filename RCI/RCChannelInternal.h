//
//  RCChannelInternal.h
//  Relay IRC
//
//  Created by Max Shavrick on 2/15/16.
//  Copyright © 2016 Mxms. All rights reserved.
//

#ifndef RCChannelInternal_h
#define RCChannelInternal_h

#import "RCChannel.h"

@interface RCChannel ()
- (void)setUserJoined:(NSString *)joined;
- (void)setUserLeft:(NSString *)left;

- (void)receivedMessage:(id)_message from:(NSString *)from time:(NSString *)time_ type:(RCMessageType)type;
- (void)receivedMessage:(RCMessage *)message;
@end

#endif /* RCChannelInternal_h */
