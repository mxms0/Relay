//
//  RCTextField.m
//  Relay
//
//  Created by Max Shavrick on 3/21/12.
//

#import "RCTextField.h"

@implementation RCTextField

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self setTextColor:UIColorFromRGB(0xa5a6a7)];
		[self setFont:[UIFont systemFontOfSize:12]];
		UIButton *xx = [UIButton buttonWithType:UIButtonTypeCustom];
		[xx setImage:[UIImage imageNamed:@"0_removr"] forState:UIControlStateNormal];
		[xx setFrame:CGRectMake(0, 0, 32, 32)];
		[xx addTarget:self action:@selector(clearAllText) forControlEvents:UIControlEventTouchUpInside];
		[self setRightView:xx];
	}
	return self;
}

- (void)clearAllText {
	[self setText:@""];
}

- (BOOL)becomeFirstResponder {
	BOOL ret = [super becomeFirstResponder];
	if (ret) {
		self.rightViewMode = UITextFieldViewModeAlways;
	}
	return ret;
}

- (BOOL)resignFirstResponder {
    BOOL ret = [super resignFirstResponder];
	if (ret)
		self.rightViewMode = UITextFieldViewModeWhileEditing;
	return ret;
}

- (void)drawPlaceholderInRect:(CGRect)rect {
	[super drawPlaceholderInRect:rect];
	CGContextClearRect(UIGraphicsGetCurrentContext(), rect);
	[UIColorFromRGB(0x71737a) setFill];
	CGFloat sv = [[self placeholder] sizeWithFont:[UIFont systemFontOfSize:13]].width;
	
	switch (self.textAlignment) {
		case NSTextAlignmentRight:
			sv = (rect.size.width - sv);
			if (!self.isFirstResponder) {
				sv -= 20;
			}
			break;
		case NSTextAlignmentLeft:
			sv = 0;
			break;
		default:
			sv = (rect.size.width - sv);
			if (!self.isFirstResponder) {
				sv -= 20;
			}
			break;
	}
	
	[[self placeholder] drawInRect:CGRectMake(sv, 0, rect.size.width, rect.size.height) withFont:[UIFont systemFontOfSize:13]];
}

- (void)drawTextInRect:(CGRect)rect {
	[super drawTextInRect:CGRectMake(0, 0, rect.size.width-20, rect.size.height)];
}

@end
