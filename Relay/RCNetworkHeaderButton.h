//
//  RCNetworkHeaderButton.h
//  Relay
//
//  Created by Max Shavrick on 10/21/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCNetwork;
@interface RCNetworkHeaderButton : UIButton {
	NSInteger section;
	RCNetwork *net;
	BOOL _pSelected;
}
@property (nonatomic, assign) NSInteger section;
- (void)setNetwork:(RCNetwork *)net;
- (RCNetwork *)net;
@end
