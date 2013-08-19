//
//  RCUserTableCell.m
//  Relay
//
//  Created by Max Shavrick on 3/15/12.
//

#import "RCUserTableCell.h"
#import "RCChatController.h"
#import "NSString+IRCStringSupport.h"
#import "RCChannel.h"

@implementation RCUserTableCell
@synthesize isLast, isWhois;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15];
		self.textLabel.textColor = [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f];
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.contentView.backgroundColor = [UIColor clearColor];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		[self setBackgroundColor:[UIColor colorWithRed:53/255.0f green:53/255.0f blue:56/255.0f alpha:1.0f]];
		isWhois = NO;
		fakeSelected = NO;
    }
    return self;
}

- (void)setChannel:(RCPMChannel *)chan {
	[channel release];
	channel = [chan retain];
	return;
	if ([chan isKindOfClass:[RCConsoleChannel class]]) return;
	prefix = RCUserRank(self.textLabel.text, [chan delegate]);
	if (prefix)
		self.textLabel.text = [self.textLabel.text substringFromIndex:1];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[[UIColor colorWithRed:35/255.0f green:35/255.0f blue:36/255.0f alpha:1.0f] setFill];
	UIRectFill(CGRectMake(0, rect.size.height - 2, rect.size.width, 0.5));
	[[UIColor colorWithRed:73/255.0f green:73/255.0f blue:76/255.0f alpha:1.0f] setFill];
	UIRectFill(CGRectMake(0, rect.size.height - 1, rect.size.width, 1));
	if (prefix) {
	
	}
}

@end
