//
//  RCKeychainItem.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCKeychainItem.h"
#import <Security/Security.h>

@implementation RCKeychainItem

- (id)initWithIdentifier:(NSString *)ident accessGroup:(NSString *)group {
	if ((self = [super init])) {
		genericQuery = [[NSMutableDictionary alloc] initWithObjectsAndKeys:(id)kSecClassGenericPassword, (id)kSecClass, ident, (id)kSecAttrGeneric, (id)kSecMatchLimitOne, (id)kSecMatchLimit, (id)kCFBooleanTrue, (id)kSecReturnAttributes, nil];
#if !TARGET_IPHONE_SIMULATOR
		if (group) {
			[genericQuery setObject:group forKey:(id)kSecAttrAccessGroup];
		}
#endif
		NSDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:genericQuery];
		NSMutableDictionary *output = nil;
		if (!SecItemCopyMatching((CFDictionaryRef)tmp, (CFTypeRef *)&output) == noErr) {
			[self resetKeychain];
			[data setObject:ident forKey:(id)kSecAttrGeneric];
#if !TARGET_IPHONE_SIMULATOR
			if (group) {
				[data setObject:group forKey:(id)kSecAttrAccessGroup];
			}
#endif
		}
		else {
			data = [self secDictionaryToBasicDictionary:output];
		}
		[output release];
	}
	return self;
}

- (NSMutableDictionary *)basicDictionaryToSecDictionary:(NSDictionary *)oo {
	NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithDictionary:oo];
	[ret setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	NSString *pass = [oo objectForKey:(id)kSecValueData];
	[ret setObject:[pass dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];
	return ret;
}

- (NSMutableDictionary *)secDictionaryToBasicDictionary:(NSDictionary *)oo {
	NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithDictionary:oo];
	[ret setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	[ret setObject:(id)kSecClassGenericPassword forKey:(id)kSecClass];
	NSData *passData = nil;
	if (SecItemCopyMatching((CFDictionaryRef)ret, (CFTypeRef *)&passData) == noErr) {
		[ret removeObjectForKey:(id)kSecReturnData];
		NSString *pass = [[NSString alloc] initWithBytes:[passData bytes] length:[passData length] encoding:NSUTF8StringEncoding];
		[ret setObject:pass forKey:(id)kSecValueData];
		[pass release];
	}
	else {
		NSLog(@"fuckme");
	}
	[passData release];
	return ret;
}

- (id)objectForKey:(NSString *)key {
	return [data objectForKey:key];
}

- (void)setObject:(NSString *)value forKey:(NSString *)key {
	if (!value) return;
	id _current = [data objectForKey:key];
	if (![_current isEqual:value]) {
		[data setObject:value forKey:key];
		[self writeKeychain];
	}
}

- (void)writeKeychain {
	NSDictionary *attributes = nil;
	NSMutableDictionary *upd = nil;
	OSStatus st;
	OSStatus rts = SecItemCopyMatching((CFDictionaryRef)genericQuery, (CFTypeRef *)&attributes);
	if (attributes) NSLog(@"hi%@", attributes);
	NSLog(@"hi %d", rts);
	if (rts == noErr) {
		upd = [NSMutableDictionary dictionaryWithDictionary:attributes];
		[upd setObject:[genericQuery objectForKey:(id)kSecClass] forKey:(id)kSecClass];
		NSMutableDictionary *tmp = [self basicDictionaryToSecDictionary:data];
		[tmp removeObjectForKey:(id)kSecClass];
#if TARGET_IPHONE_SIMULATOR
		[tmp removeObjectForKey:(id)kSecAttrAccessGroup];
#endif
		st = SecItemUpdate((CFDictionaryRef)upd, (CFDictionaryRef)tmp);
				[self logStatus:st];
	}
	else {
		st = SecItemAdd((CFDictionaryRef)[self basicDictionaryToSecDictionary:data], NULL);
		if (st == -25299) {
			NSLog(@"hi alryd found");
		}
	}
}
- (void)logStatus:(OSStatus)st {
	NSLog(@"ERR-OR %d", st);
}

- (void)resetKeychain {
	OSStatus st = noErr;
	if (!data) {
		data = [[[NSMutableDictionary alloc] init] autorelease];
	}
	else {
		NSMutableDictionary *tmpDict = [self basicDictionaryToSecDictionary:data];
		st = SecItemDelete((CFDictionaryRef)tmpDict);
		[self logStatus:st];
	}
	[data setObject:@"" forKey:(id)kSecAttrAccount];
	[data setObject:@"" forKey:(id)kSecAttrLabel];
	[data setObject:@"" forKey:(id)kSecAttrDescription];
	[data setObject:@"" forKey:(id)kSecValueData];
}

- (void)dealloc {
	[genericQuery release];
	[super dealloc];
}

@end
