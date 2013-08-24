//
//  RCViewCard.h
//  Relay
//
//  Created by Max Shavrick on 6/16/13.
//

#import <UIKit/UIKit.h>
#import "RCChatNavigationBar.h"
#import "RCBarButtonItem.h"
#import "RCPMChannel.h"
#import "RCConsoleChannel.h"
#import "RCPrettyActionSheet.h"
#import "RCNetworkManager.h"

@interface RCViewCard : UIView {
	RCChatNavigationBar *navigationBar;
}
@property (nonatomic, readonly) RCChatNavigationBar *navigationBar;
- (id)initWithFrame:(CGRect)frame;
- (void)findShadowAndDoStuffToIt;
- (void)setLeftBarButtonItemEnabled:(BOOL)en;
- (void)loadNavigationButtons;
@end
