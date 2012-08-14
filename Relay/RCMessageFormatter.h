//
//  RCMessage.h
//  Relay
//
//  Created by Max Shavrick on 2/20/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "RCChatPanel.h"

@interface RCMessageFormatter : NSObject {
	NSString *string;
    BOOL highlight;
    BOOL shouldColor;
}
@property(retain) NSString* string;
@property(assign) BOOL highlight;
@property(assign) BOOL shouldColor;
- (id)initWithMessage:(NSString *)msg isOld:(BOOL)old isMine:(BOOL)m isHighlight:(BOOL)hh type:(RCMessageType)flavor;
- (NSString *)string;
@end
