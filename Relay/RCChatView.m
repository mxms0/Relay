//
//  RCScrollView.m
//  Relay
//
//  Created by Max Shavrick on 7/27/12.
//

#import "RCChatView.h"
#import <CoreText/CoreText.h>
#import "RCMessageFormatter.h"
#import "NSString+IRCStringSupport.h"
#import "RCChannel.h"
#import "RCChatController.h"

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
            template = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chatview" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
			template = [[NSString stringWithFormat:template, [[NSBundle mainBundle] pathForResource:@"0_jaggs@2x" ofType:@"png"]] retain];
        }
        self.opaque = NO;
        self.dataDetectorTypes = (UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber);
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

- (void)layoutSubviews {
	for (UIView *subv in [[[self subviews] objectAtIndex:0] subviews]) {
		if ([subv isKindOfClass:[UIImageView class]])
			[subv setHidden:YES];
	}
}

- (BOOL)webView:(UIWebView *)webView2 shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSString *requestString = [[request URL] absoluteString];
	if ([requestString isEqualToString:@"file:///"])
		return YES;
    if ([requestString hasPrefix:@"link:"]) {
        NSLog(@"should open link: %@", [requestString substringFromIndex:[@"link:" length]]);
        NSString *escaped = [[requestString substringFromIndex:[@"link:" length]] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:escaped]];  
        return NO;
    }
	else if ([requestString hasPrefix:@"channel:"]) {
		NSLog(@"should join: %@", [requestString substringFromIndex:[@"channel:" length]]);
		NSString *escaped = [[requestString substringFromIndex:[@"channel:" length]] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		RCChannel *ch = [[(RCChannel *)[[self chatpanel] channel] delegate] addChannel:escaped join:YES];
		if (ch) {
			[[RCChatController sharedController] selectChannel:[ch channelName] fromNetwork:nil];
		}
		reloadNetworks();
		// select network here.
		return NO;
		
	}
	else {
		[[UIApplication sharedApplication] openURL:[request URL]];
	}
    return NO;
}

- (void)dealloc {
    NSLog(@"kthxbai :[");
    [super dealloc];
}  

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    @synchronized(self) {
		NSMutableArray *pre_pool = preloadPool;
		preloadPool = nil;
		for (RCMessageFormatter *ms in pre_pool) {
			[self layoutMessage:ms];
		}
		[pre_pool release];
	}
}

- (void)layoutMessage:(RCMessageFormatter *)ms {
	@synchronized(self) {
		if (preloadPool) {
			NSLog(@"GOING SWIMMMING");
			[preloadPool addObject:ms];
			return;
		}
	}
	[ms retain];
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		NSString *isReady = [self stringByEvaluatingJavaScriptFromString:@"isReady();"];
        if (![isReady isEqualToString:@"YES"]) {
            
        }
		NSString *name = nil;
		if (ms.needsCenter) {
			name = [self stringByEvaluatingJavaScriptFromString:@"createMessage(true);"];
		}
		else {
			name = [self stringByEvaluatingJavaScriptFromString:@"createMessage(false);"];			
		}
		NSString *res = [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"postMessage('%@', '%@', %@)", name, ms.string, (self.scrollView.tracking ? @"false" : @"true")]];
		[ms release];
	});
}

- (void)scrollToBottom {
    [self stringByEvaluatingJavaScriptFromString:@"scrollToBottom();"];
}

@end
