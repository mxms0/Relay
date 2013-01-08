//
//  RCNickSuggestionView.h
//  Relay
//
//  Created by Max Shavrick on 1/6/13.
//

#import <UIKit/UIKit.h>

@interface RCNickSuggestionView : UIView {
	CGPoint displayPoint;
}
@property (nonatomic, readonly) CGPoint displayPoint;
+ (id)sharedInstance;
- (void)showAtPoint:(CGPoint)p withNames:(NSArray *)names;
- (void)dismiss;
@end
