//
//  RCChatNavigationBar.m
//  Relay
//
//  Created by Max Shavrick on 10/27/12.
//

#import "RCChatNavigationBar.h"
#import "RCChatController.h"

@implementation RCChatNavigationBar
@synthesize subtitle, title, isMain, drawIndent;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		title = nil;
		subtitle = nil;
		drawIndent = NO;
		isMain = NO;
		CALayer *hshdw = [[CALayer alloc] init];
		UIImage *hfs = [UIImage imageNamed:@"0_vzshdw"];
		[hshdw setContents:(id)hfs.CGImage];
		[hshdw setShouldRasterize:YES];
		[hshdw setFrame:CGRectMake(0, 44, 320, hfs.size.height)];
		// assuming the iphone app always launches in portrait..
		// and assuming the iphone never changes it's width...
		// for some reason apple passes CGRectZero as the frame.
		// lame.
		[self.layer setMasksToBounds:NO];
		[self.layer addSublayer:hshdw];
		[hshdw release];
		UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 320, 48) byRoundingCorners:UIRectCornerTopLeft| UIRectCornerTopRight cornerRadii:CGSizeMake(4.5, 4.5)];
		CAShapeLayer *maskLayer = [CAShapeLayer layer];
		maskLayer.frame = CGRectMake(0, 0, 320, 48);
		maskLayer.path = maskPath.CGPath;
		self.layer.mask = maskLayer;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	self.layer.mask.frame = CGRectMake(0, 0, frame.size.width, frame.size.height+4);
	UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.layer.mask.frame byRoundingCorners:UIRectCornerTopLeft| UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
	CAShapeLayer *shp = (CAShapeLayer *)self.layer.mask;
	shp.path = maskPath.CGPath;
}

- (void)setIsMain:(BOOL)_isMain {
	if (isMain) return;
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	[btn setFrame:CGRectMake(55, 2, 218, 40)];
	[btn setBackgroundColor:[UIColor clearColor]];
	[btn addTarget:[RCChatController sharedController] action:@selector(showMenuOptions:) forControlEvents:UIControlEventTouchUpInside];
	[btn setTag:1132];
	[self addSubview:btn];
	isMain = _isMain;
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	UIImage *bg = [UIImage imageNamed:@"0_headr"];
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	[bg drawAtPoint:CGPointMake(0, 0)];
	if (drawIndent) {
		UIImage *indent = [UIImage imageNamed:@"0_indents"];
		[indent drawAtPoint:CGPointMake(0, 2)];
		return;
	}
	CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0, [UIColor whiteColor].CGColor);
	CGContextSetFillColorWithColor(ctx, UIColorFromRGB(0x282C40).CGColor);
	CGFloat size = 0.0;
	float maxWidth = (rect.size.width-100);
	[title sizeWithFont:[UIFont boldSystemFontOfSize:22] minFontSize:18 actualFontSize:&size forWidth:maxWidth lineBreakMode:UILineBreakModeClip];
	[title drawInRect:CGRectMake((!!subtitle ? 50 : 30), (!!subtitle ? 1.5 : (((rect.size.height-4)/2)-(size/2))), maxWidth, 30) withFont:[UIFont boldSystemFontOfSize:size] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
	if (subtitle) {
		CGFloat subsze = 0.0;
		[subtitle sizeWithFont:[UIFont systemFontOfSize:12] minFontSize:11 actualFontSize:&subsze forWidth:maxWidth lineBreakMode:UILineBreakModeClip];
		CGContextSetFillColorWithColor(ctx, UIColorFromRGB(0x626464).CGColor);
		[subtitle drawInRect:CGRectMake(50, 3+size, maxWidth, 14) withFont:[UIFont systemFontOfSize:subsze] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
	}
}

- (void)dealloc {
	[title release];
	[subtitle release];
	[super dealloc];
}

@end
