//
//  NSMutableAttributedString+NSMutableAttributedString_RCAdditions.m
//  Relay
//
//  Created by Max Shavrick on 7/22/14.
//

#import "NSMutableAttributedString+RCAdditions.h"
#import <UIKit/UIKit.h>

@implementation NSMutableAttributedString (NSMutableAttributedString_RCAdditions)

- (void)setBoldFontInRange:(NSRange)range {
	[self addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:14] range:range];
}

- (void)setItalicFontInRange:(NSRange)range {
	[self addAttribute:NSFontAttributeName value:[UIFont italicSystemFontOfSize:14] range:range];
}

- (void)setUnderlineInRange:(NSRange)range {
	[self addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:range];
}

@end
