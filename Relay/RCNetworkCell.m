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
    }
    return self;
}

@end
