//
//  RCBasicViewController.m
//  Relay
//
//  Created by Max Shavrick on 7/1/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCBasicViewController.h"

@implementation UIView (FindAndResignFirstResponder)
- (BOOL)findAndResignFirstResponder {
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;
    }
    for (UIView *subView in self.subviews) {
        if ([subView findAndResignFirstResponder])
            return YES;
    }
    return NO;
}
@end

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
	UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 32)];
	[backButton setTitle:@"  Back" forState:UIControlStateNormal];
	[[backButton titleLabel] setFrame:CGRectMake(0, 10, 40, 30)];
	[[backButton titleLabel] setTextAlignment:UITextAlignmentCenter];
	[[backButton titleLabel] setFont:[UIFont boldSystemFontOfSize:11]];
	[backButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[backButton setTitleColor:UIColorFromRGB(0x454646) forState:UIControlStateNormal];
	[[backButton titleLabel] setShadowOffset:CGSizeMake(0, 1)];
	[backButton setBackgroundImage:[[UIImage imageNamed:@"0_navback"] stretchableImageWithLeftCapWidth:15 topCapHeight:0] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[[UIImage imageNamed:@"0_navback_pressed"] stretchableImageWithLeftCapWidth:15 topCapHeight:0] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
	self.navigationItem.leftBarButtonItem = backItem;
	[backItem release];
	[backButton release];
}

- (void)backButtonTapped:(id)of {
	[self.navigationController popViewControllerAnimated:YES];
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	float y = 44;
	float width = 320;
	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		y = 32; width = 480;
	}
	for (UIView *subvc in [self.navigationController.navigationBar subviews]) {
		NSLog(@"hi %@",subvc);
		if ([subvc isKindOfClass:[UIImageView class]])
			subvc.frame = CGRectMake(0, y, width, 10);
	}
	r_shadow.frame = CGRectMake(0, y, width, 10);
}


@end
