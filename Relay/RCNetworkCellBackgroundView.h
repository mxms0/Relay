//
//  RCNetworkCellBackgroundView.h
//  Relay
//
//  Created by Max Shavrick on 10/21/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCNetworkCellBackgroundView : UIView {
	BOOL isTop;
	BOOL isBottom;
}
@property (nonatomic, assign) BOOL isTop;
@property (nonatomic, assign) BOOL isBottom;

- (void)drawRect:(CGRect)rect;

@end
