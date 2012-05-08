//
//  RCAddCell.m
//  Relay
//
//  Created by Max Shavrick on 3/21/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCAddCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation RCAddCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.textLabel.backgroundColor = [UIColor clearColor];
	}
	return self;
}

@end
