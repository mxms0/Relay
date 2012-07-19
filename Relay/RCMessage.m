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
	[coder encodeObject:string.string forKey:@"0_MSGKEY"];
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
	return [NSString stringWithFormat:@"<%@ :%p; Message = %@; Height = %f;", NSStringFromClass([self class]), self, string.string, messageHeight];
}

- (id)initWithMessage:(NSString *)_message isOld:(BOOL)old isMine:(BOOL)m isHighlight:(BOOL)hh flavor:(RCMessageFlavor)_flavor {
	if ((self = [super init])) {
		string = [[RCAttributedString alloc] initWithString:_message];
		flavor = _flavor;
	}
	[string setFont:[UIFont fontWithName:@"Helvetica" size:12]];
	UIColor *normalColor = UIColorFromRGB(0x3F4040);
	if (old)
		normalColor = UIColorFromRGB(0xB6BCCC);
	[string setTextColor:normalColor];
	switch (flavor) {
		case RCMessageFlavorAction:
			[string setTextIsUnderlined:NO range:NSMakeRange(0, _message.length)];
			[string setTextBold:YES range:NSMakeRange(0, _message.length)];
			[string setTextAlignment:CTTextAlignmentFromUITextAlignment(UITextAlignmentCenter) lineBreakMode:CTLineBreakModeFromUILineBreakMode(UILineBreakModeClip)];
			break;
		case RCMessageFlavorNormal: {
			NSRange p = [_message rangeOfString:@"]"];
			NSRange r = [_message rangeOfString:@":" options:0 range:NSMakeRange(p.location, _message.length-p.location)];
			[string setTextBold:YES range:NSMakeRange(0, r.location)];
			break;
		}
		case RCMessageFlavorNotice:
			[string setTextBold:YES range:NSMakeRange(0, _message.length)];
			// do something.
			break;
		case RCMessageFlavorTopic:
			[string setTextAlignment:CTTextAlignmentFromUITextAlignment(UITextAlignmentCenter) lineBreakMode:CTLineBreakModeFromUILineBreakMode(UILineBreakModeWordWrap)];
			break;
		case RCMessageFlavorJoin:
			[string setFont:[UIFont fontWithName:@"Helvetica" size:11]];
			[string setTextAlignment:CTTextAlignmentFromUITextAlignment(UITextAlignmentCenter) lineBreakMode:CTLineBreakModeFromUILineBreakMode(UILineBreakModeWordWrap)];
			break;
		case RCMessageFlavorPart:
			[string setFont:[UIFont fontWithName:@"Helvetica" size:11]];
			[string setTextAlignment:CTTextAlignmentFromUITextAlignment(UITextAlignmentCenter) lineBreakMode:CTLineBreakModeFromUILineBreakMode(UILineBreakModeWordWrap)];
			break;
		case RCMessageFlavorNormalE:
			//	[attr setTextBold:YES range:NSMakeRange(0, _message.length)];
			break;
	}	
	return self;
}

- (void)dealloc {
	[string release];
	[super dealloc];
}
@end
