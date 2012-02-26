//
//  RCTableHeaderView.h
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import <UIKit/UIKit.h>
#import "RCNetwork.h"

@protocol RCTableHeaderViewDelegate <NSObject>

@end

@interface RCTableHeaderView : UIButton {
}

- (void)setNetwork:(RCNetwork *)network;

@end
