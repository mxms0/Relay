//
//  RCBasicViewController.m
//  Relay
//
//  Created by Max Shavrick on 7/1/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCBasicViewController.h"

@implementation RCBasicViewController

- (id)initWithStyle:(UITableViewStyle)style {
	if ((self = [super initWithStyle:style])) {
		titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 40)];
		titleView.backgroundColor = [UIColor clearColor];
		titleView.textAlignment = UITextAlignmentCenter;
		titleView.font = [UIFont boldSystemFontOfSize:22];
		titleView.shadowColor = [UIColor whiteColor];
		titleView.textColor = UIColorFromRGB(0x424343);
		titleView.shadowOffset = CGSizeMake(0, 1);
		self.navigationItem.titleView = titleView;
		[titleView release];
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0) return 35.0;
	return 25.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 240, 20)];
	label.text = [self tableView:tableView titleForHeaderInSection:section];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.shadowColor = [UIColor blackColor];
	label.shadowOffset = CGSizeMake(0, 1);
	label.font = [UIFont boldSystemFontOfSize:14];
	return [label autorelease];
}

- (NSString *)titleText {
	return @"HAIRLYLONGSTRINGHERE HAI";
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"0_addnav"] forBarMetrics:UIBarMetricsDefault];
	UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"0_bg"]];
	[bg setFrame:self.view.frame];
	self.tableView.backgroundView = bg;
	[bg release];
	titleView.text = [self titleText];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
