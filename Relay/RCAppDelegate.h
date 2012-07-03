//
//  RCAppDelegate.h
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import <UIKit/UIKit.h>
#import "RCPopoverWindow.h"

@class RCViewController;

@interface RCAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIViewController *navigationController;
@property (nonatomic, readonly) BOOL isDoubleHeight;

@end
