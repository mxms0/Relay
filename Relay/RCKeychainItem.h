//
//  RCKeychainItem.h
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import <UIKit/UIKit.h>

@interface RCKeychainItem : NSObject {
	NSString *service;
}
- (id)initWithService:(NSString *)serv;
- (NSString *)stringForKey:(NSString *)key;
- (void)setObject:(NSString *)value forKey:(NSString *)key;
@end