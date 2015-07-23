//
//  RAChatController.h
//  Relay IRC
//
//  Created by Max Shavrick on 7/22/15.
//  Copyright (c) 2015 Mxms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RANavigationBar.h"

@interface RAChatController : NSObject <UINavigationBarDelegate, RANavigationBarButtonDelegate>
+ (instancetype)sharedInstance;
- (void)layoutInterfaceWithViewController:(UINavigationController *)vc;
@end
