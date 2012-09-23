//
//  RCNetworkCell.m
//  Relay
//
//  Created by Max Shavrick on 6/22/12.
//

#import "RCNetworkCell.h"

@implementation RCNetworkCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.textLabel.textColor = [UIColor whiteColor];
		self.backgroundColor = [UIColor clearColor];
		self.detailTextLabel.font = [UIFont systemFontOfSize:12];
		self.detailTextLabel.textColor = UIColorFromRGB(0xAFB1B6);
		self.detailTextLabel.shadowColor = [UIColor blackColor];
		self.detailTextLabel.shadowOffset = CGSizeMake(0, 1);
		self.textLabel.shadowOffset = CGSizeMake(0, 1);
		self.textLabel.shadowColor = [UIColor blackColor];
		underline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"0_underline"]];
		[self addSubview:underline];
		[underline release];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[underline setFrame:CGRectMake(6, 41, newSuperview.frame.size.width-11, 2)];
}

@end
