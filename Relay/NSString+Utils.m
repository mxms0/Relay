//
//  NSString+Comparing.m
//  Relay
//
//  Created by Max Shavrick on 2/19/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (RCUtils)
- (BOOL)isEqualToStringNoCase:(NSString *)string {
	return (CFStringCompare((CFStringRef)self, (CFStringRef)string, kCFCompareCaseInsensitive) == kCFCompareEqualTo);
}

- (BOOL)hasPrefixNoCase:(NSString *)string {
	return ([self rangeOfString:string options:(NSCaseInsensitiveSearch | NSAnchoredSearch)].location != NSNotFound);
}

- (BOOL)hasSuffixNoCase:(NSString *)string {
	return ([self rangeOfString:string options:(NSCaseInsensitiveSearch | NSAnchoredSearch | NSBackwardsSearch)].location != NSNotFound);
}

- (NSString *)recursivelyRemovePrefix:(NSString *)prefix {
	if (!prefix || !self) return nil;
	
    if ([self hasPrefix:prefix])
		self = [self substringFromIndex:[prefix length]];
	else
        return self;
	
    return [self recursivelyRemovePrefix:prefix];
}
@end
