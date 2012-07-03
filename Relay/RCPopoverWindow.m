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

static id _instance = nil;
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
		applicationDelegate = [UIApp delegate];
    }
    _instance = self;
    return _instance;
}

- (void)setBasicFramesForElements {
	[_pImg setTransform:CGAffineTransformMakeRotation(0)];
	[_pImg setFrame:CGRectMake(26, 50, 268, 240)];
	[networkTable setFrame:CGRectMake(40, 65, 240, 205)];
	[networkTable setTransform:CGAffineTransformMakeRotation(0)];
}

+ (id)sharedPopover {
    if (!_instance) [[self alloc] initWithFrame:CGRectMake(0,0,320,480)];
    return _instance;
}

- (void)reloadData {
    [networkTable reloadData];
}

- (void)animateIn {
	self.hidden = NO;
	self.alpha = 0;
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.25];
	self.alpha = 1;
	[UIView commitAnimations];	
}

- (void)animateOut {
	[UIView animateWithDuration:0.25 animations:^ {
		self.alpha = 0;	
	} completion:^(BOOL fin) {
		self.hidden = YES;
	}];
}

- (void)correctAndRotateToInterfaceOrientation:(UIInterfaceOrientation)oi {
	[self setBasicFramesForElements];
	BOOL animate = NO;
	// NEED THIS BOOLEAN INCASE THE VIEW APPEARS WHILE THIS IS OCCURING 
	if (!self.hidden) {
		animate = YES;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.25];
	}
	networkTable.transform = CGAffineTransformMakeRotation(0);
	if (UIInterfaceOrientationIsLandscape(oi)) {
		if (self.frame.origin.y == 20) {
			self.frame = CGRectMake(0,0,320,480);
		}
		networkTable.transform = CGAffineTransformMakeRotation(_deg(90));
		networkTable.frame = CGRectMake(55, 10, networkTable.frame.size.width, networkTable.frame.size.height);
		_pImg.frame = CGRectMake(20, 10, _pImg.frame.size.width, _pImg.frame.size.height);
		// i like 20.
	}
	else {
		[self setBasicFramesForElements];
		// necessary. don't. even. ask.
	}
	_pImg.transform = networkTable.transform;
	if (animate) {
		[UIView commitAnimations];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *ident = @"0_networkcell";
	RCNetworkCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
	if (!cell) {
		cell = [[RCNetworkCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident];
	}
	cell.textLabel.text = [[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.row] sDescription];
	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.detailTextLabel.text = [NSString stringWithFormat:@"(%@)", [[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.row] server]];	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[RCNavigator sharedNavigator] selectNetwork:[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.row]];
	[self animateOut];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[[RCNetworkManager sharedNetworkManager] networks] count];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self animateOut];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

@end
