//
//  RCUserTableCell.m
//  Relay
//
//  Created by Max Shavrick on 3/15/12.
//

#import "RCUserTableCell.h"

@implementation RCUserTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		self.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11];
		self.textLabel.textColor = [UIColor colorWithRed:0.236 green:0.239 blue:0.243 alpha:1.000];
		self.textLabel.shadowColor = [UIColor whiteColor];
		self.textLabel.shadowOffset = CGSizeMake(0, 1);
		self.detailTextLabel.backgroundColor = [UIColor clearColor];
		self.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:9.5];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		UIImage *bg = [UIImage imageNamed:@"0_strangebg"];
		[self.contentView setBackgroundColor:[UIColor colorWithPatternImage:bg]];
		[self setNeedsDisplay];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGSize size = [self.textLabel.text sizeWithFont:[UIFont systemFontOfSize:11]];
	CGSize dSize = [self.detailTextLabel.text sizeWithFont:[UIFont systemFontOfSize:9.5]];
	[self.textLabel setFrame:CGRectMake(22, 0, self.textLabel.frame.size.width, self.textLabel.frame.size.height)];
	[self.detailTextLabel setFrame:CGRectMake(27 + size.width, 7.5, dSize.width, 10)];
	[self.imageView setFrame:CGRectMake(5, 5, 14.5, 15.5)];
}

@end
