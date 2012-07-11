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
		[self.contentView addSubview:self.textLabel];
		[self.textLabel release];
	}
	return self;
}

- (void)_textHasBeenSet {
	needsLayout = YES;
	self.textLabel.text = [message message];
	CHAttributedString *attr = [[CHAttributedString alloc] initWithString:self.textLabel.text];
	[attr setFont:[UIFont fontWithName:@"Helvetica" size:12]];
	UIColor *normalColor = UIColorFromRGB(0x3F4040);
	if ([message isOld])
		normalColor = UIColorFromRGB(0xB6BCCC);
	[attr setTextColor:normalColor];
	
	@autoreleasepool {
		UIImage *bg = [UIImage imageNamed:@"0_chatcell"];
		[self.contentView setBackgroundColor:[UIColor colorWithPatternImage:bg]];
		[self setNeedsDisplay];
	}
	switch ([message flavor]) {
		case RCMessageFlavorAction:
			[attr setTextIsUnderlined:NO range:NSMakeRange(0, self.textLabel.text.length)];
			[attr setTextBold:YES range:NSMakeRange(0, self.textLabel.text.length)];
			[attr setTextAlignment:CTTextAlignmentFromUITextAlignment(UITextAlignmentCenter) lineBreakMode:CTLineBreakModeFromUILineBreakMode(UILineBreakModeClip)];
			break;
		case RCMessageFlavorNormal:
			if ([message highlight]) {
				if (![message isOld])
					[attr setTextColor:UIColorFromRGB(0xDA4156)];
				else [attr setTextColor:UIColorFromRGB(0xB6BCCC)];
			}
			NSRange p = [self.textLabel.text rangeOfString:@"]"];
			NSRange r = [self.textLabel.text rangeOfString:@":" options:0 range:NSMakeRange(p.location, self.textLabel.text.length-p.location)];
			[attr setTextBold:YES range:NSMakeRange(0, r.location)];
			break;
		case RCMessageFlavorNotice:
			[attr setTextBold:YES range:NSMakeRange(0, self.textLabel.text.length)];
			// do something.
			break;
		case RCMessageFlavorTopic:
			[attr setTextAlignment:CTTextAlignmentFromUITextAlignment(UITextAlignmentCenter) lineBreakMode:CTLineBreakModeFromUILineBreakMode(UILineBreakModeWordWrap)];
			break;
		case RCMessageFlavorJoin:
			[attr setFont:[UIFont fontWithName:@"Helvetica" size:11]];
			[attr setTextAlignment:CTTextAlignmentFromUITextAlignment(UITextAlignmentCenter) lineBreakMode:CTLineBreakModeFromUILineBreakMode(UILineBreakModeWordWrap)];
			[self.contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"0_joinbar"]]];
			break;
		case RCMessageFlavorPart:
			[attr setFont:[UIFont fontWithName:@"Helvetica" size:11]];
			[attr setTextAlignment:CTTextAlignmentFromUITextAlignment(UITextAlignmentCenter) lineBreakMode:CTLineBreakModeFromUILineBreakMode(UILineBreakModeWordWrap)];
			[self.contentView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"0_joinbar"]]];
			break;
		case RCMessageFlavorNormalE:
		//	[attr setTextBold:YES range:NSMakeRange(0, self.textLabel.text.length)];
			break;
	}
	if ([message isMine]) {
		if (![message isOld])
			[attr setTextColor:UIColorFromRGB(0x697797)];
	}
	[self.textLabel setAttributedText:attr];
	[attr release];
	if (![message messageHeight]) {
		float *heights = [self calculateHeightForLabel];
		[message setMessageHeight:heights[0]];
		[message setMessageHeightLandscape:heights[1]];
		free(heights);
	}
	height = ((self.frame.size.width == 480) ? message.messageHeightLandscape : message.messageHeight);
	if (height > 15) {
		int layr = height/15;
		@autoreleasepool {
			UIImage *bg = [UIImage imageNamed:[NSString stringWithFormat:@"0_chatcell_%d", (int)layr]];
			[self.contentView setBackgroundColor:[UIColor colorWithPatternImage:bg]];
			[self setNeedsDisplay];
		}
	}
}

- (float *)calculateHeightForLabel {
	float *heights = (float *)malloc(sizeof(float *));
	float fake = [self.textLabel.attributedText boundingHeightForWidth:316];
	float faker = [self.textLabel.attributedText boundingHeightForWidth:476];
	float multiplier = fake/12;
	heights[0] = fake + (multiplier * 3);
	multiplier = faker/12;
	heights[1] = faker + (multiplier * 3);
	return ((float *)heights);
}

- (void)layoutSubviews {
	[super layoutSubviews];
	if (needsLayout) {
		[self.textLabel setFrame:CGRectMake(2, 2,((UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? 480 : 320) - 4) , height)];
		[self.textLabel setNeedsDisplay];
		needsLayout = NO;
	}
}

@end
