//
//  RCMessageFormatter.h
//  Relay
//
//  Created by Siberia on 6/10/14.
//  Copyright (c) 2014 American Heritage School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableAttributedString+RCAdditions.h"
#import "RCMessage.h"

@interface RCMessageFormatter : NSObject
@property (nonatomic, retain) RCMessage *message;

- (id)initWithMessage:(NSString *)message;
@end
