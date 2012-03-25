//
//  RCNewMessagesBubble.h
//  Relay
//
//  Created by Max Shavrick on 3/25/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCNewMessagesBubble : UIButton {
	UIImage *noglow;
	UIImage *glow;
}
- (void)realignTitleLabel;
- (void)pulse;
@end
