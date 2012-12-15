//
//  NSString+IRCStringSupport.h
//  Relay
//
//  Created by qwertyoruiop on 12/08/12.
//
#import <Foundation/Foundation.h>

@interface NSString (HTML)

- (NSString *)gtm_stringByEscapingForHTML;
- (NSString *)gtm_stringByEscapingForAsciiHTML;
- (NSString *)stringWithNewLinesAsBRs;
- (NSString *)stringByLinkifyingURLs;
- (NSString *)stringByEncodingHTMLEntities:(BOOL)k;
- (NSString *)stringByStrippingIRCMetadata;
@end