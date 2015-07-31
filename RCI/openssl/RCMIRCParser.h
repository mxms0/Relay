//
//  RCMIRCParser.h
//  Relay
//
//  Created by Max Shavrick on 7/27/14.
//	99% written by Dustin Howett

typedef enum RCIRCAttribute {
	RCIRCAttributeColor = 0x03,
	RCIRCAttributeBold = 0x02,
	RCIRCAttributeReset = 0x0F,
	RCIRCAttributeItalic = 0x16,
	RCIRCAttributeUnderline = 0x1F,
	RCIRCAttributeInternalNickname = 0x04
} RCIRCAttribute;

#include <unicode/utf8.h>
#import "RCAttribute.h"
#import "RCColorAttribute.h"

int strntoi(const char *restrict s, size_t maxlen, char **restrict endp);
NSString *RCStripIRCMetadataFromString(NSString *str);
// returns string without mirc characters
NSArray *RCMIRCAttributesFromString(NSString *str);
// returns array of all RCAttributes