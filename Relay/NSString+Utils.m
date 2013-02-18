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
	if (!prefix) return nil;
	if ([self hasPrefix:prefix])
		self = [self substringFromIndex:[prefix length]];
	else return self;
	return [self recursivelyRemovePrefix:prefix];
}

- (NSString *)recursivelyRemoveSuffix:(NSString *)sfx {
	if (!sfx) return nil;
	if ([self hasSuffix:sfx])
		self = [self substringToIndex:(([self length]-1) - [sfx length])];
	else return self;
	return [self recursivelyRemovePrefix:sfx];
}

- (NSString *)base64 {
	NSData *dd = [self dataUsingEncoding:NSASCIIStringEncoding];
	const uint8_t *input = (const uint8_t *)[dd bytes];
	NSInteger length = [dd length];
	
	static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
	NSMutableData *data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
	uint8_t *output = (uint8_t *)data.mutableBytes;
	
	NSInteger i;
	for (i = 0; i < length; i += 3) {
		NSInteger value = 0;
		NSInteger j;
		for (j = i; j < (i + 3); j++) {
			value <<= 8;
			if (j < length) {
				value |= (0xFF & input[j]);
			}
		}
		NSInteger theIndex = (i / 3) * 4;
		output[theIndex + 0] = table[(value >> 18) & 0x3F];
		output[theIndex + 1] = table[(value >> 12) & 0x3F];
		output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
		output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
	}
	
	return [[[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding] autorelease];
}

@end
