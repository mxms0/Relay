#import "RCKeychainItem.h"
#import <Security/Security.h>

@implementation RCKeychainItem

- (NSString *)objectForKey:(NSString *)key {
    NSDictionary *result;
    NSArray *keys = [[[NSArray alloc] initWithObjects: (NSString *) kSecClass, kSecAttrAccount, kSecReturnAttributes, nil] autorelease];
    NSArray *objects = [[[NSArray alloc] initWithObjects: (NSString *) kSecClassGenericPassword, key, kCFBooleanTrue, nil] autorelease];
    NSDictionary *query = [[NSDictionary alloc] initWithObjects: objects forKeys: keys];
	
    OSStatus status = SecItemCopyMatching((CFDictionaryRef) query, (CFTypeRef *) &result);
    [query release];
    if (status != noErr) {
		return nil;
	}
	else {
        NSString *value = (NSString *) [result objectForKey: (NSString *) kSecAttrGeneric];
		[value retain];
        [result release];
        return [value autorelease];
    }
}

- (BOOL)setObject:(NSString *)value forKey:(NSString *)key {
    NSString *existingValue = [self objectForKey:key];
    OSStatus status;
    if (existingValue) {
        NSArray *keys = [[[NSArray alloc] initWithObjects: (NSString *) kSecClass, kSecAttrAccount, nil] autorelease];
        NSArray *objects = [[[NSArray alloc] initWithObjects: (NSString *) kSecClassGenericPassword, key, nil] autorelease];
        NSDictionary *query = [[[NSDictionary alloc] initWithObjects: objects forKeys: keys] autorelease];
        status = SecItemUpdate((CFDictionaryRef) query, (CFDictionaryRef) [NSDictionary dictionaryWithObject:value forKey: (NSString *) kSecAttrGeneric]);
    }
	else {
		NSArray *keys = [[[NSArray alloc] initWithObjects: (NSString *) kSecClass, kSecAttrAccount, kSecAttrGeneric, nil] autorelease];
		NSArray *objects = [[[NSArray alloc] initWithObjects: (NSString *) kSecClassGenericPassword, key, value, nil] autorelease];
		NSDictionary *query = [[[NSDictionary alloc] initWithObjects: objects forKeys: keys] autorelease];
		 status = SecItemAdd((CFDictionaryRef) query, NULL);
    }
	
    // Check if the value was stored
    if (status != noErr) {
	//	NSLog(@"ERRRRRRRRR");
		return false;
    }
	else {
        return true;
    }
}

@end
