//
//  RCChannelManagementViewController.h
//  Relay
//
//  Created by Max Shavrick on 8/7/12.
//

#import "RCBasicViewController.h"
#import "RCBasicTextInputCell.h"
#import "RCBasicTableViewCell.h"
#import "RCChannelManager.h"
#import "RCKeychainItem.h"

@class RCNetwork, RCChannelManager;
@interface RCChannelManagementViewController : RCBasicViewController <UITextFieldDelegate> {
	RCNetwork *net;
	NSString *channel;
	NSString *originalChannel;
	NSString *pass;
	RCChannelManager *delegate;
	BOOL jOC;
}
@property (nonatomic, retain) NSString *channel;
@property (nonatomic, retain) NSString *originalChannel;
@property (nonatomic, assign) RCChannelManager *delegate;
- (id)initWithStyle:(UITableViewStyle)style network:(RCNetwork *)net channel:(NSString *)chan;
@end
