

#import <UIKit/UIKit.h>

@interface RCKeychainItem : NSObject {
}
- (NSString *)objectForKey:(NSString *)key;
- (BOOL)setObject:(NSString *)value forKey:(NSString *)key;
@end