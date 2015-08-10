//
//  RCMessage.h
//  Relay
//
//  Created by Max Shavrick on 7/18/13.
//	no correlation to RCMessageFormatter

#import <Foundation/Foundation.h>

@interface RCMessage : NSObject {
	NSString *_numeric;
	NSString *_sender;
	NSString *_destination;
	NSString *_message;
}
@property (nonatomic, retain) NSString *numeric;
@property (nonatomic, retain) NSString *sender;
@property (nonatomic, retain) NSString *destination;
@property (nonatomic, retain) NSString *message;
// message is the segment after the ":" character
@property (nonatomic, retain) NSDictionary *messageTags;
- (id)initWithString:(NSString *)string;
- (void)parse;
- (NSString *)parameterAtIndex:(int)index;
@end
