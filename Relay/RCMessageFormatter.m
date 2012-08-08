//
//  RCMessage.m
//  Relay
//
//  Created by Max Shavrick on 2/20/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCMessageFormatter.h"

@implementation RCMessageFormatter

- (id)initWithMessage:(NSString *)_message isOld:(BOOL)old isMine:(BOOL)m isHighlight:(BOOL)hh type:(RCMessageType)_flavor {
	if (![_message hasSuffix:@"\n"])
		_message = [_message stringByAppendingString:@"\n"];
	if ((self = [super init])) {
		string = [[NSMutableAttributedString alloc] initWithString:_message];
	}
	[string setFont:[UIFont fontWithName:@"Helvetica" size:12]];
	//	UIColor *normalColor = UIColorFromRGB(0x3F4040);
	UIColor *normalColor = UIColorFromRGB(0xF2F2F2);
	BOOL centerAlign = NO;
	if (old)
		normalColor = UIColorFromRGB(0xB6BCCC);
	[string setTextColor:normalColor];
	switch (_flavor) {
		case RCMessageTypeAction:
			[string setTextIsUnderlined:NO range:NSMakeRange(0, _message.length)];
			[string setTextBold:YES range:NSMakeRange(0, _message.length)];
			//		[string setTextAlignment:CTTextAlignmentFromUITextAlignment(UITextAlignmentCenter) lineBreakMode:CTLineBreakModeFromUILineBreakMode(UILineBreakModeClip)];
			centerAlign = YES;
			break;
		case RCMessageTypeNormal: {
			if (hh) {
				if (!old)
					[string setTextColor:UIColorFromRGB(0xDA4156)];
			else [string setTextColor:UIColorFromRGB(0xB6BCCC)];
			}
			NSRange p = [_message rangeOfString:@"]"];
			NSRange r = [_message rangeOfString:@":" options:0 range:NSMakeRange(p.location, _message.length-p.location)];
			[string setTextBold:YES range:NSMakeRange(0, r.location)];
			break;
		}
		case RCMessageTypeNotice:
			[string setTextBold:YES range:NSMakeRange(0, _message.length)];
			// do something.
			break;
		case RCMessageTypeTopic:
			[string setTextAlignment:CTTextAlignmentFromUITextAlignment(UITextAlignmentCenter) lineBreakMode:CTLineBreakModeFromUILineBreakMode(UILineBreakModeWordWrap)];
			centerAlign = YES;
			break;
		case RCMessageTypeJoin:
			[string setFont:[UIFont fontWithName:@"Helvetica" size:11]];
			[string setTextAlignment:CTTextAlignmentFromUITextAlignment(UITextAlignmentCenter) lineBreakMode:CTLineBreakModeFromUILineBreakMode(UILineBreakModeWordWrap)];
			centerAlign = YES;
			break;
		case RCMessageTypePart:
			[string setFont:[UIFont fontWithName:@"Helvetica" size:11]];
			[string setTextAlignment:CTTextAlignmentFromUITextAlignment(UITextAlignmentCenter) lineBreakMode:CTLineBreakModeFromUILineBreakMode(UILineBreakModeWordWrap)];
			centerAlign = YES;
			break;
		case RCMessageTypeNormalE:
			//	[attr setTextBold:YES range:NSMakeRange(0, _message.length)];
			break;
	}
	return self;
}

- (NSMutableAttributedString *)string {
	return string;
}

- (void)dealloc {
	[string release];
	[super dealloc];
}
@end
