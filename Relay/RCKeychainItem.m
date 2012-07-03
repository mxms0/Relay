//
//  RCKeychainItem.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCKeychainItem.h"
#import <Security/Security.h>

@implementation RCKeychainItem

- (id)initWithService:(NSString *)serv {
	if ((self = [super init])) {
		service = serv;
	}
	return self;
}

- (NSString *)stringForKey:(NSString *)key {
	OSStatus st = noErr;
	NSMutableDictionary *basicQuery = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
								(id)kSecClassGenericPassword, (id)kSecClass,
								key, (id)kSecAttrAccount,
								service, (id)kSecAttrService, nil];
	NSDictionary *result = NULL;
	NSMutableDictionary *propQuery = [[NSMutableDictionary alloc] initWithDictionary:basicQuery];
	[propQuery setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnAttributes];
	st = SecItemCopyMatching((CFDictionaryRef)propQuery, (CFTypeRef *)&result);
	[propQuery release];
	[result release];
	if (st != noErr) {
		NSLog(@"Meh %@", [NSError errorWithDomain:NSOSStatusErrorDomain code:st userInfo:nil]);
	}
	NSData *res = NULL;
	NSMutableDictionary *passQry = [[NSMutableDictionary alloc] initWithDictionary:basicQuery];
	[passQry setObject:(id)kCFBooleanTrue forKey:(id)kSecReturnData];
	st = SecItemCopyMatching((CFDictionaryRef)passQry, (CFTypeRef *)&res);
	[passQry release];
	if (st != noErr) {
		NSLog(@"Meh %@", [NSError errorWithDomain:NSOSStatusErrorDomain code:st userInfo:nil]);
	}
	NSString *pass = nil;
	if (res) {
		pass = [[NSString alloc] initWithData:res encoding:NSUTF8StringEncoding];
	}
	else {
		// crap.
	}
	[res release];
	[basicQuery release];
	return [pass autorelease];
}

- (void)setObject:(NSString *)value forKey:(NSString *)key {
	if (!value || !key) {
		return; 
		//wtf why am i doing this.. WHY WOULD I EVER PASS NIL I DON'T EVEN
	}
	NSString *pass = [self stringForKey:key];
	if (pass) {
		if ([pass isEqualToString:value]) {
			return;
		}
	}
	// if already exists, we need to just update
	// username is the key.
	OSStatus st = noErr;
	if (pass) {
		NSDictionary *qry = [[NSDictionary alloc] initWithObjectsAndKeys:(id)kSecClassGenericPassword, (id)kSecClass,
						 service, (id)kSecAttrService,
						 service, (id)kSecAttrLabel,
						 key, (id)kSecAttrAccount, nil];

		st = SecItemUpdate((CFDictionaryRef)qry, (CFDictionaryRef)[NSDictionary dictionaryWithObject:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData]);
		[qry release];
	}
	else {
		NSDictionary *qry = [[NSDictionary alloc] initWithObjectsAndKeys:(id)kSecClassGenericPassword, (id)kSecClass,
							 service, (id)kSecAttrService,
							 service, (id)kSecAttrLabel,
							 key, (id)kSecAttrAccount,
							 [value dataUsingEncoding:NSUTF8StringEncoding], (id)kSecValueData,
							 nil];
		st = SecItemAdd((CFDictionaryRef)qry, NULL);
	}
	if (st != noErr) {
		//shit.
	}
}

- (void)dealloc {
	[super dealloc];
}

@end
