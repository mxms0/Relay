//
//  RCUserTableCell.m
//  Relay
//
//  Created by Max Shavrick on 3/15/12.
//

#import "RCUserTableCell.h"
#import "RCChatController.h"
#import "NSString+IRCStringSupport.h"
#import "RCPMChannel.h"

@implementation RCUserTableCell
@synthesize isLast, isWhois, contentView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		contentView = [[RCUserTableCellContentView alloc] initWithFrame:CGRectZero];
		[self addSubview:contentView];
		[contentView release];
		[self.textLabel retain];
		[self.textLabel removeFromSuperview];
		[contentView addSubview:self.textLabel];
		[self.textLabel release];
		[self.textLabel release];
		// really sorry. lol.
		self.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
		self.textLabel.textColor = [UIColor colorWithRed:0.236 green:0.239 blue:0.243 alpha:1.000];
		self.textLabel.shadowColor = [UIColor whiteColor];
		self.textLabel.shadowOffset = CGSizeMake(0, 1);
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		isWhois = NO;
		fakeSelected = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	self.textLabel.hidden = isWhois;
	[contentView setNeedsDisplay];
	[[UIColor orangeColor]set];
	UIRectFill(rect);
}

@end
