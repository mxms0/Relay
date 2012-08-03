//
//  RCMessage.m
//  Relay
//
//  Created by Max Shavrick on 2/20/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCMessage.h"

@implementation RCMessage
@synthesize string, messageHeight, messageHeightLandscape;

- (void) encodeWithCoder: (NSCoder *)coder {
	[coder encodeObject:([self.string isKindOfClass:[NSAttributedString class]] ? ((NSAttributedString *)self.string).string : self.string) forKey:@"0_MSGKEY"];
	[coder encodeObject:[NSNumber numberWithFloat:messageHeight] forKey:@"0_MSGHEIGHT_0"];
	[coder encodeObject:[NSNumber numberWithFloat:messageHeightLandscape] forKey:@"0_MSGHEIGHT_1"];
	[coder encodeObject:[NSNumber numberWithInt:flavor] forKey:@"0_MSGFLAV"];
}

- (id)initWithCoder:(NSCoder *)coder {
	if ([coder containsValueForKey:@"0_MSGKEY"]) {
		self = [self initWithMessage:[coder decodeObjectForKey:@"0_MSGKEY"] isOld:YES isMine:NO isHighlight:NO flavor:[[coder decodeObjectForKey:@"0_MSGFLAV"] intValue]];
		messageHeight = [[coder decodeObjectForKey:@"0_MSGHEIGHT_0"] floatValue];
		messageHeightLandscape = [[coder decodeObjectForKey:@"0_MSGHEIGHT_1"] floatValue];
		return self;
	}
	return nil;
}

- (id)description {
	return [NSString stringWithFormat:@"<%@ :%p; Message = %@; Height = %f;", NSStringFromClass([self class]), self, self.string, messageHeight];
}

- (id)initWithMessage:(NSString *)_message isOld:(BOOL)old isMine:(BOOL)m isHighlight:(BOOL)hh flavor:(RCMessageFlavor)_flavor {
	RCAttributedString *_string = nil;
	if ((self = [super init])) {
		_string = [[RCAttributedString alloc] initWithString:_message];
		flavor = _flavor;
	}
	self.minificationFilter = kCAFilterNearest;
	self.contentsScale = [[UIScreen mainScreen] scale];
	self.rasterizationScale = [[UIScreen mainScreen] scale];
	[_string setFont:[UIFont fontWithName:@"Helvetica" size:12]];
	UIColor *normalColor = UIColorFromRGB(0x3F4040);
	if (old)
		normalColor = UIColorFromRGB(0xB6BCCC);
	[_string setTextColor:normalColor];
	switch (flavor) {
		case RCMessageFlavorAction:
			[_string setTextIsUnderlined:NO range:NSMakeRange(0, _message.length)];
			[_string setTextBold:YES range:NSMakeRange(0, _message.length)];
			[_string setTextAlignment:CTTextAlignmentFromUITextAlignment(UITextAlignmentCenter) lineBreakMode:CTLineBreakModeFromUILineBreakMode(UILineBreakModeClip)];
			break;
		case RCMessageFlavorNormal: {
			if (hh) {
				if (!old)
					[_string setTextColor:UIColorFromRGB(0xDA4156)];
				else [_string setTextColor:UIColorFromRGB(0xB6BCCC)];
			}
			NSRange p = [_message rangeOfString:@"]"];
			NSRange r = [_message rangeOfString:@":" options:0 range:NSMakeRange(p.location, _message.length-p.location)];
			[_string setTextBold:YES range:NSMakeRange(0, r.location)];
			break;
		}
		case RCMessageFlavorNotice:
			[_string setTextBold:YES range:NSMakeRange(0, _message.length)];
			// do something.
			break;
		case RCMessageFlavorTopic:
			[_string setTextAlignment:CTTextAlignmentFromUITextAlignment(UITextAlignmentCenter) lineBreakMode:CTLineBreakModeFromUILineBreakMode(UILineBreakModeWordWrap)];
			break;
		case RCMessageFlavorJoin:
			[_string setFont:[UIFont fontWithName:@"Helvetica" size:11]];
			[_string setTextAlignment:CTTextAlignmentFromUITextAlignment(UITextAlignmentCenter) lineBreakMode:CTLineBreakModeFromUILineBreakMode(UILineBreakModeWordWrap)];
			break;
		case RCMessageFlavorPart:
			[_string setFont:[UIFont fontWithName:@"Helvetica" size:11]];
			[_string setTextAlignment:CTTextAlignmentFromUITextAlignment(UITextAlignmentCenter) lineBreakMode:CTLineBreakModeFromUILineBreakMode(UILineBreakModeWordWrap)];
			break;
		case RCMessageFlavorNormalE:
			//	[attr setTextBold:YES range:NSMakeRange(0, _message.length)];
			break;
	}
	self.string = _string;
	return self;
}

- (void)dealloc {
	[super dealloc];
}
@end
