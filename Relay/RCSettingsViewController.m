//
//  RCSettingsViewController.m
//  Relay
//
//  Created by Max Shavrick on 7/12/13.
//

#import "RCSettingsViewController.h"
#import "RCAboutViewController.h"

@implementation RCSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style {
	if ((self = [super initWithStyle:UITableViewStylePlain])) {
		UIView *pure = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 100)];
		[self.tableView setTableHeaderView:pure];
		[pure release];
		[self.tableView setContentInset:UIEdgeInsetsMake(-100, 0, 0, 0)];
		sectionalArrays = @[
						@[@"Nickname", @"Real Name", @"User Name", @"Quit Message"],
						@[@"Night Mode", @"Seconds In Timestamps", @"24 Hour Time"],
						@[@"Autocorrect", @"Autocapitalize"],
                        @[@"Custom Commands"],
                        @[@"About Relay"]
		];
		[sectionalArrays retain];
		keyValues = [NSDictionary dictionaryWithObjectsAndKeys:AUTOCORRECTION_KEY, @"Autocorrect", AUTOCAPITALIZE_KEY, @"Autocapitalize", TWENTYFOURHOURTIME_KEY, @"24 Hour Time", TIMESECONDS_KEY, @"Seconds In Timestamps", THEME_NAME_KEY, @"Night Mode", nil];
		[keyValues retain];
		managedPreferences = [[[RCNetworkManager sharedNetworkManager] settingsDictionary] mutableCopy];
	}
	return self;
}

- (void)loadView {
	[super loadView];
	RCBarButtonItem *ct = [[RCBarButtonItem alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
	[ct addTarget:self action:@selector(cancelChanges) forControlEvents:UIControlEventTouchUpInside];
	[ct setImage:[UIImage imageNamed:@"icon_close_red"] forState:UIControlStateNormal];
	UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithCustomView:ct];
	[self.navigationItem setLeftBarButtonItem:cancel];
	[cancel release];
	[ct release];
	
	RCBarButtonItem *bt = [[RCBarButtonItem alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
	[bt addTarget:self action:@selector(saveChanges) forControlEvents:UIControlEventTouchUpInside];
	[bt setImage:[UIImage imageNamed:@"icon_tick"] forState:UIControlStateNormal];
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithCustomView:bt];
	[self.navigationItem setRightBarButtonItem:done];
	[done release];
	[bt release];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [sectionalArrays count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0;
	return 36;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [sectionalArrays[section] count];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 1.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [NSString stringWithFormat:@"0_%d_%d", indexPath.row, indexPath.section];
	RCSettingsTableViewCell *cell = (RCSettingsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	NSString *text = [sectionalArrays[indexPath.section] objectAtIndex:indexPath.row];
	if (!cell) {
		cell = [[[RCSettingsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
		switch (indexPath.section) {
			case 0: {
				break;
			}
            case 1: {
                UISwitch *aSwitch = [[UISwitch alloc] init];
                [aSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
				NSString *key = [keyValues objectForKey:text];
				if ([key isEqualToString:THEME_NAME_KEY])
					aSwitch.on = [[managedPreferences objectForKey:key] isEqualToString:@"DarkUI"];
                else aSwitch.on = (BOOL)[[managedPreferences objectForKey:[keyValues objectForKey:text]] boolValue];
                [cell setAccessoryView:aSwitch];
                [aSwitch release];
				break;
            }
            case 2: {
                UISwitch *aSwitch = [[UISwitch alloc] init];
                [aSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
                aSwitch.on = (BOOL)[[managedPreferences objectForKey:[keyValues objectForKey:text]] boolValue];
                [cell setAccessoryView:aSwitch];
                [aSwitch release];
				break;
            }
            case 3: {
				break;
            }
            case 4: {
				break;
            }
			default:
				break;
		}
	}
	cell.textLabel.text = text;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 3: {
            break;
        }
        case 4: {
            RCAboutViewController *about = [[RCAboutViewController alloc] init];
            [self.navigationController pushViewController:about animated:YES];
			[about release];
            break;
        }
        default: {
            break;
        }
    }
}

- (void)switchToggled:(UISwitch *)aSwitch {
	madeChanges = YES;
	RCSettingsTableViewCell *cell = (RCSettingsTableViewCell *)[aSwitch superview];
	if (isiOS7) cell = (RCSettingsTableViewCell *)[cell superview];
	NSString *key = [keyValues objectForKey:cell.textLabel.text];
	if ([key isEqualToString:THEME_NAME_KEY]) {
		themeChanged = YES;
		[managedPreferences setObject:(aSwitch.on ? @"DarkUI" : @"LightUI") forKey:THEME_NAME_KEY];
	}
	else [managedPreferences setObject:(aSwitch.on ? (id)kCFBooleanTrue : (id)kCFBooleanFalse) forKey:key];
}

- (NSString *)titleText {
	return @"Settings";
}

- (void)cancelChanges {
	[self dismiss];
}

- (void)saveChanges {
	if (madeChanges) {
		if (themeChanged) {
			[[NSNotificationCenter defaultCenter] postNotificationName:THEME_CHANGED_KEY object:[managedPreferences objectForKey:THEME_NAME_KEY] userInfo:nil];
		}
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
