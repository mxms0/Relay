//
//  RCHoverWebBrowser.m
//  Relay
//
//  Created by Max Shavrick on 7/29/13.
//

#import "RCHoverWebBrowser.h"

@implementation RCHoverWebBrowser

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		webView = [[UIWebView alloc] init];
		[self addSubview:webView];
		[webView release];
	}
	return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	[webView setFrame:CGRectMake(0, navigationBar.frame.size.height, frame.size.width, frame.size.height - navigationBar.frame.size.height)];
}

- (void)scrollToTop {
	[[webView scrollView] setContentOffset:CGPointMake(0, 0) animated:YES];
}

@end
