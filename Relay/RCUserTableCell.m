//
//  RCUserTableCell.m
//  Relay
//
//  Created by Max Shavrick on 3/15/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCUserTableCell.h"

@implementation RCUserTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		self.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11];
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.textLabel.textColor = UIColorFromRGB(0x3F4040);
		self.textLabel.shadowColor = [UIColor whiteColor];
		self.textLabel.shadowOffset = CGSizeMake(0, 1);
		self.detailTextLabel.backgroundColor = [UIColor clearColor];
		self.detailTextLabel.font = [UIFont italicSystemFontOfSize:9.5];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		UIImage *bg = [UIImage imageNamed:@"0_chatcell"];
		[self.contentView setBackgroundColor:[UIColor colorWithPatternImage:bg]];
		[self setNeedsDisplay];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGSize size = [self.textLabel.text sizeWithFont:[UIFont systemFontOfSize:11]];
	CGSize dSize = [self.detailTextLabel.text sizeWithFont:[UIFont systemFontOfSize:9.5]];
	[self.textLabel setFrame:CGRectMake(22, 4, self.textLabel.frame.size.width, self.textLabel.frame.size.height)];
	[self.detailTextLabel setFrame:CGRectMake(27 + size.width, 7.5, dSize.width, 10)];
	[self.imageView setFrame:CGRectMake(5, 5, 14.5, 15.5)];
}

@end
