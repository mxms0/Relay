//
//  RCAttribute.h
//  Relay
//
//  Created by Max Shavrick on 7/27/14.
//

#import <Foundation/Foundation.h>

typedef enum RCIRCAttribute {
	RCIRCAttributeColor = 0x03,
	RCIRCAttributeBold = 0x02,
	RCIRCAttributeReset = 0x0F,
	RCIRCAttributeItalic = 0x16,
	RCIRCAttributeUnderline = 0x1F,
	RCIRCAttributeInternalNickname = 0x04
} RCIRCAttribute;

@interface RCAttribute : NSObject {
	RCIRCAttribute _type;
	int _start, _end;
}
@property (nonatomic, readonly) int start;
@property (nonatomic, assign) int end;
@property (nonatomic, readonly) RCIRCAttribute type;
- (id)initWithType:(RCIRCAttribute)typ start:(int)pos;
@end

/* ::: NOTES :::
 * \x03 - begin/end color segment
 * \x02 - begin/end bold segment
 * \x16 - begin/end italics segment
 * \x1F - begin/end underline segment
 * \x30 - White
 * \x31 - Black
 * \x32 - Blue
 * \x33 - Green
 * \x34 - Light Red
 * \x35 - Brown
 * \x36 - Purple
 * \x37 - Orange
 * \x38 - Yellow
 * \x39 - Light Green
 * \x31\x30 - Cyan
 * \x31\x31 - Light Cyan
 * \x31\x32 - Light Blue
 * \x31\x33 - Pink
 * \x31\x34 - Gray
 * \x31\x35 - Light Gray
 */
