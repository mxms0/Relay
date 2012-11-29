//
//  RCNetworkHeaderButton.h
//  Relay
//
//  Created by Max Shavrick on 10/21/12.
//

#import <UIKit/UIKit.h>

@class RCNetwork;
@interface RCNetworkHeaderButton : UIButton {
	NSInteger section;
	RCNetwork *net;
	UIButton *coggearwhat;
	BOOL showsGlow;
	BOOL _pSelected;
}
@property (nonatomic, assign) NSInteger section;
@property (nonatomic, assign) BOOL showsGlow;
- (void)setNetwork:(RCNetwork *)net;
- (RCNetwork *)net;
@end
