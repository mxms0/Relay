//
//  RCDefaultMessageFormatter.h
//  Relay
//
//  Created by Max Shavrick on 6/10/14
//

#import <Foundation/Foundation.h>
#import "NSMutableAttributedString+RCAdditions.h"
#import "RCMessage.h"

@interface RCDefaultMessageFormatter : NSObject
@property (nonatomic, retain) RCMessage *message;

- (instancetype)initWithMessage:(RCMessage *)message;
- (NSString *)formattedMessage;
@end
