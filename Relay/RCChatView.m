//
//  RCScrollView.m
//  Relay
//
//  Created by Max Shavrick on 7/27/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChatView.h"
#import <CoreText/CoreText.h>
#import "RCMessageFormatter.h"
#import "NSString+IRCStringSupport.h"
#import "RCChannel.h"
#import "RCNavigator.h"

static NSString* template = nil;

static NSString* str2col[] = {
	@"white", // white
	@"black", // black
	@"navy", // blue
	@"green", // green
	@"red", // red
	@"maroon", // brown
	@"purple", // purple
	@"orange", // orange
	@"yellow", // yellow
	@"lime", // lime
	@"teal", // teal
	@"lightcyan", // light cyan
	@"royalblue", // light blue
	@"fuchsia", // pink
	@"grey", // grey
	@"silver", // light grey
	nil
};

NSString *colorForIRCColor(char irccolor) {
    if (irccolor == -1) {
        return @"default-foreground";
    }
    if (irccolor == -2) {
        return @"default-background";
    }
    if (irccolor >= 16) {
        return @"invalid";
    }
    return str2col[irccolor];
}

@implementation RCChatView
@synthesize chatpanel;
- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
        if (!template) {
            template = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chatview" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil] retain];
        }
        self.opaque = NO;
        self.dataDetectorTypes = UIDataDetectorTypeNone;
        self.backgroundColor = [UIColor clearColor];
        self.delegate = (id<UIWebViewDelegate>) self;
        preloadPool = [NSMutableArray new];
        [self loadHTMLString:template baseURL:[NSURL URLWithString:@""]];
		[[self scrollView] setShowsHorizontalScrollIndicator:NO];
		[[self scrollView] setShowsVerticalScrollIndicator:NO];//just incase
        [[self scrollView] setDecelerationRate:UIScrollViewDecelerationRateNormal];
        [[self scrollView] setScrollsToTop:YES];
	}
	return self;
}

- (BOOL)webView:(UIWebView *)webView2 shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *requestString = [[request URL] absoluteString];
    if ([requestString hasPrefix:@"link:"]) {
        NSLog(@"should open link: %@", [requestString substringFromIndex:[@"link:" length]]);
        NSString *escaped = [[requestString substringFromIndex:[@"link:" length]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:escaped]];  
        return NO;
    }
	else {
        if ([requestString hasPrefix:@"channel:"]) {
			NSLog(@"should join: %@", [requestString substringFromIndex:[@"channel:" length]]);
			NSString *escaped = [[requestString substringFromIndex:[@"channel:" length]] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			RCChannel *ch = [[(RCChannel*)[[self chatpanel] channel] delegate] addChannel:escaped join:YES];
			[[RCNavigator sharedNavigator] channelSelected:[ch bubble]];
			[[RCNavigator sharedNavigator] scrollToBubble:[ch bubble]];
			return NO;
		}
	}
    return NO;
}

