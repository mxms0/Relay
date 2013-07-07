//
//  RCBasicTextInputCell.m
//  Relay
//
//  Created by Max Shavrick on 8/7/12.
//

#import "RCBasicTextInputCell.h"

@implementation RCBasicTextInputCell
@synthesize textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		textField = [[RCTextField alloc] initWithFrame:CGRectMake(0, 2, 170, 16)];
        // Initialization code
		[textField setTextAlignment:NSTextAlignmentRight];
		[self setAccessoryView:textField];
		[textField release];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	[UIColorFromRGB(0x393d4a) set];
	UIRectFill(rect);
}

@end
