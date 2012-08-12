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
        scrollViewMessageQueue = dispatch_queue_create([[@"SCDISPATCHQUEUE_MSGHANDLE" stringByAppendingString:[self description]] UTF8String], 0ul);
	}
	return self;
}

- (void)dealloc
{
    [stringToDraw release];
    dispatch_release(scrollViewMessageQueue);
    [super dealloc];
}

- (int)scrollback
{
    return 300;
}

- (void)checkScrollback
{
    dispatch_async(scrollViewMessageQueue, ^()
                   {
                       @synchronized(self)
                       {
                           /* this is *very* intensive. should find a better way to do it */
                           while (msgs > [self scrollback]) {
                               NSMutableAttributedString* os = stringToDraw;
                               NSRange rangeForNewlineAndSoOn = [[stringToDraw string] rangeOfString:@"\n"];
                               if (rangeForNewlineAndSoOn.location == NSNotFound) {
                                   NSLog(@"wat."); return;
                               }
                               rangeForNewlineAndSoOn.location++;
                               rangeForNewlineAndSoOn.length = [stringToDraw length] - rangeForNewlineAndSoOn.location;
                               stringToDraw = [[stringToDraw attributedSubstringFromRange:rangeForNewlineAndSoOn] mutableCopy];
                               [os release];
                               msgs--;
                               NSLog(@"- [%p] %d %@", self, msgs, [stringToDraw string]);
                           }
                           [self setNeedsDisplay];
                           
                           
                       }
                   });
}

- (void)layoutMessage:(RCMessageFormatter *)ms {
    dispatch_async(scrollViewMessageQueue, ^(void)
                   {
                       @synchronized(self)
                       {
                           if (![[[ms string] string] isEqualToString:@""]) {
                               [stringToDraw appendAttributedString:[ms string]];
                           }
                           [ms release];
                           msgs ++;
                           [self checkScrollback];
                           [self resetContentSize];
                           NSLog(@"+ [%p] %d", self, msgs);
                           
                       }
                   });
}

- (void)scrollToBottom {
    self.contentOffset = CGPointMake(0, ((self.contentSize.height-self.frame.size.height <= 0) ? 0 : self.contentSize.height-self.frame.size.height));
}

- (void)resetContentSize {
    dispatch_async(scrollViewMessageQueue, ^()
                   {
                       @synchronized(self)
                       {
                           if (!stringToDraw) return;
                           CGFloat kEndPos = self.contentSize.height; 
                           CGFloat kCurPos = self.contentOffset.y + self.frame.size.height;
                           kEndPos = (kEndPos > self.frame.size.height) ? kEndPos : self.frame.size.height;
                           CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)stringToDraw);
                           CFRange destRange = CFRangeMake(0, 0);
                           CFRange sourceRange = CFRangeMake(0, stringToDraw.length);
                           CGSize frameSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, sourceRange, NULL, CGSizeMake(self.frame.size.width, CGFLOAT_MAX), &destRange);
                           dispatch_async(dispatch_get_main_queue(), ^()
                                          {
                                              self.contentSize = CGSizeMake(self.bounds.size.width, frameSize.height);
                                              if (kEndPos <= kCurPos)
                                                  [self scrollToBottom];
                                              [self setNeedsDisplay];
                                          });
                           CFRelease(framesetter);
                       }
                   });
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
    @synchronized(self)
    {
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
        if (!theFrame) {
            return;
        }
        CTFrameDraw(theFrame, context);
        
        // Clean up
        CFRelease(path);
        CFRelease(theFrame); // I KNOW RIGHT YOU FUCKER
        CFRelease(framesetter);
        [super drawRect:rect];
    }
}

@end
