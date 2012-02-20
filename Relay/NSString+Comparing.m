//
//  NSString+Comparing.m
//  Relay
//
//  Created by Max Shavrick on 2/19/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "NSString+Comparing.h"

@implementation NSString (Comparing)

- (BOOL)isEqualToStringNoCase:(NSString *)string {
	return [[self lowercaseString] isEqualToString:[string lowercaseString]];
}

- (BOOL)hasPrefixNoCase:(NSString *)string {
	return [[self lowercaseString] hasPrefix:[string lowercaseString]];
}

- (BOOL)hasSuffixNoCase:(NSString *)string {
	return [[self lowercaseString] hasSuffix:[string lowercaseString]];
}

@end
