//
//  RCNickSuggestionView.h
//  Relay
//
//  Created by Max Shavrick on 1/6/13.
//

#import <UIKit/UIKit.h>
#import "RCNickButton.h"

@interface RCNickSuggestionView : UIView {
	CGPoint displayPoint;
	NSRange range;
	UITextField *inputField;
}
@property (nonatomic, assign) NSRange range;
@property (nonatomic, readonly) CGPoint displayPoint;
@property (nonatomic, retain) UITextField *inputField;
+ (id)sharedInstance;
- (void)showAtPoint:(CGPoint)p withNames:(NSArray *)names;
- (void)dismiss;
- (void)setRange:(NSRange)rr inputField:(UITextField *)ff;
@end
