//
//  RCPasswordRequestAlert.h
//  Relay
//
//  Created by Max Shavrick on 7/22/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCPrettyAlertView.h"
@class RCNetwork;

typedef enum RCPasswordRequestAlertType {
	RCPasswordRequestAlertTypeNickServ,
	RCPasswordRequestAlertTypeServer
} RCPasswordRequestAlertType;

@interface RCPasswordRequestAlert : RCPrettyAlertView {
	RCNetwork *net;
	RCPasswordRequestAlertType type;
}
- (id)initWithNetwork:(RCNetwork *)net type:(RCPasswordRequestAlertType)ty;
@end
