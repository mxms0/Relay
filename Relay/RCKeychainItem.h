//
//  RCKeychainItem.h
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//	This code is based on apple's GenericKeychain example.
//	i don't think above çovers me legally. :P

#import <UIKit/UIKit.h>

@interface RCKeychainItem : NSObject {
	NSMutableDictionary *base;
}
- (id)initWithIdentifier:(NSString *)ident;
- (NSString *)objectForKey:(NSString *)key;
- (void)setObject:(NSString *)value forKey:(NSString *)key;
@end