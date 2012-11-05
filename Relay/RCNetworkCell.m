//
//  RCNetworkCell.m
//  Relay
//
//  Created by Max Shavrick on 6/22/12.
//

#import "RCNetworkCell.h"

@implementation RCNetworkCell
@synthesize channel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.channel = nil;
	/*	self.textLabel.textColor = [UIColor whiteColor];
		self.detailTextLabel.font = [UIFont systemFontOfSize:12];
		self.detailTextLabel.textColor = UIColorFromRGB(0xAFB1B6);
		self.detailTextLabel.shadowColor = [UIColor blackColor];
		self.detailTextLabel.shadowOffset = CGSizeMake(0, 1);
		self.textLabel.shadowOffset = CGSizeMake(0, 1);
		self.textLabel.shadowColor = [UIColor blackColor]; */
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	[UIColorFromRGB(0x1B1B23) set];
	UIRectFill(CGRectMake(0, 0, rect.size.width, rect.size.height));
	UIImage *ul = [UIImage imageNamed:@"0_underline"];
	[ul drawAsPatternInRect:CGRectMake(0, rect.size.height-2, rect.size.width, 2)];
	if (!self.channel) return;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0, [UIColor blackColor].CGColor);
	CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.705 green:0.718 blue:0.754 alpha:1.000].CGColor);
	CGContextScaleCTM(ctx, [[UIScreen mainScreen] scale], [[UIScreen mainScreen] scale]);
	[channel drawInRect:CGRectMake(5, 5, 200, 40) withFont:[UIFont boldSystemFontOfSize:9] lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentLeft];
}

- (void)setSelected:(BOOL)selected {
	[self setNeedsDisplay];
	[super setSelected:selected];
}

@end
