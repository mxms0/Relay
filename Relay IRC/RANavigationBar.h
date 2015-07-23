//
//  RANavigationBar.h
//  Relay IRC
//
//  Created by Max Shavrick on 7/22/15.
//  Copyright (c) 2015 Mxms. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RANavigationBarButton.h"

@class RANavigationBarButton;
@protocol RANavigationBarButtonDelegate <NSObject>
- (void)navigationBarButtonWasPressed:(RANavigationBarButton *)btn;
@end

@interface RANavigationBar : UINavigationBar {
	RANavigationBarButton *menuButton;
}
@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) NSString *subtitleText;
@property (nonatomic, assign) id <RANavigationBarButtonDelegate> tapDelegate;
@end
