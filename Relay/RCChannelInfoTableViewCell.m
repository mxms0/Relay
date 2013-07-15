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
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	NSAttributedString *str = [channelInfo attributedString];
	[str drawAtPoint:CGPointMake(8, 3)];
	NSString *tlt = [channelInfo topic];
	[tlt drawInRect:CGRectMake(8, 23, 304, 38) withFont:[UIFont systemFontOfSize:11] lineBreakMode:NSLineBreakByTruncatingTail];
	if ([channelInfo isAlreadyInChannel]) {
		MARK;
		UIImage *check = [UIImage imageNamed:@"0_checkr"];
		[check drawInRect:CGRectMake(rect.size.width - 24, 2, check.size.width, check.size.height)];
	}
}

@end
