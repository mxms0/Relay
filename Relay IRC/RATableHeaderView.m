//
//  RATableHeaderView.m
//  Relay IRC
//
//  Created by Max Shavrick on 7/22/15.
//  Copyright (c) 2015 Mxms. All rights reserved.
//

#import "RATableHeaderView.h"

@implementation RATableHeaderView

- (instancetype)init {
	if ((self = [super init])) {
		UILabel *textLabel = [[UILabel alloc] init];
		self.textLabel = textLabel;
		UILabel *detailLabel = [[UILabel alloc] init];
		self.detailTextLabel = detailLabel;
		[detailLabel release];
		[textLabel release];
		[self addSubview:self.textLabel];
		[self addSubview:self.detailTextLabel];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	self.textLabel.frame = CGRectMake(5, 5, self.frame.size.width - 10, 25);
	self.detailTextLabel.frame = CGRectMake(5, 32, self.frame.size.width - 10, 15);
}

- (void)dealloc {
	self.textLabel = nil;
	self.detailTextLabel = nil;
	[super dealloc];
}

@end
