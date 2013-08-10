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
		[self setBackgroundColor:UIColorFromRGB(0x393d4a)];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.textLabel.font = [UIFont boldSystemFontOfSize:15.5];
		self.textLabel.textColor = [UIColor whiteColor];
		self.textLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[UIColorFromRGB(0x393d4a) set];
	UIRectFill(rect);
}

@end
