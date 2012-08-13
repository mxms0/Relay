//
//  CHAttributedString.m
//  Relay
//
//  Created by Max Shavrick on 5/21/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCAttributedString.h"

@implementation NSMutableAttributedString (Moar_Stuff)

CGPoint CGPointFlipped(CGPoint point, CGRect bounds);
CGRect CGRectFlipped(CGRect rect, CGRect bounds);
NSRange NSRangeFromCFRange(CFRange range);
CGRect CTLineGetTypographicBoundsAsRect(CTLineRef line, CGPoint lineOrigin);
CGRect CTRunGetTypographicBoundsAsRect(CTRunRef run, CTLineRef line, CGPoint lineOrigin);
BOOL CTLineContainsCharactersFromStringRange(CTLineRef line, NSRange range);
BOOL CTRunContainsCharactersFromStringRange(CTRunRef run, NSRange range);

CTTextAlignment CTTextAlignmentFromUITextAlignment(UITextAlignment alignment) {
	switch (alignment) {
		case UITextAlignmentLeft: return kCTLeftTextAlignment;
		case UITextAlignmentCenter: return kCTCenterTextAlignment;
		case UITextAlignmentRight: return kCTRightTextAlignment;
		default: return kCTNaturalTextAlignment;
	}
}

CTLineBreakMode CTLineBreakModeFromUILineBreakMode(UILineBreakMode lineBreakMode) {
	switch (lineBreakMode) {
		case UILineBreakModeWordWrap: return kCTLineBreakByWordWrapping;
		case UILineBreakModeCharacterWrap: return kCTLineBreakByCharWrapping;
		case UILineBreakModeClip: return kCTLineBreakByClipping;
		case UILineBreakModeHeadTruncation: return kCTLineBreakByTruncatingHead;
		case UILineBreakModeTailTruncation: return kCTLineBreakByTruncatingTail;
		case UILineBreakModeMiddleTruncation: return kCTLineBreakByTruncatingMiddle;
		default: return 0;
	}
}

- (CGFloat)heightForOrientation:(BOOL)isLandscape {
	return [(NSNumber *)objc_getAssociatedObject(self, (const void *)(isLandscape ? "_landscapeHeight" : "_portraitHeight")) floatValue];
}

- (void)setTextHeight:(CGFloat)height forOrientation:(BOOL)isLandscape {
	objc_setAssociatedObject(self, (const void *)(isLandscape ? "_landscapeHeight" : "_portraitHeight"), [NSNumber numberWithFloat:height], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setFont:(UIFont *)font {
	[self setFontName:font.fontName size:font.pointSize];
}
- (void)setFont:(UIFont *)font range:(NSRange)range {
	[self setFontName:font.fontName size:font.pointSize range:range];
}
- (void)setFontName:(NSString *)fontName size:(CGFloat)size {
	[self setFontName:fontName size:size range:NSMakeRange(0,[self length])];
}
- (void)setFontName:(NSString *)fontName size:(CGFloat)size range:(NSRange)range {
	// kCTFontAttributeName
	CTFontRef aFont = CTFontCreateWithName((CFStringRef)fontName, size, NULL);
	if (!aFont) return;
	[self removeAttribute:(NSString *)kCTFontAttributeName range:range]; // Work around for Apple leak
	[self addAttribute:(NSString *)kCTFontAttributeName value:(id)aFont range:range];
	CFRelease(aFont);
}
- (void)setFontFamily:(NSString *)fontFamily size:(CGFloat)size bold:(BOOL)isBold italic:(BOOL)isItalic range:(NSRange)range {
	// kCTFontFamilyNameAttribute + kCTFontTraitsAttribute
	CTFontSymbolicTraits symTrait = (isBold?kCTFontBoldTrait:0) | (isItalic?kCTFontItalicTrait:0);
	NSDictionary* trait = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:symTrait] forKey:(NSString *)kCTFontSymbolicTrait];
	NSDictionary* attr = [NSDictionary dictionaryWithObjectsAndKeys:
						  fontFamily,kCTFontFamilyNameAttribute,
						  trait,kCTFontTraitsAttribute,nil];
	
	CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((CFDictionaryRef)attr);
	if (!desc) return;
	CTFontRef aFont = CTFontCreateWithFontDescriptor(desc, size, NULL);
	CFRelease(desc);
	if (!aFont) return;
	
	[self removeAttribute:(NSString *)kCTFontAttributeName range:range]; // Work around for Apple leak
	[self addAttribute:(NSString *)kCTFontAttributeName value:(id)aFont range:range];
	CFRelease(aFont);
}

- (void)setTextColor:(UIColor *)color {
	[self setTextColor:color range:NSMakeRange(0,[self length])];
}
- (void)setTextColor:(UIColor *)color range:(NSRange)range {
	// kCTForegroundColorAttributeName
	[self removeAttribute:(NSString *)kCTForegroundColorAttributeName range:range]; // Work around for Apple leak
	[self addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)color.CGColor range:range];
}

- (void)setTextIsUnderlined:(BOOL)underlined {
	[self setTextIsUnderlined:underlined range:NSMakeRange(0,[self length])];
}
- (void)setTextIsUnderlined:(BOOL)underlined range:(NSRange)range {
	int32_t style = underlined ? (kCTUnderlineStyleSingle|kCTUnderlinePatternSolid) : kCTUnderlineStyleNone;
	[self setTextUnderlineStyle:style range:range];
}
- (void)setTextUnderlineStyle:(int32_t)style range:(NSRange)range {
	[self removeAttribute:(NSString *)kCTUnderlineStyleAttributeName range:range]; // Work around for Apple leak
	[self addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:style] range:range];
}

