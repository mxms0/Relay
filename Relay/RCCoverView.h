//
//  RCCoverView.h
//  Relay
//
//  Created by Max Shavrick on 8/23/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCChannel.h"

@interface RCCoverView : UIView {
	UIView *mainView;
	UIImageView *backgroundImage;
	UIImageView *arrow;
	RCChannel *channel;
}
@property (nonatomic, retain) RCChannel *channel;
- (id)initWithFrame:(CGRect)frame andChannel:(RCChannel *)chan;
- (void)setArrowPosition:(CGPoint)ppt;
- (void)show;
- (void)hide;
@end
