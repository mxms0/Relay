//
//  RCKeychainItem.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCKeychainItem.h"
#import <Security/Security.h>

@implementation RCKeychainItem

- (id)initWithIdentifier:(NSString *)ident {
	if ((self = [super init])) {
		base = [[NSMutableDictionary alloc] init];
		[base setObject:(id)kSecClassInternetPassword forKey:(id)kSecClass];
		[base setObject:ident forKey:(id)kSecAttrServer];
	}
	return self;
}

- (NSString *)objectForKey:(NSString *)key {
	if (!key) return nil;
	NSMutableDictionary *cpy = [NSMutableDictionary dictionaryWithDictionary:base];
	NSData *ret;
	[cpy setObject:(id)kSecMatchLimitOne forKey:(id)kSecMatchLimit];
	[cpy setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	OSStatus st = SecItemCopyMatching((CFDictionaryRef)cpy, (CFTypeRef *)&ret);
	if (st == noErr) {
		NSString *pass = [NSString stringWithUTF8String:[ret bytes]];
		return pass;
	}
	return nil;
}

- (void)setObject:(NSString *)value forKey:(NSString *)key {
	if (!key) return;
	NSData *pd = [value dataUsingEncoding:NSUTF8StringEncoding];
	[base setObject:pd forKey:(id)kSecValueData];
	OSStatus st = SecItemAdd((CFDictionaryRef)base, NULL);
	if (st == errSecDuplicateItem) {
		[base removeObjectForKey:(id)kSecValueData];
		NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithObjectsAndKeys:pd, (id)kSecValueData, nil];
		SecItemUpdate((CFDictionaryRef)base, (CFDictionaryRef)tmp);
		
	}
}

- (void)removeObject:(NSString *)obj forKey:(NSString *)key {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:(id)kSecClassInternetPassword, (id)kSecClass, (id)[base objectForKey:(id)kSecAttrServer], (id)kSecAttrServer, nil];
	SecItemDelete((CFDictionaryRef)dict);
}

@end
