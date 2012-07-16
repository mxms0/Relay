//
//  RCDateManager.h
//  Relay
//
//  Created by Max Shavrick on 7/16/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCDateManager : NSObject {
	NSDateFormatter *formatter;
}
+ (id)sharedInstance;
- (NSString *)currentDateAsString;

@end
