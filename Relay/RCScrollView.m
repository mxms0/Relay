//
//  RCScrollView.m
//  Relay
//
//  Created by Max Shavrick on 7/27/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCScrollView.h"
#import <CoreText/CoreText.h>
#import "RCAttributedString.h"
#import "RCMessageFormatter.h"

@implementation RCScrollView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self setBackgroundColor:[UIColor clearColor]];
		[self setCanCancelContentTouches:YES];
		y = 4;
		self.pagingEnabled = NO;
		shouldScroll = YES;
		stringToDraw = [[NSMutableAttributedString alloc] init];
		self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeRedraw;
		[self setScrollEnabled:YES];
		[self setDelegate:self];
	}
	return self;
}

- (void)layoutMessage:(RCMessageFormatter *)ms {
	if (![[[ms string] string] isEqualToString:@""]) {
		[stringToDraw appendAttributedString:[ms string]];
	}
	[ms release];
	ms = nil;
	[self resetContentSize];
}

- (void)resetContentSize {
	if (!stringToDraw) return;
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)stringToDraw);
	CFRange destRange = CFRangeMake(0, 0);
    CFRange sourceRange = CFRangeMake(0, stringToDraw.length);
	CGSize frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, sourceRange, NULL, CGSizeMake(self.frame.size.width, CGFLOAT_MAX), &destRange);
	self.contentSize = CGSizeMake(self.bounds.size.width, frameSize.height);
    CFRelease(framesetter);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	shouldScroll = NO;
	MARK;	
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	MARK;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	MARK;
}

- (void) drawRect:(CGRect)rect {
	[super drawRect:rect];
	if (!stringToDraw) return;
	CGContextRef context = UIGraphicsGetCurrentContext();
	
    // Flip the context
	CGContextSetShadowWithColor(context, CGSizeMake(0, 1.0), 0, [UIColor colorWithWhite:0 alpha:0.5].CGColor);
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, self.contentSize.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGMutablePathRef path = CGPathCreateMutable();
    CGRect destRect = (CGRect){.size = self.contentSize};
	CGPathAddRect(path, NULL, destRect);
	
    // Create framesetter
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)stringToDraw);
	
	// Draw the text
	CTFrameRef theFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, stringToDraw.length), path, NULL);
	CTFrameDraw(theFrame, context);
	
    // Clean up
	CFRelease(path);
	CFRelease(theFrame);
	CFRelease(framesetter);
}

@end
