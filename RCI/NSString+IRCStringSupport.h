//
//  NSString+IRCStringSupport.h
//  Relay
//
//  Created by Max Shavrick on 12/08/12.
//
#import <Foundation/Foundation.h>
#include <unicode/utf8.h>

int strntoi(const char *restrict s, size_t maxlen, char **restrict endp);

@interface NSString (RCAdditions)
- (NSString *)stringByStrippingIRCMetadata;
@end
