//
//  RCChatPanel.m
//  Relay
//
//  Created by Max Shavrick on 2/17/12.
//

#import "RCChatPanel.h"
#import "RCChannel.h"
#import "RCChatController.h"

@implementation RCChatPanel
@synthesize messages, channel;

static NSString *template = nil;

- (id)initWithChannel:(RCChannel *)chan {
	if ((self = [super init])) {
		[self setChannel:chan];
		[[self scrollView] setScrollsToTop:YES];
		[self setBackgroundColor:[UIColor clearColor]];
		self.opaque = NO;
		[self setHidden:YES];
		if (!template) {
			template = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"chatview" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
			// must . fix. for. SD. displaayss
			template = [[NSString stringWithFormat:template,[[NSBundle mainBundle] pathForResource:@"0_jaggs@2x" ofType:@"png"]] retain];
		}
		preloadPool = [[NSMutableArray alloc] init];
		self.dataDetectorTypes = (UIDataDetectorTypeLink | UIDataDetectorTypePhoneNumber);
		self.delegate = (id<UIWebViewDelegate>)self;
		[[self scrollView] setShowsHorizontalScrollIndicator:NO];
		[[self scrollView] setShowsHorizontalScrollIndicator:NO];
		[[self scrollView] setShowsVerticalScrollIndicator:NO];//just incase
        [[self scrollView] setDecelerationRate:UIScrollViewDecelerationRateNormal];
        [[self scrollView] setScrollsToTop:YES];
		[self loadHTMLString:template baseURL:[NSURL URLWithString:@""]];
	}
	return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([textField.text isEqualToString:@""] || textField.text == nil) return NO;
	NSString *appstore_txt = [textField.text retain];
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
	dispatch_async(queue, ^ {
		dispatch_sync(dispatch_get_main_queue(), ^ {
			[channel userWouldLikeToPartakeInThisConversation:appstore_txt];
			[appstore_txt release];			
		});
	});
	[textField setText:@""];
	[[RCNickSuggestionView sharedInstance] dismiss];
	return NO;
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
		RCChannel *ch = [[(RCChannel *)[self channel] delegate] addChannel:escaped join:YES];
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
	if (self.hidden) {
		self.hidden = NO;
	}
	@synchronized(self) {
		if (preloadPool) {
			NSLog(@"GOING SWIMMMING");
			[preloadPool addObject:ms];
			return;
		}
	}
	[ms retain];
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		NSString *name = nil;
		if (ms.needsCenter) {
			name = [self stringByEvaluatingJavaScriptFromString:@"createMessage(true);"];
		}
		else {
			name = [self stringByEvaluatingJavaScriptFromString:@"createMessage(false);"];
		}
		NSString *res = [self stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"postMessage('%@', '%@', %@)", name, ms.string, ((self.scrollView.tracking || self.scrollView.dragging )? @"false" : @"true")]];
		if ([res isEqualToString:@"nop"]) {
			//hi
		}
		[ms release];
	});
}

- (void)scrollToBottom {
    [self stringByEvaluatingJavaScriptFromString:@"scrollToBottom();"];
}

- (void)layoutSubviews {
	for (UIView *subv in [[[self subviews] objectAtIndex:0] subviews]) {
		if ([subv isKindOfClass:[UIImageView class]])
			[subv setHidden:YES];
	}
}

- (void)postMessage:(NSString *)_message withType:(RCMessageType)type highlight:(BOOL)high {
	[self postMessage:_message withType:type highlight:high isMine:NO];
}

- (void)postMessage:(NSString *)_message withType:(RCMessageType)type highlight:(BOOL)high isMine:(BOOL)mine {
    [_message retain];
	RCMessageFormatter *message = [[RCMessageFormatter alloc] initWithMessage:_message isOld:NO isMine:mine isHighlight:high type:type];
	dispatch_async(dispatch_get_main_queue(), ^ {
		[message format];
		[self layoutMessage:message];
		[self setNeedsDisplay];
		[message release];
		[_message release];
	});
}

- (void)setScrollingEnabled:(BOOL)en {
	[[self scrollView] setScrollEnabled:en];
}

- (void)dealloc {
	[super dealloc];
}

@end
