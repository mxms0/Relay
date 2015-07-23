//
//  RATableView.m
//  Relay IRC
//
//  Created by Max Shavrick on 7/22/15.
//  Copyright (c) 2015 Mxms. All rights reserved.
//

#import "RATableView.h"

@implementation RATableView

- (id)init {
	if ((self = [super initWithFrame:CGRectZero style:UITableViewStylePlain])) {
		self.opaque = NO;
		[self setBackgroundColor:[UIColor clearColor]];
		//		[[self scrollView] setShowsVerticalScrollIndicator:YES]; // Aehmlo wants it. We'll see.
		UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
		v.backgroundColor = [UIColor clearColor];
		[self setTableFooterView:v];
		[v release];
		[self setSeparatorInset:UIEdgeInsetsZero];
	}
	return self;
}

@end
