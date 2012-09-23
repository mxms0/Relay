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
- (NSString *)gtm_stringByUnescapingFromHTML;
- (NSString *)stringByConvertingHTMLToPlainText;
- (NSString *)stringByDecodingHTMLEntities;
- (NSString *)stringByEncodingHTMLEntities;
- (NSString *)stringByEncodingHTMLEntities:(BOOL)isUnicode;
- (NSString *)stringWithNewLinesAsBRs;
- (NSString *)stringByRemovingNewLinesAndWhitespace;
- (NSString *)stringByLinkifyingURLs;
- (NSString *)stringByStrippingTags; 
- (NSString *)stringByStrippingIRCMetadata;
@end