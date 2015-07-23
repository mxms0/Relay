//
//  RANavigationBar.m
//  Relay IRC
//
//  Created by Max Shavrick on 7/22/15.
//  Copyright (c) 2015 Mxms. All rights reserved.
//

#import "RANavigationBar.h"
#import "Relay.h"

@implementation RANavigationBar
@synthesize titleText, subtitleText;

- (instancetype)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self commonInit];
	}
	return self;
}

- (instancetype)init {
	if ((self = [super init])) {
		[self commonInit];
	}
	return self;
}

- (void)setTapDelegate:(id<RANavigationBarButtonDelegate>)tapDelegate {
	[menuButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
	[menuButton addTarget:tapDelegate action:@selector(navigationBarButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)commonInit {
	menuButton = [[RANavigationBarButton alloc] init];
	[menuButton setBackgroundColor:[UIColor clearColor]];
	[self addSubview:menuButton];
	[menuButton release];
	self.titleText = @"Relay";
	self.subtitleText = @"Welcome to Relay";
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[menuButton setFrame:CGRectMake(60, -1, self.frame.size.width - 120, self.frame.size.height - 4)];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[[UIColor colorWithRed:49/255.0 green:67/255.0 blue:82/255.0 alpha:1.0] set];
	UIRectFill(rect);
	[[UIColor colorWithRed:42/255.0 green:57/255.0 blue:71/255.0 alpha:1.0] set];
	UIRectFill(CGRectMake(0, rect.size.height - 5, rect.size.width, 5));
	
	
	
	CGFloat cardWidth = rect.size.width;

	CGFloat buttonWidth = 45.f; // fallback.
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	UIColor *shadowColor = nil;
	UIColor *fillColor = nil;
	CGSize shadowOffset = CGSizeZero;
	shadowColor = [UIColor colorWithWhite:0.0 alpha:0.2];
	fillColor = [UIColor whiteColor];
	shadowOffset = CGSizeMake(0, 1);
	
	[UIColorFromRGB(0x293d4d) set];
	UIRectFill(CGRectMake(0, rect.size.height-3, rect.size.width, 3));
	
	CGContextSetShadowWithColor(ctx, shadowOffset, 1, shadowColor.CGColor);
	CGContextSetFillColorWithColor(ctx, fillColor.CGColor);
	
	CGFloat maxWidth = (cardWidth - 90.f);
	
	CGFloat titleSize = 0.f;
	CGFloat subtitleSize = 0.f;
	CGSize titleSpace;
	CGSize subtitleSpace;
	
	titleSpace = [titleText sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:18] minFontSize:12 actualFontSize:&titleSize forWidth:maxWidth lineBreakMode:NSLineBreakByClipping];
	subtitleSpace = [subtitleText sizeWithFont:[UIFont systemFontOfSize:11] minFontSize:10 actualFontSize:&subtitleSize forWidth:maxWidth lineBreakMode:NSLineBreakByClipping];
	
	CGFloat totalHeight = roundf(titleSpace.height + 2.f + subtitleSpace.height);
	CGFloat contentY = roundf(rect.size.height/2 - totalHeight/2) - (subtitleSize == 0.0 ? 7.f : 5.f); // don't ask me why the +5.f -theiostream
	if ([[self subviews] count] == 0) {
		contentY -= 7;
	}
	
	[titleText drawInRect:CGRectMake(buttonWidth + 5.f, contentY, cardWidth - (buttonWidth+5.f)*2, titleSpace.height) withFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:titleSize] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
	[subtitleText drawInRect:CGRectMake(buttonWidth + 5.f, contentY + titleSpace.height + 2.f, cardWidth - (buttonWidth+5.f)*2, subtitleSpace.height) withFont:[UIFont systemFontOfSize:subtitleSize] lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
	
}

@end
