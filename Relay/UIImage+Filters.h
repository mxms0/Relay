//
//  UIImage+Filters.h
//  Relay
//
//  Created by Max Shavrick on 6/21/13.
//	Code based on UIImageAdjust library on github by @coreyleach
//	https://github.com/coryleach/UIImageAdjust
//

#import <UIKit/UIKit.h>

@interface UIImage (Gaussian)
- (UIImage *)imageWith3x3GaussianBlur;
@end