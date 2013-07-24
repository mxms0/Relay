//
//  RCOperation.h
//  Relay
//
//  Created by Max Shavrick on 7/23/13.
//

#import <Foundation/Foundation.h>
#import "RCChannelListViewCard.h"

@interface RCOperation : NSOperation {
	BOOL executing;
	BOOL finished;
	BOOL cancelled;
}
@property (nonatomic, assign) RCChannelListViewCard *delegate;
@property (nonatomic, assign) BOOL cancelled;
- (void)finish;
@end
