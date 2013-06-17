//
//  RCViewCard.h
//  Relay
//
//  Created by Max Shavrick on 6/16/13.
//

#import <UIKit/UIKit.h>
#import "RCChatNavigationBar.h"

@interface RCViewCard : UIView {
	RCChatNavigationBar *navigationBar;
}
@property (nonatomic, assign) BOOL needsBlueBackground;
@property (nonatomic, assign) BOOL isBottomView;
@property (nonatomic, readonly) RCChatNavigationBar *navigationBar;
- (id)initWithFrame:(CGRect)frame isBottomView:(BOOL)bb;
- (void)findShadowAndDoStuffToIt;
@end
