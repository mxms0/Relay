//
//  RCAttribute.h
//  Relay
//
//  Created by Max Shavrick on 7/27/14.
//

#import <Foundation/Foundation.h>

@interface RCAttribute : NSObject {
	RCIRCAttribute _type;
	int _start, _end;
}
@property (nonatomic, readonly) int start;
@property (nonatomic, assign) int end;
@property (nonatomic, readonly) RCIRCAttribute type;
- (id)initWithType:(RCIRCAttribute)typ start:(int)pos;
@end
