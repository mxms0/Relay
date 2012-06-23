//
//  RCKeychainItem.h
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import <UIKit/UIKit.h>

@interface RCKeychainItem : NSObject {
}
- (NSString *)objectForKey:(NSString *)key;
- (BOOL)setObject:(NSString *)value forKey:(NSString *)key;
@end