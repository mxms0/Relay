//
//  RCSwitch.h
//  Relay
//
//  Created by Max Shavrick on 3/21/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCSwitch : UIControl {
	BOOL on;
	UIImageView *bg;
	UIButton *knob;
}

@property (nonatomic, assign) BOOL on;

@end
