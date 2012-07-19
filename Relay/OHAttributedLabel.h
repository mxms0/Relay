/***********************************************************************************
 *
 * Copyright (c) 2010 Olivier Halligon
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 ***********************************************************************************
 *
 * Created by Olivier Halligon  (AliSoftware) on 20 Jul. 2010.
 *
 * Any comment or suggestion welcome. Please contact me before using this class in
 * your projects. Referencing this project in your AboutBox/Credits is appreciated.
 *
 ***********************************************************************************/


#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "CHAttributedString.h"

CTTextAlignment CTTextAlignmentFromUITextAlignment(UITextAlignment alignment);
CTLineBreakMode CTLineBreakModeFromUILineBreakMode(UILineBreakMode lineBreakMode);

@class OHAttributedLabel;
@protocol OHAttributedLabelDelegate <NSObject>
@optional
- (BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo;
- (UIColor *)colorForLink:(NSTextCheckingResult *)linkInfo underlineStyle:(int32_t *)underlineStyle; //!< Combination of CTUnderlineStyle and CTUnderlineStyleModifiers
@end

#define UITextAlignmentJustify ((UITextAlignment)kCTJustifiedTextAlignment)

@interface OHAttributedLabel : UILabel {
	RCAttributedString *_attributedText;
	CTFrameRef textFrame;
	CGRect drawingRect;
	NSMutableArray *customLinks;
	NSTextCheckingResult *activeLink;
	CGPoint touchStartPoint;
}

@property (nonatomic, copy) RCAttributedString* attributedText;
- (void)resetAttributedText;
@property (nonatomic, assign) NSTextCheckingTypes automaticallyAddLinksForType;
@property (nonatomic, retain) UIColor *linkColor;
@property (nonatomic, retain) UIColor *highlightedLinkColor;
@property (nonatomic, assign) BOOL underlineLinks;
- (void)addCustomLink:(NSURL *)linkUrl inRange:(NSRange)range;
- (void)removeAllCustomLinks;
@property (nonatomic, assign) BOOL onlyCatchTouchesOnLinks;
@property (nonatomic, assign) IBOutlet id <OHAttributedLabelDelegate> delegate;
@property (nonatomic, assign) BOOL centerVertically;
@property (nonatomic, assign) BOOL extendBottomToFit;
@end
