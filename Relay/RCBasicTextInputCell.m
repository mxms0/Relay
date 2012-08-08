//
//  RCBasicTextInputCell.m
//  Relay
//
//  Created by Max Shavrick on 8/7/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCBasicTextInputCell.h"

@implementation RCBasicTextInputCell
@synthesize textField;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.textLabel.backgroundColor = [UIColor clearColor];
		[self setOpaque:YES];
		textField = [[RCTextField alloc] initWithFrame:CGRectMake(0, 0, 170, 16)];
        // Initialization code
		[self setAccessoryView:textField];
		[textField release];
    }
    return self;
}

@end
