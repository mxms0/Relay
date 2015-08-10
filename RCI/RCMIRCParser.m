//
//  RCMIRCParser.m
//  Relay
//
//  Created by Max Shavrick on 7/27/14.
//

#import "RCMIRCParser.h"

int strntoi(const char *restrict s, size_t maxlen, char **restrict endp) {
	int i = 0;
	int n = 0;
	while (isdigit(*s) && i < maxlen) {
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

NSString *RCStripIRCMetadataFromString(NSString *str) {
	NSData *d = [str dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
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

NSArray *RCMIRCAttributesFromString(NSString *message) {
	NSMutableArray *attrs = [NSMutableArray array];
	NSMutableDictionary *openAttrs = [NSMutableDictionary dictionary];
	
	int pos = 0;
	NSData *d = [message dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	const char *buf = d.bytes;
	int32_t len = (int32_t)[d length];
	UChar32 codepoint;
	int ii = 0; // in index
	while (ii < len) {
		U8_NEXT_UNSAFE(buf, ii, codepoint);
		switch (codepoint) {
			case RCIRCAttributeBold:
			case RCIRCAttributeItalic:
			case RCIRCAttributeUnderline: {
				NSNumber *key = @(codepoint);
				RCAttribute *a = openAttrs[key];
				if (!a) {
					a = [[[RCAttribute alloc] initWithType:(char)codepoint start:pos] autorelease];
					[attrs addObject:a];
					openAttrs[key] = a;
				} else {
					a.end = pos;
					[openAttrs removeObjectForKey:key];
				}
				break;
			}
			case RCIRCAttributeReset: {
				for (RCAttribute *a in [openAttrs allValues]) {
					a.end = pos;
				}
				[openAttrs removeAllObjects];
				break;
			}
			case RCIRCAttributeInternalNickname:
			case RCIRCAttributeColor: {
				NSNumber *key = @(codepoint);
				RCAttribute *a = openAttrs[key];
				if (a) {
					a.end = pos;
					[openAttrs removeObjectForKey:key];
				}
				char *end = NULL;
				const char *bnex = buf + ii;
				int fg = strntoi(bnex, 2, &end);
				int bg = -1;
				if(end != bnex) { // We got a colour
					if (*end == ',') { // And a comma
						bg = strntoi(end + 1, 2, &end);
					}
					ii = (int)(end - buf);
					a = [[[RCColorAttribute alloc] initWithType:(char)codepoint start:pos fg:fg bg:bg] autorelease];
					[attrs addObject:a];
					openAttrs[key] = a;
				}
				break;
			default:
				pos++;
				break;
			}
		}
	}
	
	for (RCAttribute *a in [openAttrs allValues]) {
		a.end = pos;
	}
	return [[attrs retain] autorelease];
}
