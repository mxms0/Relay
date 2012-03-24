//
//  RCTableView.h
//  Relay
//
//  Created by Max Shavrick on 3/8/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#define SHADOW_HEIGHT 20.0
#define SHADOW_INVERSE_HEIGHT 10.0
#define SHADOW_RATIO (SHADOW_INVERSE_HEIGHT / SHADOW_HEIGHT)

@interface RCTableView : UITableView {
	CAGradientLayer *originShadow;
	CAGradientLayer *topShadow;
	UIImageView *bottomShadow;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;

@end
