//
//  RCBasicTableViewCell.m
//  Relay
//
//  Created by Max Shavrick on 8/7/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCBasicTableViewCell.h"

@implementation RCBasicTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)ident {
	if ((self = [super initWithStyle:style reuseIdentifier:ident])) {
		self.textLabel.backgroundColor = [UIColor clearColor];
		[self setOpaque:YES];
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
