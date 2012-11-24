//
//  RCNetworkCell.m
//  Relay
//
//  Created by Max Shavrick on 6/22/12.
//

#import "RCNetworkCell.h"

@implementation RCNetworkCell
@synthesize channel, white;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.channel = nil;
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
		self.backgroundColor = [UIColor clearColor];
		self.white = NO;
		fakeWhite = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	[UIColorFromRGB(0x1B1B23) set];
	UIRectFill(CGRectMake(0, 0, rect.size.width, rect.size.height));
	UIImage *arrow = [UIImage imageNamed:@"0_arrowr"];
	[arrow drawInRect:CGRectMake(232, 14, 16, 16)];
	UIImage *ul = [UIImage imageNamed:@"0_underline"];
	[ul drawAsPatternInRect:CGRectMake(0, rect.size.height-2, rect.size.width, 2)];
	if (!self.channel) return;
	BOOL isPM = (![self.channel hasPrefix:@"#"] && ![self.channel isEqualToString:@"IRC"]);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0, [UIColor blackColor].CGColor);
	UIColor *def = [UIColor colorWithRed:0.529 green:0.549 blue:0.580 alpha:1.000];
	if (white || fakeWhite) def = [UIColor whiteColor];
	CGContextSetFillColorWithColor(ctx, def.CGColor);
	CGContextScaleCTM(ctx, [[UIScreen mainScreen] scale], [[UIScreen mainScreen] scale]);
	[channel drawInRect:CGRectMake((isPM ? 18 : 5), (isPM ? 4 : 5), 200, 40) withFont:[UIFont boldSystemFontOfSize:9] lineBreakMode:UILineBreakModeCharacterWrap alignment:UITextAlignmentLeft];
	if (isPM) {
		UIImage *bubl = [UIImage imageNamed:@"0_pbubl"];
		NSLog(@"HI %@", NSStringFromCGSize(bubl.size));
		[bubl drawInRect:CGRectMake(4, 4, 12, 12)];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	fakeWhite = YES;
	[self setNeedsDisplay];
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	fakeWhite = NO;
	[self setNeedsDisplay];
	[super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	fakeWhite = NO;
	[self setNeedsDisplay];
	[super touchesEnded:touches withEvent:event];
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
}

@end
