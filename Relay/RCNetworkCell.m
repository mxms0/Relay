//
//  RCNetworkCell.m
//  Relay
//
//  Created by Max Shavrick on 6/22/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCNetworkCell.h"

@implementation RCNetworkCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		self.textLabel.textColor = [UIColor whiteColor];
		self.backgroundColor = [UIColor clearColor];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.detailTextLabel.font = [UIFont systemFontOfSize:12];
		self.detailTextLabel.textColor = [UIColor whiteColor];
		self.detailTextLabel.shadowColor = [UIColor blackColor];
		self.detailTextLabel.shadowOffset = CGSizeMake(0, 1);
		self.textLabel.shadowOffset = CGSizeMake(0, 1);
		self.textLabel.shadowColor = [UIColor blackColor];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
//	self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, 1, self.textLabel.frame.size.width, self.textLabel.frame.size.height);
}

@end
