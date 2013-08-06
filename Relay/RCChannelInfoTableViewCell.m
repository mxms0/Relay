//
//  RCChannelInfoTableViewCell.m
//  Relay
//
//  Created by Max Shavrick on 7/11/13.
//

#import "RCChannelInfoTableViewCell.h"

@implementation RCChannelInfoTableViewCell
@synthesize channelInfo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		rightLabel = [[UILabel alloc] init];
		[rightLabel setFont:[UIFont systemFontOfSize:11]];
		[rightLabel setTextColor:[UIColor lightGrayColor]];
		[rightLabel setBackgroundColor:UIColorFromRGB(0xDDE0E5)];
		[self.contentView setBackgroundColor:UIColorFromRGB(0xDDE0E5)];
		[self.contentView setOpaque:YES];
		[self setOpaque:YES];
		[self.contentView addSubview:rightLabel];
		[rightLabel release];
		self.textLabel.font = [UIFont boldSystemFontOfSize:14];
		[[self.textLabel superview] bringSubviewToFront:self.textLabel];
		self.textLabel.textColor = UIColorFromRGB(0x444647);
		self.detailTextLabel.numberOfLines = 2;
		self.detailTextLabel.font = [UIFont systemFontOfSize:11];
		self.detailTextLabel.baselineAdjustment = UIBaselineAdjustmentNone;
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self.textLabel setFrame:CGRectMake(5, 1, self.textLabel.frame.size.width, self.textLabel.frame.size.height)];
	[self.detailTextLabel setFrame:CGRectMake(5, 19, 300, 30)];
	[rightLabel setFrame:CGRectMake(self.textLabel.frame.size.width + 8, 7, 80, 10)];
}

- (void)setChannelInfo:(RCChannelInfo *)_channelInfo {
	self.textLabel.text = [_channelInfo channel];
	rightLabel.text = [NSString stringWithFormat:@"%d Users", [_channelInfo userCount]];
	self.detailTextLabel.text = [_channelInfo topic];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	if ([channelInfo isAlreadyInChannel]) {
		UIImage *check = [UIImage imageNamed:@"0_checkr"];
		[check drawInRect:CGRectMake(rect.size.width - 24, 2, check.size.width, check.size.height)];
	}
}

@end
