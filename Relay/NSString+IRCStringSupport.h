//
//  NSString+IRCStringSupport.h
//  Relay
//
//  Created by qwertyoruiop on 12/08/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//
#import <Foundation/Foundation.h>

// Dependant upon GTMNSString+HTML

@interface NSString (HTML)

/// Get a string where internal characters that need escaping for HTML are escaped 
//
///  For example, '&' become '&amp;'. This will only cover characters from table
///  A.2.2 of http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
///  which is what you want for a unicode encoded webpage. If you have a ascii
///  or non-encoded webpage, please use stringByEscapingAsciiHTML which will
///  encode all characters.
///
/// For obvious reasons this call is only safe once.
//
//  Returns:
//    Autoreleased NSString
//
- (NSString *)gtm_stringByEscapingForHTML;

/// Get a string where internal characters that need escaping for HTML are escaped 
//
///  For example, '&' become '&amp;'
///  All non-mapped characters (unicode that don't have a &keyword; mapping)
///  will be converted to the appropriate &#xxx; value. If your webpage is
///  unicode encoded (UTF16 or UTF8) use stringByEscapingHTML instead as it is
///  faster, and produces less bloated and more readable HTML (as long as you
///  are using a unicode compliant HTML reader).
///
/// For obvious reasons this call is only safe once.
//
//  Returns:
//    Autoreleased NSString
//
- (NSString *)gtm_stringByEscapingForAsciiHTML;

/// Get a string where internal characters that are escaped for HTML are unescaped 
//
///  For example, '&amp;' becomes '&'
///  Handles &#32; and &#x32; cases as well
///
//  Returns:
//    Autoreleased NSString
//
- (NSString *)gtm_stringByUnescapingFromHTML;

// Strips HTML tags & comments, removes extra whitespace and decodes HTML character entities.
- (NSString *)stringByConvertingHTMLToPlainText;

// Decode all HTML entities using GTM.
- (NSString *)stringByDecodingHTMLEntities;

// Encode all HTML entities using GTM.
- (NSString *)stringByEncodingHTMLEntities;

// Minimal unicode encoding will only cover characters from table
// A.2.2 of http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
// which is what you want for a unicode encoded webpage.
- (NSString *)stringByEncodingHTMLEntities:(BOOL)isUnicode;

// Replace newlines with <br /> tags.
- (NSString *)stringWithNewLinesAsBRs;

// Remove newlines and white space from string.
- (NSString *)stringByRemovingNewLinesAndWhitespace;

// Wrap plain URLs in <a href="..." class="linkified">...</a>
//  - Ignores URLs inside tags (any URL beginning with =")
//  - HTTP & HTTPS schemes only
//  - Only works in iOS 4+ as we use NSRegularExpression (returns self if not supported so be careful with NSMutableStrings)
//  - Expression: (?<!=")\b((http|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&amp;:/~\+#]*[\w\-\@?^=%&amp;/~\+#])?)
//  - Adapted from http://regexlib.com/REDetails.aspx?regexp_id=96
- (NSString *)stringByLinkifyingURLs;

// DEPRECIATED - Please use NSString stringByConvertingHTMLToPlainText
- (NSString *)stringByStrippingTags __attribute__((deprecated));
- (NSString*)stringByStrippingIRCMetadata;
@end