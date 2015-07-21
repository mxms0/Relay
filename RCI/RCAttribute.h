//
//  RCAttribute.h
//  Relay
//
//  Created by Siberia on 7/27/14.
//  Copyright (c) 2014 American Heritage School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCI.h"

@interface RCAttribute : NSObject {
	RCIRCAttribute _type;
	int _start, _end;
}
@property (nonatomic, readonly) int start;
@property (nonatomic, assign) int end;
@property (nonatomic, readonly) RCIRCAttribute type;
- (id)initWithType:(RCIRCAttribute)typ start:(int)pos;
@end
