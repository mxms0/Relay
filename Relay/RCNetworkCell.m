//
//  RCNetworkCell.m
//  Relay
//
//  Created by Max Shavrick on 6/22/12.
//

#import "RCNetworkCell.h"

@implementation RCNetworkCell
@synthesize channel, white, newMessageCount, joined;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.channel = nil;
		[self setSelectionStyle:UITableViewCellSelectionStyleNone];
		self.backgroundColor = [UIColor clearColor];
		self.white = NO;
		fakeWhite = NO;
		self.newMessageCount = 0;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	[[UIColor colorWithRed:0.079 green:0.089 blue:0.118 alpha:1.000] set];
	[UIColorFromRGB(0x1B1B23) set];
	UIRectFill(CGRectMake(0, 0, rect.size.width, rect.size.height));
	UIImage *arrow = [UIImage imageNamed:@"0_arrowr"];
	[arrow drawInRect:CGRectMake(232, 14, 16, 16)];
	UIImage *ul = [UIImage imageNamed:@"0_underline"];
	[ul drawAsPatternInRect:CGRectMake(0, rect.size.height-2, rect.size.width, 2)];
	if (!self.channel) return;
	BOOL isPM = (![self.channel hasPrefix:@"#"] && ![self.channel hasPrefix:@"\x01"]);
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0, [UIColor blackColor].CGColor);
	UIColor *def = [UIColor colorWithRed:0.529 green:0.549 blue:0.580 alpha:1.000];
	if (white || fakeWhite) def = [UIColor whiteColor];
	CGContextSetFillColorWithColor(ctx, def.CGColor);
	CGContextScaleCTM(ctx, [[UIScreen mainScreen] scale], [[UIScreen mainScreen] scale]);

	[channel drawAtPoint:CGPointMake((isPM ? 18 : 5), (isPM ? 4 : 5)) forWidth:(newMessageCount > 0 ? (newMessageCount > 99 ? 90 : 95) : 110) withFont:[UIFont boldSystemFontOfSize:9] minFontSize:5 actualFontSize:NULL lineBreakMode:UILineBreakModeCharacterWrap baselineAdjustment:UIBaselineAdjustmentAlignCenters];
	if (isPM) {
		UIImage *bubl = [UIImage imageNamed:@"0_pbubl"];
		[bubl drawInRect:CGRectMake(4, 4, 12, 12)];
	}
	if (newMessageCount > 0) {
		int len = 0;
		NSString *rendr = @"";
		if (newMessageCount > 99) {
			rendr = @"99+";
		}
		else {
			rendr = [NSString stringWithFormat:@"%d", newMessageCount];
		}
		len = [rendr sizeWithFont:[UIFont boldSystemFontOfSize:7.5]].width;
		// sorry. :s
		// it's not my fault! i promise. surenix did it!
		BOOL longerThanNormal = ([rendr isEqualToString:@"99+"]);
		CGFloat radius = 5.4;;
		CGRect ovalThing = CGRectMake((longerThanNormal ? 95 : 100), 5, (longerThanNormal ? 16 : 11), 11);
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetRGBFillColor(context, 76, 78, 84, 0.4);
		CGContextMoveToPoint(context, ovalThing.origin.x, ovalThing.origin.y + radius);
		CGContextAddLineToPoint(context, ovalThing.origin.x, ovalThing.origin.y + ovalThing.size.height - radius);
		CGContextAddArc(context, ovalThing.origin.x + radius, ovalThing.origin.y + ovalThing.size.height - radius, radius, M_PI, M_PI / 2, 1);
		CGContextAddLineToPoint(context, ovalThing.origin.x + ovalThing.size.width - radius, ovalThing.origin.y + ovalThing.size.height);
		CGContextAddArc(context, ovalThing.origin.x + ovalThing.size.width - radius, ovalThing.origin.y + ovalThing.size.height - radius, radius, M_PI / 2, 0.0f, 1);
		CGContextAddLineToPoint(context, ovalThing.origin.x + ovalThing.size.width, ovalThing.origin.y + radius);
		CGContextAddArc(context, ovalThing.origin.x + ovalThing.size.width - radius, ovalThing.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
		CGContextAddLineToPoint(context, ovalThing.origin.x + radius, ovalThing.origin.y);
		CGContextAddArc(context, ovalThing.origin.x + radius, ovalThing.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
		CGContextFillPath(context);
		CGContextSetFillColorWithColor(context, UIColorFromRGB(0x191A26).CGColor);
		CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 0.5, [UIColor colorWithWhite:1 alpha:0.2].CGColor);
		[rendr drawAtPoint:CGPointMake((longerThanNormal ? 97 : (newMessageCount <= 9 ? 103 : 101)), 5) forWidth:50 withFont:[UIFont boldSystemFontOfSize:7.5] fontSize:7.5 lineBreakMode:UILineBreakModeClip baselineAdjustment:UIBaselineAdjustmentAlignCenters];
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
