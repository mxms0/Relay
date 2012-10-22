//
//  RCPopoverWindow.m
//  Relay
//
//  Created by Max Shavrick on 6/18/12.
//

#import "RCPopoverWindow.h"
#import "RCNetworkManager.h"

@implementation RCPopoverWindow
@synthesize shouldRePresentKeyboardOnDismiss;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		networkTable = [[UITableView alloc] initWithFrame:CGRectMake(33, 43, 253, 267)];
		networkTable.layer.cornerRadius = 14;
		networkTable.delegate = self;
		networkTable.backgroundColor = [UIColor clearColor];
		networkTable.separatorStyle = UITableViewCellSeparatorStyleNone;
		networkTable.dataSource = self;
		[networkTable setShowsVerticalScrollIndicator:NO];
		_pImg = [[UIImageView alloc] initWithFrame:CGRectMake(26, 28, 268, 300)];
		[_pImg setImage:[UIImage imageNamed:@"0_popover"]];
		[self addSubview:_pImg];
		[_pImg release];
		[self addSubview:networkTable];
        [networkTable setScrollsToTop:NO];
		[networkTable release];
		self.hidden = YES;
		self.opaque = NO;
		self.alpha = 0;
		self.shouldRePresentKeyboardOnDismiss = NO;
		applicationDelegate = [UIApp delegate];
    }
    return self;
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
		[self removeFromSuperview];
		self.hidden = YES;
		if (shouldRePresentKeyboardOnDismiss)
			[[[RCNavigator sharedNavigator] currentPanel] becomeFirstResponder];
		self.shouldRePresentKeyboardOnDismiss = NO;
	}];
}

- (void)checkSelection:(RCNetwork *)net {
	NSArray *s = [networkTable indexPathsForSelectedRows];
	for (NSIndexPath *pp in s) {
		[networkTable deselectRowAtIndexPath:pp animated:NO];
	}
#warning FIX THIS !!11
}

- (void)correctAndRotateToInterfaceOrientation:(UIInterfaceOrientation)oi {
	BOOL animate = NO;
	if (!self.hidden) {
		animate = YES;
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.25];
	}
	if (UIInterfaceOrientationIsLandscape(oi)) {
		[_pImg setImage:[UIImage imageNamed:@"0_popover_l"]];
		_pImg.frame = CGRectMake(-1, 29, 242, 234);
		networkTable.frame = CGRectMake(2, 38, 253, 300);
	}
	/* XXXX: FIX THESE NUMBERS WHEN SURENIX GETS TO IT */
	else {
		[_pImg setImage:[UIImage imageNamed:@"0_popover"]];
		[networkTable setFrame:CGRectMake(33, 43, 253, 300)];
		[_pImg setFrame:CGRectMake(26, 28, 268, 300)];
	}
	if (animate) {
		[UIView commitAnimations];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 40;
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 1.2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	RCNetworkHeaderButton *btn = [[RCNetworkHeaderButton alloc] initWithFrame:CGRectMake(0, 0, 300, 45)];
	[btn setSection:section];
	[btn setNetwork:[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:section]];

	[btn addTarget:self action:@selector(headerTouched:) forControlEvents:UIControlEventTouchUpInside];
	return [btn autorelease];
}

- (void)headerTouched:(RCNetworkHeaderButton *)headr {
	NSArray *nets = [[RCNetworkManager sharedNetworkManager] networks];
	for (RCNetwork *net in nets) {
		[net set_selected:NO];
	}
	[[headr net] set_selected:YES];
	[networkTable reloadData];
	[[RCNavigator sharedNavigator] selectNetwork:[headr net]];
	[self animateOut];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *ident = @"0_networkcell";
	RCNetworkCell *cell = [tableView dequeueReusableCellWithIdentifier:ident];
	if (!cell) {
		cell = [[[RCNetworkCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ident] autorelease];
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[RCNavigator sharedNavigator] selectNetwork:[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:indexPath.row]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
	return [[[[[RCNetworkManager sharedNetworkManager] networks] objectAtIndex:section] _channels] count];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self animateOut];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[[RCNetworkManager sharedNetworkManager] networks] count];
}

@end
