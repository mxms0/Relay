//
//  RCChannel.h
//  Relay
//
//  Created by James Long on 24/12/2011.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCChannel : NSObject {
	NSString *name;
}
- (id)initWithRoomName:(NSString *)_name;
- (void)messageRecieved:(NSString *)message from:(NSString *)from;
@end
