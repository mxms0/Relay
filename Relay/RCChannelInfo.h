//
//  RCChannelInfo.h
//  Relay
//
//  Created by Max Shavrick on 8/18/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCChannelInfo : NSObject {
	int userCount;
	NSString *topic;
	NSString *channel;
}
@property (nonatomic, assign) int userCount;
@property (nonatomic, retain) NSString *topic;
@property (nonatomic, retain) NSString *channel;

@end
