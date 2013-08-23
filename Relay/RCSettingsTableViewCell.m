//
//  RCSettingsTableViewCell.m
//  Relay
//
//  Created by Max Shavrick on 8/10/13.
//

#import "RCSettingsTableViewCell.h"

@implementation RCSettingsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		[self setBackgroundColor:[UIColor colorWithRed:53/255.0f green:53/255.0f blue:56/255.0f alpha:1.0f]];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.textLabel.font = [UIFont systemFontOfSize:15.5];
		self.textLabel.textColor = [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f];
		self.textLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[[UIColor colorWithRed:53/255.0f green:53/255.0f blue:56/255.0f alpha:1.0f] set];
	UIRectFill(rect);
	[UIColorFromRGB(0x4a4a4c) set];
	UIRectFill(CGRectMake(0, 0, rect.size.width, 1));
}

@end
