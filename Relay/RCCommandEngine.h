//
//  RCCommandEngine.h
//  Relay
//
//  Created by Max Shavrick on 10/15/12.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class RCNetwork;
@interface RCCommandEngine : NSObject {
	NSMutableDictionary *cmds;
}
+ (id)sharedInstance;
- (void)handleCommand:(NSString *)command fromNetwork:(RCNetwork *)net;
- (void)registerSelector:(SEL)selector forCommands:(id)commands usingClass:(Class)mee;
@end
