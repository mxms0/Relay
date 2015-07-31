//
//  RCCommandEngine.h
//  Relay
//
//  Created by Max Shavrick on 10/15/12.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "RCChannel.h"

@class RCNetwork, RCChannel;
@interface RCCommandEngine : NSObject {
	NSMutableDictionary *cmds;
}
+ (id)sharedInstance;
- (void)handleCommand:(NSString *)command fromNetwork:(RCNetwork *)net forChannel:(RCChannel *)chan;
- (void)registerSelector:(SEL)selector forCommands:(id)commands usingClass:(Class)mee;
- (NSArray *)commandsMatchingString:(NSString *)str;
@end
