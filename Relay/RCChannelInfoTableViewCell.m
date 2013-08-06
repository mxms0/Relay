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
		self.textLabel.font = [UIFont boldSystemFontOfSize:12];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGFloat act = 0;
	CGFloat width = [self.textLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:16] minFontSize:8 actualFontSize:&act forWidth:260 lineBreakMode:NSLineBreakByTruncatingMiddle].width;
	[self.textLabel setFont:[UIFont boldSystemFontOfSize:act]];
	[rightLabel setFrame:CGRectMake(width+5, 10, 320 - width + 10, 10)];
}

- (void)setChannelInfo:(RCChannelInfo *)_channelInfo {
//	self.channelInfo = _channelInfo;
	self.textLabel.text = [_channelInfo channel];
	rightLabel.text = [NSString stringWithFormat:@"%d Users", [_channelInfo userCount]];
	self.detailTextLabel.text = [_channelInfo topic];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	return;
	NSAttributedString *str = [channelInfo attributedString];
	[str drawAtPoint:CGPointMake(8, 3)];
	NSString *tlt = [channelInfo topic];
	[tlt drawInRect:CGRectMake(8, 23, 304, 38) withFont:[UIFont systemFontOfSize:11] lineBreakMode:NSLineBreakByTruncatingTail];
	if ([channelInfo isAlreadyInChannel]) {
		UIImage *check = [UIImage imageNamed:@"0_checkr"];
		[check drawInRect:CGRectMake(rect.size.width - 24, 2, check.size.width, check.size.height)];
	}
}

@end
