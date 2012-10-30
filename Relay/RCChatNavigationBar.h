//
//  RCChatNavigationBar.h
//  Relay
//
//  Created by Max Shavrick on 10/27/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCChatNavigationBar : UINavigationBar {
	NSString *title;
	NSString *subtitle;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@end
