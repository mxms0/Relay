//
//  RCBarGroup.h
//  Relay
//
//  Created by Max Shavrick on 3/23/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCBar.h"

@interface RCBarGroup : UIView {
	RCBar *left;
	RCBar *right;
}
- (void)setRightBarMode:(int)modr;
- (void)setLeftBarMode:(int)modr;
@end
