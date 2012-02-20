//
//  RCChatCell.m
//  Relay
//
//  Created by Max Shavrick on 2/17/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChatCell.h"


@implementation RCChatCell
@synthesize textLabel;

CTFontRef CTFontCreateFromUIFont(UIFont *font) {
	CTFontRef ctFont = CTFontCreateWithName((CFStringRef)font.fontName, font.pointSize, NULL);
	return ctFont;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.textLabel = [[OHAttributedLabel alloc] init];
		[self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
		self.textLabel.font = [UIFont boldSystemFontOfSize:12];
		[self addSubview:self.textLabel];
		[self.textLabel release];
	}
	return self;
}

- (void)_textHasBeenSet {
	NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:self.textLabel.text];
	[attr setTextColor:[UIColor blackColor]];
	[attr setFont:[UIFont fontWithName:@"Helvetica" size:12]];
	[attr setTextBold:YES range:NSMakeRange(0, [self.textLabel.text rangeOfString:@":"].location)];
	[self.textLabel setAttributedText:attr];
	[attr release];
}

- (float)calculateHeightForLabel {
	int maxWidth = [[UIScreen mainScreen] applicationFrame].size.width-4; // 2 here, 2 there.. :P
	int lengthOfName = [[self.textLabel.text substringWithRange:NSMakeRange(0, [self.textLabel.text rangeOfString:@":"].location)] sizeWithFont:[UIFont fontWithName:@"Helvetica-Bold" size:12]].width;
	int lengthOfMsg = [[self.textLabel.text substringWithRange:NSMakeRange([self.textLabel.text rangeOfString:@":"].location, self.textLabel.text.length-[self.textLabel.text rangeOfString:@":"].location)] sizeWithFont:[UIFont fontWithName:@"Helvetica" size:12]].width;
	int finalLength = lengthOfMsg += lengthOfName;
	int heightToUse = ((finalLength += (finalLength % maxWidth))/maxWidth);
	return (heightToUse <= 1 ? 1 : heightToUse)*15;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self.textLabel setFrame:CGRectMake(2,2, 320, [self calculateHeightForLabel])];
	[self.textLabel setNeedsDisplay];
}

@end
