//
//  RCViewController.h
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import <UIKit/UIKit.h>
#import "RCChannel.h"

@interface RCViewController : UIViewController {
	RCChannel *currentChannel;
}
@property (nonatomic, readonly) RCChannel *currentChannel;
@end
