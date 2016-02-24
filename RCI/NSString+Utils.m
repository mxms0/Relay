//
//  NSString+Comparing.m
//  Relay
//
//  Created by Max Shavrick on 2/19/12.
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

- (NSString *)base64 {
	NSString *base64CharacterList = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	NSInteger inputLength = self.length;
	NSMutableString *encodedResult = [NSMutableString string];
	
	unsigned char *is = (unsigned char *)[self cStringUsingEncoding:[NSString defaultCStringEncoding]];
	unsigned long data;
	unsigned long di;
	
	for (NSInteger i = 0; i < inputLength; i += 3) {
		data  = (*is++ << 16);
		data += (*is++ << 8);
		data += (*is++);
		
		for (NSInteger d = 0; d < 4; d++) {
			if (d >= 2 && (i + d) > inputLength) {
				[encodedResult appendString:@"="];
			}
			else {
				di = ((data >> 18) & 63);
				[encodedResult appendFormat:@"%C", [base64CharacterList characterAtIndex:di]];
			}
			data = (data << 6);
		}
	}
	return encodedResult;
}

@end
