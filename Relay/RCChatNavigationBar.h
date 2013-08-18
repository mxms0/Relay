//
//  RCChatNavigationBar.h
//  Relay
//
//  Created by Max Shavrick on 10/27/12.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface RCChatNavigationBar : UIView {
	NSString *title;
	NSString *subtitle;
	BOOL isMain;
	BOOL superSpecialLikeAc3xx2;
	CGFloat maxSize;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, assign) BOOL isMain;
@property (nonatomic, assign) BOOL superSpecialLikeAc3xx2;
@property (nonatomic, assign) CGFloat maxSize;
@end
