//
//  RCPrettyActionSheet.h
//  Relay
//
//  Created by Max Shavrick on 10/20/12.
//

#import <UIKit/UIKit.h>
#import "RCActionSheetButton.h"

@interface RCPrettyActionSheet : UIView {
	NSMutableArray *buttons;
	NSString *title;
	UIView *buttonView;
	int buttonCount;
	id delegate;
	CGFloat projectedOffset;
}
- (id)initWithTitle:(NSString *)title delegate:(id <UIActionSheetDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;
- (void)showInView:(UIView *)view;
@end
