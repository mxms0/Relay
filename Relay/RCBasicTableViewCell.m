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
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.textLabel.font = [UIFont boldSystemFontOfSize:14];
		self.textLabel.textColor = UIColorFromRGB(0x545758);
        // Initialization code
    }
    return self;
}

- (void)addSubview:(UIView *)view {
	NSLog(@"hello %@",view);
	if ([view isKindOfClass:[objc_getClass("UITableViewCellEditControl") class]]) {
		for (UIView *suv in [view subviews]) {
			if ([suv isKindOfClass:[UIImageView class]]) {
				UIImage *gg = [UIImage imageNamed:@"0_tplusbtn"];
				if (self.editingStyle == UITableViewCellEditingStyleDelete)
					gg = [UIImage imageNamed:@"0_tminusbtn"];
				[(UIImageView *)suv setImage:gg];
				break;
			}
		}
	}
	else if ([view isKindOfClass:[objc_getClass("UITableViewCellDeleteConfirmationControl") class]]) {
		NSLog(@"MEH %@", [self subviews]);
		for (UIView *subv in [self subviews]) {
			if ([subv isKindOfClass:[objc_getClass("UITableViewCellEditControl") class]]) {
				for (UIView *suv in [subv subviews]) {
					if ([suv isKindOfClass:[UIImageView class]]) {
						UIImage *gg = [UIImage imageNamed:@"0_tplusbtn"];
						if (self.editingStyle == UITableViewCellEditingStyleDelete)
							gg = [UIImage imageNamed:@"0_tminusbtn"];
						[(UIImageView *)suv setImage:gg];
						break;
					}
				}
				break;
			}
		}
	}
	[super addSubview:view];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
