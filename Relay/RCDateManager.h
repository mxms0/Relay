//
//  RCDateManager.h
//  Relay
//
//  Created by Max Shavrick on 7/16/12.
//

#import <Foundation/Foundation.h>

@interface RCDateManager : NSObject {
	NSDateFormatter *formatter;
}
+ (id)sharedInstance;
- (NSString *)currentDateAsString;

@end
