//
//  NSString+Comparing.h
//  Relay
//
//  Created by Max Shavrick on 2/19/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Comparing)
- (BOOL)isEqualToStringNoCase:(NSString *)string;
- (BOOL)hasPrefixNoCase:(NSString *)string;
- (BOOL)hasSuffixNoCase:(NSString *)string;
@end
