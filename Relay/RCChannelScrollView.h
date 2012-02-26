//
//  RCRoomScrollView.h
//  Relay
//
//  Created by Max Shavrick on 2/25/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCChannelBubble.h"

@interface RCChannelScrollView : UIScrollView {
	
}
- (void)layoutChannels:(NSArray *)channels;
@end
