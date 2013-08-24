//
//  RCSchemeManager.h
//  Relay
//
//  Created by Max Shavrick on 8/18/13.
//

#import <Foundation/Foundation.h>

@interface RCSchemeManager : NSObject {
	NSBundle *currentThemeBundle;
	BOOL isRetina;
}
@property (nonatomic, readonly) BOOL isDark;
+ (id)sharedInstance;
- (UIImage *)imageNamed:(NSString *)image;
@end
