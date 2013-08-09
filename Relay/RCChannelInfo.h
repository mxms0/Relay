//
//  RCChannelInfo.h
//  Relay
//
//  Created by Max Shavrick on 8/18/12.
//

#import <Foundation/Foundation.h>

@interface RCChannelInfo : NSObject {
	int userCount;
	BOOL isAlreadyInChannel;
	NSString *topic;
	NSString *channel;
}
@property (nonatomic, assign) int userCount;
@property (nonatomic, assign) BOOL isAlreadyInChannel;
@property (nonatomic, retain) NSString *topic;
@property (nonatomic, retain) NSString *channel;
@end
