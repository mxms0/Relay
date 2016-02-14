//
//  RANetworkSelectionView.m
//  Relay IRC
//
//  Created by Max Shavrick on 7/22/15.
//  Copyright (c) 2015 Mxms. All rights reserved.
//

#import "RANetworkSelectionView.h"
#import "RATableView.h"
#import "RANetworkManager.h"

@implementation RANetworkSelectionView

- (instancetype)init {
	if ((self = [super init])) {
		networkListing = [[RATableView alloc] init];
		[self addSubview:networkListing];
		[networkListing setDelegate:self];
		[networkListing setDataSource:self];
	}
	return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
	[networkListing setFrame:self.bounds];
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[networkListing reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView {
	return [[[RANetworkManager sharedNetworkManager] networks] count];;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	RCNetwork *net = [[[RANetworkManager sharedNetworkManager] networks] objectAtIndex:section];
	return [[net channels] count];
}

- (UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cc"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cc"];
	}
	RCNetwork *net = [[[RANetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.section];
	NSOrderedSet *channels = [net channels];
	cell.textLabel.text = [[channels objectAtIndex:indexPath.row] channelName];
	return cell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
	RCChannel *channel = [[[[[RANetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.section] channels] objectAtIndex:indexPath.row];
	[self.delegate networkSelectionView:self userSelectedChannel:channel];
}

@end