- (void)setTextBold:(BOOL)isBold range:(NSRange)range {
	NSUInteger startPoint = range.location;
	NSRange effectiveRange;
	do {
		// Get font at startPoint
        CTFontRef currentFont;
        
        @try {
            currentFont = (CTFontRef)[self attribute:(NSString *)kCTFontAttributeName atIndex:startPoint effectiveRange:&effectiveRange];
        }
        @catch (NSException *exception) {
            return;
        }
        // The range for which this font is effective
		NSRange fontRange = NSIntersectionRange(range, effectiveRange);
		// Create bold/unbold font variant for this font and apply
		CTFontRef newFont = CTFontCreateCopyWithSymbolicTraits(CTFontCreateWithName(CFSTR("Helvetica"), 11, NULL), 0.0, NULL, (isBold?kCTFontBoldTrait:0), kCTFontBoldTrait);
		if (newFont) {
			[self removeAttribute:(NSString *)kCTFontAttributeName range:fontRange]; // Work around for Apple leak
			[self addAttribute:(NSString *)kCTFontAttributeName value:(id)newFont range:fontRange];
			CFRelease(newFont);
		}
		else {
			NSString *fontName = @"Helvetica-Bold";
			NSLog(@"[OHAttributedLabel] Warning: can't find a bold font variant for font %@. Try another font family (like Helvetica) instead.",fontName);
		}
		////[self removeAttribute:(NSString *)kCTFontWeightTrait range:fontRange]; // Work around for Apple leak
		////[self addAttribute:(NSString *)kCTFontWeightTrait value:(id)[NSNumber numberWithInt:1.0f] range:fontRange];
		
		// If the fontRange was not covering the whole range, continue with next run
		startPoint = NSMaxRange(effectiveRange);
	} while (startPoint < NSMaxRange(range));
}

- (void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode {
	[self setTextAlignment:alignment lineBreakMode:lineBreakMode range:NSMakeRange(0,[self length])];
}
- (void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode range:(NSRange)range {
	// kCTParagraphStyleAttributeName > kCTParagraphStyleSpecifierAlignment
	CTParagraphStyleSetting paraStyles[2] = {
		{.spec = kCTParagraphStyleSpecifierAlignment, .valueSize = sizeof(CTTextAlignment), .value = (const void *)&alignment},
		{.spec = kCTParagraphStyleSpecifierLineBreakMode, .valueSize = sizeof(CTLineBreakMode), .value = (const void *)&lineBreakMode},
	};
	CTParagraphStyleRef aStyle = CTParagraphStyleCreate(paraStyles, 2);
	[self removeAttribute:(NSString *)kCTParagraphStyleAttributeName range:range]; // Work around for Apple leak
	[self addAttribute:(NSString *)kCTParagraphStyleAttributeName value:(id)aStyle range:range];
	CFRelease(aStyle);
}

@end

@implementation NSAttributedString (Stuff)

- (CGFloat)boundingHeightForWidth:(CGFloat)inWidth {
	CGFloat height = 0;
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString ( (CFMutableAttributedStringRef) self);
	CGRect box = CGRectMake(0,0, inWidth, CGFLOAT_MAX);
	CFIndex startIndex = 0;
	CGMutablePathRef path = CGPathCreateMutable(); 
	CGPathAddRect(path, NULL, box);
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(startIndex, 0), path, NULL);
	CFArrayRef lineArray = CTFrameGetLines(frame); 
	CFIndex j = 0, lineCount = CFArrayGetCount(lineArray); 
	CGFloat lineHeight, ascent, descent, leading;
	for (j = 0; j < lineCount; j++) {
		CTLineRef currentLine = (CTLineRef)CFArrayGetValueAtIndex(lineArray, j);
		CTLineGetTypographicBounds(currentLine, &ascent, &descent, &leading);      
		lineHeight = ascent + descent + leading;
		height += lineHeight;
	}
	CFRelease(frame);
	CFRelease(path);
	CFRelease(framesetter);
	return height;
}
+ (id)attributedStringWithString:(NSString *)string {
	return string ? [[[self alloc] initWithString:string] autorelease] : nil;
}
+ (id)attributedStringWithAttributedString:(NSAttributedString *)attrStr {
	return attrStr ? [[[self alloc] initWithAttributedString:attrStr] autorelease] : nil;
}
- (CGSize)sizeConstrainedToSize:(CGSize)maxSize {
	return [self sizeConstrainedToSize:maxSize fitRange:NULL];
}
- (CGSize)sizeConstrainedToSize:(CGSize)maxSize fitRange:(NSRange *)fitRange {
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self);
	CFRange fitCFRange = CFRangeMake(0,0);
	CGSize sz = CTFramesetterSuggestFrameSizeWithConstraints(framesetter,CFRangeMake(0,0),NULL,maxSize,&fitCFRange);
	if (framesetter) CFRelease(framesetter);
	if (fitRange) *fitRange = NSMakeRange(fitCFRange.location, fitCFRange.length);
	return CGSizeMake( floorf(sz.width+1) , floorf(sz.height+1) ); // take 1pt of margin for security
}
@end
