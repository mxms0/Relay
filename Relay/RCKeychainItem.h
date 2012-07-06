//
//  RCKeychainItem.h
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//	This codd is based on apple's GenericKeychain example.
//	i don't think above çovers me legally. :P

#import <UIKit/UIKit.h>

@interface RCKeychainItem : NSObject {
	NSMutableDictionary *data;
	NSMutableDictionary *genericQuery;
}
- (id)initWithIdentifier:(NSString *)ident accessGroup:(NSString *)group;
- (NSString *)objectForKey:(NSString *)key;
- (void)setObject:(NSString *)value forKey:(NSString *)key;
- (void)resetKeychain;
@end