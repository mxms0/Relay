//
//  NSMutableAttributedString+NSMutableAttributedString_RCAdditions.h
//  Relay
//
//  Created by Max Shavrick on 7/22/14.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface NSMutableAttributedString (NSMutableAttributedString_RCAdditions)
- (void)setBoldFontInRange:(NSRange)range;
- (void)setItalicFontInRange:(NSRange)range;
- (void)setUnderlineInRange:(NSRange)range;
@end
