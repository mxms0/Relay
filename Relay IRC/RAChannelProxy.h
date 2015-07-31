//
//  RAChannelProxy.h
//  Relay IRC
//
//  Created by Max Shavrick on 7/26/15.
//  Copyright (c) 2015 Mxms. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RCChannel;
@interface RAChannelProxy : NSObject {
	NSMutableArray<NSString *> *messages;
}
@property (nonatomic, unsafe_unretained) RCChannel *channel;
- (instancetype)initWithChannel:(RCChannel *)channel;
- (void)addMessage:(NSString *)message;
- (NSMutableArray<NSString *> *)messages;
@end
