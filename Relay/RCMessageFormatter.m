//
//  RCMessage.m
//  Relay
//
//  Created by Max Shavrick on 2/20/12.
//

#import "RCMessageFormatter.h"
#import "NSString+IRCStringSupport.h"

@implementation RCMessageFormatter
@synthesize string, highlight, shouldColor, needsCenter;

- (id)initWithMessage:(NSString *)_message isOld:(BOOL)old isMine:(BOOL)m isHighlight:(BOOL)hh type:(RCMessageType)_flavor {
    if ((self = [super init])) {
		self.string = _message;
        self.highlight = hh;
		self.shouldColor = m;
		self.needsCenter = (_flavor == RCMessageTypeTopic);
	}
	return self;
}

- (void)format {
	[self setString:[[[[string stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"] stringByReplacingOccurrencesOfString:@"\n" withString:@""] stringByEncodingHTMLEntities:YES] stringWithNewLinesAsBRs]];
	int cpos = 0;
	BOOL isBold = NO;
	BOOL isItalic = NO;
	BOOL isUnderline = NO;
	BOOL didColor = NO;
	NSString *fgcolor = colorForIRCColor(-1);
	NSString *bgcolor = colorForIRCColor(-2);
	int nickcolor = 0;
	int nDepth = 0;
	int len = [string length];
	NSMutableString *final = [[NSMutableString alloc] init];
	if (self.highlight)
		[final appendString:@"<font color=\"#5b2e2e\">"];
	while (cpos < len) {
		switch ([string characterAtIndex:cpos]) {
			case RCIRCAttributeBold:
				cpos++;
				isBold = !isBold;
				if (isBold) {
					[final appendString:@"<b>"];
				}
				else {
					[final appendString:@"</b>"];
				}
				break;
			case RCIRCAttributeItalic:
				cpos++;
				isItalic = !isItalic;
				if (isItalic) {
					[final appendString:@"<i>"];
				}
				else {
					[final appendString:@"</i>"];
				}
				break;
			case RCIRCAttributeUnderline:
				cpos++;
				isUnderline = !isUnderline;
				if (isUnderline) {
					[final appendFormat:@"<u>"];
				}
				else {
					[final appendFormat:@"</u>"];
				}
				break;
			case RCIRCAttributeReset:
				cpos++;
				break;
			case RCIRCAttributeColor: {
				int num1 = -1;
				int num2 = -2;
				BOOL itc = YES;
				cpos++;
				if (readNumber(&num1, &itc, (unsigned int *)&cpos, string) && itc) {
					itc = NO;
					readNumber(&num2, &itc, (unsigned int *)&cpos, string);
				}
				fgcolor = colorForIRCColor(num1);
				bgcolor = colorForIRCColor(num2);
				if (didColor) {
					[final appendString:@"</font>"];
					didColor = NO;
				}
				if (num1 == -1 && num2 == -2) {
					continue;
				}
				[final appendFormat:@"<font color=\"%@\" style=\"background:%@\">", fgcolor, bgcolor];
				didColor = YES;
				break;
			}
			case RCIRCAttributeInternalNickname:

				cpos++;
				nDepth++;
				if (nDepth) {
					if ([string length] >= (cpos + 2) && nDepth == 1) {
						nickcolor = [[string substringWithRange:NSMakeRange(cpos, 2)] intValue];
					}
				}
				[final appendFormat:@"%@<span class=\"color%d\">", (!isBold ? @"<b>" : @""), nickcolor];
				cpos += 2;
				break;
			case RCIRCAttributeInternalNicknameEnd:
				cpos++;
				[final appendFormat:@"</span>%@", (!isBold ? @"</b>" : @"")];
				[final appendString:@"</span>"];
				if (nDepth)
					nDepth--;
				break;
			default:
				[final appendFormat:@"%C", [string characterAtIndex:cpos]];
				cpos++;
				continue;
				break;
		}
	}
	if (self.highlight)
		[final appendString:@"</font>"];
	[self setString:(NSString *)final];
	[final release];
}

- (void)dealloc {
	// [self setString:nil];
	[super dealloc];
}
@end
