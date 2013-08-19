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
		[self setBackgroundColor:[UIColor colorWithRed:53/255.0f green:53/255.0f blue:56/255.0f alpha:1.0f]];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.textLabel.font = [UIFont systemFontOfSize:15.5];
		self.textLabel.textColor = [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f];
		self.textLabel.backgroundColor = [UIColor clearColor];
		textField = [[RCTextField alloc] initWithFrame:CGRectMake(0, 2, 170, 16)];
		[textField setTextAlignment:NSTextAlignmentRight];
		[self setAccessoryView:textField];
		[textField release];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[[UIColor colorWithRed:53/255.0f green:53/255.0f blue:56/255.0f alpha:1.0f] set];
	UIRectFill(rect);
}

@end
