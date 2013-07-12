//
//  RCSettingsViewController.m
//  Relay
//
//  Created by Max Shavrick on 7/12/13.
//

#import "RCSettingsViewController.h"

@implementation RCSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style {
	if ((self = [super initWithStyle:UITableViewStylePlain])) {

	}
	return self;
}

- (void)loadView {
	[super loadView];
	RCBarButtonItem *ct = [[RCBarButtonItem alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
	[ct addTarget:self action:@selector(cancelChanges) forControlEvents:UIControlEventTouchUpInside];
	[ct setImage:[UIImage imageNamed:@"0_cnclr"] forState:UIControlStateNormal];
	UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithCustomView:ct];
	[self.navigationItem setLeftBarButtonItem:cancel];
	[cancel release];
	[ct release];
	
	RCBarButtonItem *bt = [[RCBarButtonItem alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
	[bt addTarget:self action:@selector(saveChanges) forControlEvents:UIControlEventTouchUpInside];
	[bt setImage:[UIImage imageNamed:@"0_checkr"] forState:UIControlStateNormal];
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithCustomView:bt];
	[self.navigationItem setRightBarButtonItem:done];
	[done release];
	[bt release];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 240, 20)];
	label.text = [self tableView:tableView titleForHeaderInSection:section];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.shadowColor = [UIColor blackColor];
	label.shadowOffset = CGSizeMake(0, 1);
	label.font = [UIFont boldSystemFontOfSize:14];
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"0_%d_%d", indexPath.row, indexPath.section];
	RCBasicTextInputCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (!cell) {
		cell = [[[RCBasicTextInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
	}
	
	return cell;
}

- (NSString *)titleText {
	return @"Settings";
}

- (void)cancelChanges {
	[self dismiss];
}

- (void)saveChanges {
	[self dismiss];
}

- (void)dismiss {
	[self dismissModalViewControllerAnimated:YES];
}

@end
