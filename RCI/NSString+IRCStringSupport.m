//
//  NSString+IRCStringSupport.m
//  Relay
//
//  Created by Max Shavrick on 12/08/12.
//

#import "NSString+IRCStringSupport.h"
#import <CoreText/CoreText.h>
#import "RCI.h"

@implementation NSString (RCAdditions)

// Only for positive integers, only up to maxlen length
int strntoi(const char *restrict s, size_t maxlen, char **restrict endp) {
	int i = 0;
	int n = 0;
	while(isdigit(*s) && i < maxlen) {
		n *= 10;
		n += *s - '0';
		++i;
		s++;
	}
	if(endp != NULL) {
		*endp = (char *)s;
	}
	return n;
}

- (NSString *)stringByStrippingIRCMetadata {
	NSData *d = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
	const char *buf = d.bytes;
	int32_t len = (int32_t)[d length];
	char *s = (char *)malloc(len);
	int ii = 0; // in index
	int oi = 0; // out index
	UChar32 codepoint;
	while (ii < len) {
		U8_NEXT_UNSAFE(buf, ii, codepoint);
		switch (codepoint) {
			case RCIRCAttributeBold:
			case RCIRCAttributeItalic:
			case RCIRCAttributeUnderline:
			case RCIRCAttributeReset:
				break;
			case RCIRCAttributeInternalNickname:
			case RCIRCAttributeColor: {
				char *end = NULL;
				const char *bnex = buf + ii;
				strntoi(bnex, 2, &end);
				if(end != bnex) { // We got a colour
					if(*end == ',') { // And a comma
						strntoi(end + 1, 2, &end);
					}
					ii = (int)(end - buf);
				}
				break;
			}
			default:
				U8_APPEND_UNSAFE(s, oi, codepoint);
		}
	}
	return [[[NSString alloc] initWithBytesNoCopy:s length:oi encoding:NSUTF8StringEncoding freeWhenDone:YES] autorelease];
}
@end
