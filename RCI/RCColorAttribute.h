//
//  RCColorAttribute.h
//  Relay
//
//  Created by Max Shavrick on 7/27/14.
//

#import "RCAttribute.h"

@interface RCColorAttribute : RCAttribute {
	int _fg, _bg;
}
@property (nonatomic, readonly) int fg;
@property (nonatomic, readonly) int bg;
- (id)initWithType:(RCIRCAttribute)typ start:(int)pos fg:(int)fg bg:(int)bg;
@end
