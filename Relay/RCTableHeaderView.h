//
//  RCTableHeaderView.h
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import <UIKit/UIKit.h>
#import "RCNetwork.h"
#import "RCGradientView.h"

@protocol RCTableHeaderViewDelegate <NSObject>

@end

@interface RCTableHeaderView : UIView {

}

- (void)setNetwork:(RCNetwork *)network;

@end
