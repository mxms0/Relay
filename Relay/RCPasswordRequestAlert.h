//
//  RCPasswordRequestAlert.h
//  Relay
//
//  Created by Max Shavrick on 7/22/12.
//

#import <UIKit/UIKit.h>
#import "RCPrettyAlertView.h"

@class RCNetwork;
@interface RCPasswordRequestAlert : RCPrettyAlertView {
	RCNetwork *net;
	RCPasswordRequestAlertType type;
}
- (id)initWithNetwork:(RCNetwork *)net type:(RCPasswordRequestAlertType)ty;
@end
