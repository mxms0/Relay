//
//  RCBarManager.h
//  Relay
//
//  Created by Max Shavrick on 3/23/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCBarGroup.h"

@interface RCBarManager : NSObject {
	RCBarGroup *leftGroup;
	RCBarGroup *rightGroup;
}
@property (nonatomic, readonly) RCBarGroup *leftGroup;
@property (nonatomic, readonly) RCBarGroup *rightGroup;
@end
