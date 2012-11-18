//
//  RCChatController.h
//  Relay
//
//  Created by Max Shavrick on 10/26/12.
//

#import <Foundation/Foundation.h>
#import "RCViewController.h"

@class RCChatViewController, RCChatsListViewController;
@interface RCChatController : NSObject <UIAlertViewDelegate> {
	RCViewController *rootView;
	RCChatViewController *navigationController;
	RCChatsListViewController *leftView;
	RCChatPanel *currentPanel;
}
@property (nonatomic, retain) RCChatPanel *currentPanel;
- (id)initWithRootViewController:(RCViewController *)rc;
+ (id)sharedController;
- (CGRect)frameForChatPanel;
- (BOOL)isLandscape;
- (void)selectChannel:(NSString *)channel fromNetwork:(RCNetwork *)net;
- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)oi;
- (void)showMenuOptions:(id)unused;
@end
