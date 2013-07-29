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
		navigationBar.title = @"Loading";
		navigationBar.subtitle = @"...";
		[navigationBar setNeedsDisplay];
		webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, navigationBar.frame.size.height, frame.size.width, frame.size.height - navigationBar.frame.size.height)];
		[self addSubview:webView];
		[webView release];
	}
	return self;
}

- (void)scrollToTop {
	[[webView scrollView] setContentOffset:CGPointMake(0, 0) animated:YES];
}

@end
