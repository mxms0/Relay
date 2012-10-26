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
		underline = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"0_underline"]];
		[self addSubview:underline];
		[underline release];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	[UIColorFromRGB(0x1B1B23) set];
	UIRectFill(CGRectMake(7, 0, 240, 44));
	if (!self.channel) return;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0, [UIColor blackColor].CGColor);
	CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.705 green:0.718 blue:0.754 alpha:1.000].CGColor);
	CGContextScaleCTM(ctx, [[UIScreen mainScreen] scale], [[UIScreen mainScreen] scale]);
	[channel drawInRect:CGRectMake(10, 4, 200, 40) withFont:[UIFont boldSystemFontOfSize:9] lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentLeft];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	[underline setFrame:CGRectMake(6, 38, newSuperview.frame.size.width-11, 2)];
}

- (void)setSelected:(BOOL)selected {
	[self setNeedsDisplay];
}

@end
