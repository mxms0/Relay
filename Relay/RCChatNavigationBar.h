//
//  RCChatNavigationBar.h
//  Relay
//
//  Created by Max Shavrick on 10/27/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface RCChatNavigationBar : UINavigationBar {
	NSString *title;
	NSString *subtitle;
	BOOL isMain;
	BOOL drawIndent;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, assign) BOOL isMain;
@property (nonatomic, assign) BOOL drawIndent;
@end
