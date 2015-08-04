//
//  RCMessage.h
//  Relay
//
//  Created by Max Shavrick on 7/18/13.
//	no correlation to RCMessageFormatter

#import <Foundation/Foundation.h>

@interface RCMessage : NSObject {
	NSArray *messageParameters;
	@public
	NSString *message;
}
@property (nonatomic, retain) NSString *numeric;
@property (nonatomic, retain) NSString *sender;
@property (nonatomic, retain) NSDictionary *tags;
- (id)initWithString:(NSString *)string;
- (void)parse;
- (NSString *)parameterAtIndex:(int)index;
- (NSString *)humanReadableString;
@end
