//
//  RCMessageConstruct.m
//  Relay
//
//  Created by Siberia on 6/10/14.
//  Copyright (c) 2014 American Heritage School. All rights reserved.
//

#import "RCMessageConstruct.h"
#import "RCI.h"

static uint32_t mIRCColors[] = {
	0xFFFFFF, // white
	0x000000, // black
	0x000080, // navy/blue
	0x008000, // green
	0xFF0000, // red
	0x800000, // brown/maroon
	0x800080, // purple
	0xFFA500, // orange
	0xFFFF00, // yellow
	0x00FF00, // lime
	0x008080, // teal
	0xE0FFFF, // light cyan
	0xADD8E6, // light blue
	0xFF00FF, // fuschhshsia/pink
	0x808080, // gray
	0xD3D3D3, // light gray
	0xFF1493, // superman ice cream
};

static uint32_t internalColors[] = {
	0x000000, 0x65999d, 0xa03244, 0xd7424c,
	0xb66277, 0xcf5528, 0xb1a433, 0x74bd4b,
	0x0CE887, 0x00D6FF, 0x007EFF, 0x6B7FFF,
	0x895bde, 0x8A0012, 0x8A4500, 0x4c7c8a,
	0x3A8A00, 0x4D038A, 0xa03244, 0xa03244,
	0xa03244, 0xa03244, 0x71afe9, 0xc6b3f1,
	0xd8958e, 0xfa3d44, 0xf56438, 0xebec86,
	0x53d040, 0x1360de, 0x997cd9,
	0xc03436,
	0x7ed172
};


@implementation RCMessageConstruct
@synthesize message, sender, color, attributedString, height, nameWidth, landscapeHeight;

- (id)initWithMessage:(NSString *)_message {
	if ((self = [super init])) {
		self.message = _message;
	}
	return self;
}

- (void)formatWithHighlight:(BOOL)hi {
	NSString *cleaned = [message stringByStrippingIRCMetadata];
	NSMutableArray *attrs = [NSMutableArray array];
	NSMutableDictionary *openAttrs = [NSMutableDictionary dictionary];
	
	int pos = 0;
	NSData *d = [message dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
	const char *buf = d.bytes;
	int32_t len = [d length];
	UChar32 codepoint;
	int ii = 0; // in index
	while (ii < len) {
		U8_NEXT_UNSAFE(buf, ii, codepoint);
		switch (codepoint) {
			case RCIRCAttributeBold:
			case RCIRCAttributeItalic:
			case RCIRCAttributeUnderline: {
				NSNumber *key = @(codepoint);
				RCAttribute *a = openAttrs[key];
				if (!a) {
					a = [[[RCAttribute alloc] initWithType:(char)codepoint start:pos] autorelease];
					[attrs addObject:a];
					openAttrs[key] = a;
				} else {
					a.end = pos;
					[openAttrs removeObjectForKey:key];
				}
				break;
			}
			case RCIRCAttributeReset: {
				for(RCAttribute *a in [openAttrs allValues]) {
					a.end = pos;
				}
				[openAttrs removeAllObjects];
				break;
			}
			case RCIRCAttributeInternalNickname:
			case RCIRCAttributeColor: {
				NSNumber *key = @(codepoint);
				RCAttribute *a = openAttrs[key];
				if(a) {
					a.end = pos;
					[openAttrs removeObjectForKey:key];
				}
				char *end = NULL;
				const char *bnex = buf + ii;
				int fg = strntoi(bnex, 2, &end);
				int bg = -1;
				if(end != bnex) { // We got a colour
					if(*end == ',') { // And a comma
						bg = strntoi(end + 1, 2, &end);
					}
					ii = end - buf;
					a = [[[RCColorAttribute alloc] initWithType:(char)codepoint start:pos fg:fg bg:bg] autorelease];
					[attrs addObject:a];
					openAttrs[key] = a;
				}
				break;
			default:
				pos++;
				break;
			}
		}
	}
	for (RCAttribute *a in [openAttrs allValues]) {
		a.end = pos;
	}
//	NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:cleaned];
//	[string addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, [cleaned length])];
//	for (RCAttribute *attr in attrs) { // Bingo: you now have a string with no crap, and a set of crap.
//		// Boring attributes don't cover any text.
//		if (attr.start == attr.end) continue;
//		switch (attr.type) {
//			case RCIRCAttributeReset:
//				break;
//			case RCIRCAttributeBold:
//				[string setBoldFontInRange:NSMakeRange(attr.start, attr.end-attr.start)];
//				break;
//			case RCIRCAttributeItalic:
//				[string setItalicFontInRange:NSMakeRange(attr.start, attr.end-attr.start)];
//				break;
//			case RCIRCAttributeUnderline:
//				[string setUnderlineInRange:NSMakeRange(attr.start, attr.end-attr.start)];
//				break;
//			case RCIRCAttributeInternalNickname: {
//				RCColorAttribute *cAttr = (RCColorAttribute *)attr;
//				[string addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(internalColors[cAttr.fg]) range:NSMakeRange(attr.start, attr.end - attr.start)];
//				[string setBoldFontInRange:NSMakeRange(attr.start, attr.end - attr.start)];
//				break;
//			}
//			case RCIRCAttributeColor: {
//				RCColorAttribute *cAttr = (RCColorAttribute *)attr;
//				if (cAttr.fg != -1)
//					[string addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(mIRCColors[cAttr.fg]) range:NSMakeRange(attr.start, attr.end - attr.start)];
//				if (cAttr.bg != -1)
//					[string addAttribute:NSBackgroundColorAttributeName value:UIColorFromRGB(mIRCColors[cAttr.bg]) range:NSMakeRange(attr.start, attr.end - attr.start)];
//				break;
//			}
//		}
//	}
//	
//	CGSize width = [sender boundingRectWithSize:CGSizeMake(150, 16) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:14]} context:nil].size;
//	CGFloat cardWidth = [RCViewCard cardWidth];
//	if (isPad) {
//		cardWidth = [RCViewCard iPadCardWidth];
//	}
//	CGFloat properWidth = cardWidth - 18;
//	if (width.width <= 1.000000000) {
//		properWidth -= (width.width + 5);
//	}
//	CGSize size = [TTTAttributedLabel sizeThatFitsAttributedString:string withConstraints:CGSizeMake(cardWidth - width.width - 9 - 9 - 10, 1000) limitedToNumberOfLines:0];
//	if (isPad) {
//		CGSize exSize = [TTTAttributedLabel sizeThatFitsAttributedString:string withConstraints:CGSizeMake([RCViewCard landscapeiPadWidth] - width.width - 9 - 9, 1000) limitedToNumberOfLines:0];
//		landscapeHeight = exSize.height;
//	}
//	height = size.height;
//	self.attributedString = string;
//	nameWidth = width.width;
//	[string release];
}

- (void)dealloc {
	self.attributedString = nil;
	self.message = nil;
	self.sender = nil;
	[super dealloc];
}

@end
