//
//  RCTableCell.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCTableCell.h"

@implementation RCTableCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		RCGradientView *_gradient = [[RCGradientView alloc] initWithFrame:self.frame];
		self.backgroundView = _gradient;
		[_gradient release];
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.textLabel.textColor = [UIColor whiteColor];
		self.detailTextLabel.numberOfLines = 2;
		self.detailTextLabel.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
