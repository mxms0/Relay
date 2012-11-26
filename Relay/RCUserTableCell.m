//
//  RCUserTableCell.m
//  Relay
//
//  Created by Max Shavrick on 3/15/12.
//

#import "RCUserTableCell.h"

@implementation RCUserTableCell
@synthesize isLast;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		self.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
		self.textLabel.textColor = [UIColor colorWithRed:0.236 green:0.239 blue:0.243 alpha:1.000];
		self.textLabel.shadowColor = [UIColor whiteColor];
		self.textLabel.shadowOffset = CGSizeMake(0, 1);
		self.detailTextLabel.backgroundColor = [UIColor clearColor];
		self.detailTextLabel.font = [UIFont fontWithName:@"Helvetica" size:9.5];
		self.selectionStyle = UITableViewCellSelectionStyleNone;

    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGSize size = [self.textLabel.text sizeWithFont:[UIFont systemFontOfSize:11]];
	CGSize dSize = [self.detailTextLabel.text sizeWithFont:[UIFont systemFontOfSize:9.5]];
	[self.textLabel setFrame:CGRectMake(10, 0, self.textLabel.frame.size.width, self.textLabel.frame.size.height)];
	[self.detailTextLabel setFrame:CGRectMake(27 + size.width, 7.5, dSize.width, 10)];
	[self.imageView setFrame:CGRectMake(5, 5, 14.5, 15.5)];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	UIImage *bg = [UIImage imageNamed:@"0_strangebg"];
	[bg drawAsPatternInRect:CGRectMake(0, 0, rect.size.width, rect.size.height)];
	if (!isLast) {
		UIImage *ul = [UIImage imageNamed:@"0_usl"];
		[ul drawAsPatternInRect:CGRectMake(0, 43, rect.size.width, 1)];
	}
	
}

@end