- (void)dealloc {
    NSLog(@"kthxbai :[");
    [super dealloc];
}
#define RENDER_WITH_OPTS \
        if (!([ms string] && ms)) {\
            return;\
        }\
        cstr = [NSString stringWithFormat:@"addToMessage('%@','%@','%@','%@','%@','%@','%@', 'YES');", name, isBold ? @"YES" : @"NO", isUnderline ? @"YES" : @"NO", isItalic ? @"YES" : @"NO", bgcolor, fgcolor, [istring substringWithRange:NSMakeRange(lpos, cpos-lpos)]]; \
        if (![[self stringByEvaluatingJavaScriptFromString:cstr] isEqualToString:@"SUCCESS"]) { \
            NSLog(@"Could not exec: %@", cstr); \
        } else if ([ms  shouldColor]) { \
            [[(RCChannel*)[[self chatpanel] channel] bubble] setMentioned:[ms  highlight]];\
            [[(RCChannel*)[[self chatpanel] channel] bubble] setHasNewMessage:![ms  highlight]];\
        }\
        lpos = cpos;    

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    @synchronized(self) {
		NSMutableArray *pre_pool = preloadPool;
		preloadPool = nil;
		for (RCMessageFormatter* ms in pre_pool) {
			[self layoutMessage:ms];
		}
		[pre_pool release];
	}
    NSLog(@"DOM INIT");
}
- (void)layoutMessage:(RCMessageFormatter *)ms {
_out_:
	@synchronized(self) {
		if (preloadPool) {
			NSLog(@"DOM not ready! Queueing.");
			[preloadPool addObject:ms];
			return;
		}
	}
	dispatch_async(dispatch_get_main_queue(), ^(void){
		NSString *isReady = [self stringByEvaluatingJavaScriptFromString:@"isReady();"];
        if (![isReady isEqualToString:@"YES"]) {
            
        }
        NSString *name = [self stringByEvaluatingJavaScriptFromString:@"createMessage();"];
		if ([[ms string] hasSuffix:@"\n"]) {
			[ms setString:[[ms string] substringWithRange:NSMakeRange(0, [[ms string] length]-1)]];
		}
		[self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"setFlags('%@','%@');", name, [[ms string] substringToIndex:[[ms string] rangeOfString:@"-"].location]]];
		NSLog(@"Wat. %@", [[ms string] substringToIndex:[[ms string] rangeOfString:@"-"].location]);
		NSString* istring = [[[[[[ms string] substringFromIndex:[[ms string] rangeOfString:@"-"].location+1] stringByEncodingHTMLEntities:YES] stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"] stringByLinkifyingURLs] stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
		unsigned int cpos = 0;
		BOOL isBold = NO;
		BOOL isItalic = NO;
		BOOL isUnderline = NO;
		NSString *fgcolor = colorForIRCColor(-1);
		NSString *bgcolor = colorForIRCColor(-2);
		unsigned int lpos = 0;
		NSString *cstr;
		NSLog(@"%@", istring);
		while (cpos - [istring length]) {
			switch ([istring characterAtIndex:cpos]) {
				case RCIRCAttributeBold:
					RENDER_WITH_OPTS;
					cpos++;
					isBold = !isBold;
					lpos = cpos;
					break;
				case RCIRCAttributeItalic:;;
					RENDER_WITH_OPTS;
					cpos++;
					isItalic = !isItalic;
					lpos = cpos;
					break;
				case RCIRCAttributeUnderline:;;
					RENDER_WITH_OPTS;
					cpos++;
					isUnderline = !isUnderline;
					lpos = cpos;
					break;
				case RCIRCAttributeReset:;;
					RENDER_WITH_OPTS;
					cpos++;
					fgcolor = colorForIRCColor(-1);
					bgcolor = colorForIRCColor(-2);
					isBold = NO;
					isItalic = NO;
					isUnderline = NO;
					lpos = cpos;
					break;
				case RCIRCAttributeColor:;;
					RENDER_WITH_OPTS;
					cpos++;
					int number1 = -1;
					int number2 = -2;
					BOOL itc = YES;
					if (readNumber(&number1, &itc, &cpos, istring) && itc) {
						NSLog(@"comma!");
						itc = NO;
						readNumber(&number2, &itc, &cpos, istring);
					}
					NSLog(@"Using %d and %d (%d,%d) [%@]", number1, number2, cpos, lpos, [istring substringFromIndex:cpos]);
                    // BOOL readNumber(int* num, BOOL* isThereComma, int* size_of_num, char* data, int size);
					fgcolor = colorForIRCColor(number1);
					bgcolor = colorForIRCColor(number2);
					lpos = cpos;
					break;
				default:
					cpos++;
					continue;
					break;
			}
			continue;
		}
	skcolor:
		RENDER_WITH_OPTS;
        //NSString* cstr = [NSString stringWithFormat:@"addToMessage('%@','NO','NO','NO','white','black','%@', 'YES');", name, ];
	});
}

- (void)scrollToBottom {
    [self stringByEvaluatingJavaScriptFromString:@"scrollToBottom();"];
}

@end
