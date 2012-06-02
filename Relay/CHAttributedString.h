//
//  CHAttributedString.h
//  Relay
//
//  Created by Max Shavrick on 5/21/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <objc/runtime.h>

@interface NSAttributedString (Stuff)
+ (id)attributedStringWithString:(NSString *)string;
+ (id)attributedStringWithAttributedString:(NSAttributedString *)attrStr;
- (CGFloat)boundingHeightForWidth:(CGFloat)inWidth;
//! Commodity method that call the following sizeConstrainedToSize:fitRange: method with NULL for the fitRange parameter
- (CGSize)sizeConstrainedToSize:(CGSize)maxSize;
//! if fitRange is not NULL, on return it will contain the used range that actually fits the constrained size.
//! Note: Use CGFLOAT_MAX for the CGSize's height if you don't want a constraint for the height.
- (CGSize)sizeConstrainedToSize:(CGSize)maxSize fitRange:(NSRange *)fitRange;
@end

@interface NSMutableAttributedString (Moar_Stuff)
- (void)setFont:(UIFont *)font;
- (void)setFont:(UIFont *)font range:(NSRange)range;
- (void)setFontName:(NSString *)fontName size:(CGFloat)size;
- (void)setFontName:(NSString *)fontName size:(CGFloat)size range:(NSRange)range;
- (void)setFontFamily:(NSString *)fontFamily size:(CGFloat)size bold:(BOOL)isBold italic:(BOOL)isItalic range:(NSRange)range;
- (void)setTextColor:(UIColor *)color;
- (void)setTextColor:(UIColor *)color range:(NSRange)range;
- (void)setTextIsUnderlined:(BOOL)underlined;
- (void)setTextIsUnderlined:(BOOL)underlined range:(NSRange)range;
- (void)setTextUnderlineStyle:(int32_t)style range:(NSRange)range; //!< style is a combination of CTUnderlineStyle & CTUnderlineStyleModifiers
- (void)setTextBold:(BOOL)isBold range:(NSRange)range;
- (void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode;
- (void)setTextAlignment:(CTTextAlignment)alignment lineBreakMode:(CTLineBreakMode)lineBreakMode range:(NSRange)range;
- (void)setTextHeight:(CGFloat)height forOrientation:(BOOL)isLandscape;
- (CGFloat)heightForOrientation:(BOOL)isLandscape;

@end
