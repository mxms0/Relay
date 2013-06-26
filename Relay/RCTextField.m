//
//  RCTextField.m
//  Relay
//
//  Created by Max Shavrick on 3/21/12.
//

#import "RCTextField.h"

#if USE_PRIVATE
@interface RCTextField (RCPrivate_)
- (void)setInsertionPointColor:(UIColor *)color;
@end
#endif

@implementation RCTextField

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_setupClearButtonMode = UITextFieldViewModeWhileEditing;
		[self setTextColor:UIColorFromRGB(0x56595A)];
		[self setFont:[UIFont systemFontOfSize:12]];
		[self setRightViewMode:UITextFieldViewModeWhileEditing];
		UIButton *xx = [UIButton buttonWithType:UIButtonTypeCustom];
		[xx setImage:[UIImage imageNamed:@"0_removr"] forState:UIControlStateNormal];
		[xx setFrame:CGRectMake(0, 0, 32, 32)];
		[xx addTarget:self action:@selector(clearAllText) forControlEvents:UIControlEventTouchUpInside];
		[self setRightView:xx];
#if USE_PRIVATE
		if ([self respondsToSelector:@selector(setInsertionPointColor:)])
			[self setInsertionPointColor:UIColorFromRGB(0x4F94EA)];
#endif
	}
	return self;
}

- (void)clearAllText {
	[self setText:@""];
}

- (BOOL)becomeFirstResponder {
	BOOL ret = [super becomeFirstResponder];
	if (ret && (_setupClearButtonMode == UITextFieldViewModeWhileEditing))
		self.rightViewMode = UITextFieldViewModeAlways ;
	return ret ;
}

- (BOOL)resignFirstResponder {
    BOOL ret = [super resignFirstResponder];
	if (ret && (_setupClearButtonMode == UITextFieldViewModeWhileEditing))
		self.rightViewMode = UITextFieldViewModeWhileEditing;
	return ret ;
}

@end
