//
//  RCActionSheetButton.h
//  Relay
//
//  Created by Max Shavrick on 8/16/13.
//

#import <UIKit/UIKit.h>

@interface RCActionSheetButton : UIButton
@property (nonatomic, readonly) RCActionSheetButtonType type;
- (id)initWithFrame:(CGRect)frame type:(RCActionSheetButtonType)typ;
@end
