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
- (void)dealloc {
	self.attributedString = nil;
	self.message = nil;
	self.sender = nil;
	[super dealloc];
}

@end
