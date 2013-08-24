//
//  RCChannelCell.m
//  Relay
//
//  Created by Max Shavrick on 6/22/12.
//

#import "RCChannelCell.h"

@implementation RCChannelCell
@synthesize channel, white, newMessageCount, hasHighlights, drawUnderline;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	// rewrite this entirely.
	CGSize shadowSize = CGSizeMake(0, -1);
	UIColor *shadowColor = [UIColor blackColor];
	if ([[RCSchemeManager sharedInstance] isDark]) {
		[UIColorFromRGB(0x3d3d40) set];
	}
	else {
		[UIColorFromRGB(0xf0f0f0) set];
		shadowSize = CGSizeZero;
		shadowColor = [UIColor clearColor];
	}
	UIRectFill(rect);
	if (!self.channel) return;
	BOOL isPM = (![self.channel hasPrefix:@"#"] && ![self.channel hasPrefix:@"\x01"]);
	UIColor *def = UIColorFromRGB(0xcfcfcf);
	if (white || fakeWhite) {
		def = UIColorFromRGB(0xfbf8f8);
		[UIColorFromRGB(0x61999c) set];
		UIRectFill(rect);
		if ([[RCSchemeManager sharedInstance] isDark]) {
			def = UIColorFromRGB(0x2A2E37);
		}
		else {
			def = [UIColor whiteColor];
		}
	}
	else {
		if ([[RCSchemeManager sharedInstance] isDark]) {
			
		}
		else {
			def = UIColorFromRGB(0x666666);
		}
	}
	if (drawUnderline) {
		[UIColorFromRGB(0x49494C) set];
		UIRectFill(CGRectMake(0, rect.size.height-1, rect.size.width, 1));
		[UIColorFromRGB(0x161618) set];
		UIRectFill(CGRectMake(0, rect.size.height-1, rect.size.width, .5));
	}
	else {
		[UIColorFromRGB(0x161618) set];
		UIRectFill(CGRectMake(0, rect.size.height-.5, rect.size.width, .5));
	}
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSetShadowWithColor(ctx, shadowSize, 0, shadowColor.CGColor);
	CGContextSetFillColorWithColor(ctx, def.CGColor);
	CGContextScaleCTM(ctx, [[UIScreen mainScreen] scale], [[UIScreen mainScreen] scale]);
	[channel drawAtPoint:CGPointMake(20, 3) forWidth:(newMessageCount > 0 ? (newMessageCount > 99 ? 90 : 95) : 95) withFont:[UIFont systemFontOfSize:8] minFontSize:5 actualFontSize:NULL lineBreakMode:NSLineBreakByCharWrapping baselineAdjustment:UIBaselineAdjustmentAlignCenters];
	UIImage *glyph = nil;
	if (isPM) {
		glyph = [[RCSchemeManager sharedInstance] imageNamed:@"usericon"];
	}
	else {
		glyph = [[RCSchemeManager sharedInstance] imageNamed:@"channellisticon"];
	}
	[glyph drawInRect:CGRectMake(4, 4, glyph.size.width * .6, glyph.size.height * .6) blendMode:kCGBlendModeNormal alpha:0.5];
	if (newMessageCount > 0) {
		NSString *rendr = @"";
		if (newMessageCount > 99) {
			rendr = @"99+";
		}
		else {
			rendr = [NSString stringWithFormat:@"%d", newMessageCount];
		}
	//	UIImage *bubble = [UIImage imageNamed:@"highlightbadge"];
	//	[bubble drawInRect:CGRectMake(100, 2, 10, 12)];
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

- (id)description {
	return [NSString stringWithFormat:@"<%@: %p; frame = %@; channel = %@", NSStringFromClass([self class]), self, NSStringFromCGRect(self.frame), self.channel];
}

@end
