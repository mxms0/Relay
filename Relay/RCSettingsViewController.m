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
		UIView *pure = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 100)];
		[self.tableView setTableHeaderView:pure];
		[pure release];
		[self.tableView setContentInset:UIEdgeInsetsMake(-100, 0, 0, 0)];
		sectionalArrays = @[
						@[@"  Aesthetics", @"Autocorrection", @"Autocapitalization", @"24 Hour Time", @"Use Seconds"],
						@[@"  Defaults", @"Nick Name", @"User Name", @"Real Name", @"Quit Message"],
		];
		[sectionalArrays retain];
		keyValues = [NSDictionary dictionaryWithObjectsAndKeys:AUTOCORRECTION_KEY, @"autocorrection", AUTOCAPITALIZE_KEY, @"autocapitalization", TWENTYFOURHOURTIME_KEY, @"24 hour time", TIMESECONDS_KEY, @"use seconds", nil];
		[keyValues retain];
		managedPreferences = [[[RCNetworkManager sharedNetworkManager] settingsDictionary] mutableCopy];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [sectionalArrays count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 25;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [sectionalArrays[section] count] - 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [sectionalArrays[section] objectAtIndex:0];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"0_%d_%d", indexPath.row, indexPath.section];
	RCSettingsTableViewCell *cell = (RCSettingsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	NSString *text = [sectionalArrays[indexPath.section] objectAtIndex:indexPath.row + 1];
	if (!cell) {
		cell = [[[RCSettingsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
		switch (indexPath.section) {
			case 0: {
				UISwitch *aSwitch = [[UISwitch alloc] init];
				[aSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
				aSwitch.on = (BOOL)[[managedPreferences objectForKey:[keyValues objectForKey:[text lowercaseString]]] boolValue];
				[cell setAccessoryView:aSwitch];
				[aSwitch release];
				break;
			}
			default:
				break;
		}
	}
	cell.textLabel.text = text;
	return cell;
}

- (void)switchToggled:(UISwitch *)aSwitch {
	madeChanges = YES;
	RCSettingsTableViewCell *cell = (RCSettingsTableViewCell *)[aSwitch superview];
	NSString *key = [keyValues objectForKey:[cell.textLabel.text lowercaseString]];
	[managedPreferences setObject:(aSwitch.on ? (id)kCFBooleanTrue : (id)kCFBooleanFalse) forKey:key];
}

- (NSString *)titleText {
	return @"Settings";
}

- (void)cancelChanges {
	[self dismiss];
}

- (void)saveChanges {
	if (madeChanges) {
		[[RCNetworkManager sharedNetworkManager] saveSettingsDictionary:managedPreferences dispatchChanges:YES];
	}
	[self dismiss];
}

- (void)dismiss {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc {
	[managedPreferences release];
	[keyValues release];
	[sectionalArrays release];
	[super dealloc];
}

@end
