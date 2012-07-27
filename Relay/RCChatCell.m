//
//  RCChatCell.m
//  Relay
//
//  Created by Max Shavrick on 2/17/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChatCell.h"
#import "RCNavigator.h"

@implementation RCChatCell
@synthesize textLabel, message;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.opaque = YES;
		self.layer.opaque = YES;
		contentView = [[RCChatCellContentView alloc] initWithFrame:CGRectZero];
		contentView.opaque = YES;
		self.backgroundView = contentView;
		[contentView release];
		
		needsLayout = NO;
		self.textLabel = [[OHAttributedLabel alloc] init];
		[self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		self.textLabel.font = [UIFont boldSystemFontOfSize:12];
		self.textLabel.backgroundColor = [UIColor clearColor];
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
		[self.textLabel setAutomaticallyAddLinksForType:(NSTextCheckingTypeAddress | NSTextCheckingTypeDate | NSTextCheckingTypeLink | NSTextCheckingTypePhoneNumber)];
		[self.textLabel setLinkColor:UIColorFromRGB(0x4F94EA)];
		[self.textLabel setUnderlineLinks:NO];
		[self.textLabel setExtendBottomToFit:YES];
		[self.textLabel setShadowColor:[UIColor whiteColor]];
		[self.textLabel setShadowOffset:CGSizeMake(0, 1)];
		self.textLabel.hidden = YES;
		[self.contentView addSubview:self.textLabel];
		[self.textLabel release];
	}
	return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	CGRect bounds = [self bounds];
	[contentView setFrame:bounds];
}

- (void)setNeedsDisplay {
	[super setNeedsDisplay];
	[contentView setNeedsDisplay];
}

- (void)setNeedsDisplayInRect:(CGRect)rect {
	[super setNeedsDisplayInRect:rect];
	[contentView setNeedsDisplayInRect:rect];
}

- (void)setMessage:(RCMessage *)_message {
	needsLayout = YES;
	message = _message;
	self.textLabel.attributedText = [_message string];
}

- (void)_messageHasBeenSet {
	@autoreleasepool {
		UIImage *bg = [UIImage imageNamed:@"0_chatcell"];
		[self.contentView setBackgroundColor:[UIColor colorWithPatternImage:bg]];
		[self setNeedsDisplay];
	}
	height = ((self.frame.size.width == 480) ? message.messageHeightLandscape : message.messageHeight);
	if (height > 15) {
		int layr = height/15;
		@autoreleasepool {
			UIImage *bg = [UIImage imageNamed:[NSString stringWithFormat:@"0_chatcell_%d", (int)layr]];
			[self.contentView setBackgroundColor:[UIColor colorWithPatternImage:bg]];
		}
	}	
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self.textLabel setFrame:CGRectMake(2, 2, self.frame.size.width-4 , height)];
}

- (void)drawContentView:(CGRect)rect {

}

@end
