//
//  RCPopoverWindow.m
//  Relay
//
//  Created by Max Shavrick on 6/18/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCPopoverWindow.h"
#import "RCNetworkManager.h"

@implementation RCPopoverWindow

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		networkTable = [[UITableView alloc] initWithFrame:CGRectMake(40, 65, 240, 205)];
		networkTable.delegate = self;
		networkTable.backgroundColor = [UIColor clearColor];
		networkTable.separatorStyle = UITableViewCellSeparatorStyleNone;
		networkTable.dataSource = self;
		_pImg = [[UIImageView alloc] initWithFrame:CGRectMake(26, 50, 268, 240)];
		[_pImg setImage:[UIImage imageNamed:@"0_popover"]];
		[self addSubview:_pImg];
		[_pImg release];
		[self addSubview:networkTable];
		[networkTable release];
		self.windowLevel = 7777;
		self.hidden = YES;
		self.opaque = NO;
		self.alpha = 0;
    }
    return self;
}

- (void)animateIn {
	self.hidden = NO;
	self.alpha = 0;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	self.alpha = 1;
	[UIView commitAnimations];	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *ident = @"0_networkcell";
	RCNetworkCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
	if (!cell) {
		cell = [[RCNetworkCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ident];
	}
	cell.textLabel.text = [[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.row] sDescription];
	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[[RCNetworkManager sharedNetworkManager] networks] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

@end
