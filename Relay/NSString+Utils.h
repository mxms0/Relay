//
//  NSString+Comparing.h
//  Relay
//
//  Created by Max Shavrick on 2/19/12.
//

#import <Foundation/Foundation.h>

@interface NSString (RCUtils)
- (BOOL)isEqualToStringNoCase:(NSString *)string;
- (BOOL)hasPrefixNoCase:(NSString *)string;
- (BOOL)hasSuffixNoCase:(NSString *)string;
- (NSString *)recursivelyRemovePrefix:(NSString *)prefix;
- (NSString *)base64;
@end
