//
//  RCAddNetwork.m
//  Relay
//
//  Created by Max Shavrick on 12/23/11.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import "RCAddNetworkViewController.h"

@implementation RCAddNetworkViewController
@synthesize _user, _nick, _name, _sPass, _nPass, _description, _server, _port, hasSSL, connectAtLaunch;

- (id)initWithStyle:(UITableViewStyle)style {
	if ((self = [super initWithStyle:style])) {
		hasSSL = NO;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	// stuff.
}

- (void)viewDidLoad {
    [super viewDidLoad];
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
	self.title = @"New Connection";
	
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)doneWithJoin {
	[self dismissModalViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(doneWithJoin)];
	[self.navigationItem setLeftBarButtonItem:cancel];
	[cancel release];
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneConnection)];
	done.enabled = NO;
	[self.navigationItem setRightBarButtonItem:done];
	[done release];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 4;
		case 1:
			return 3;
		case 2:
			return 2;
		case 3:
			return 3;
	}
	return (int)@"HAXX!!!";
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Connection Information";
		case 1:
			return @"User Information";
		case 2:
			return @"Authentication";
		case 3:
			return @"Advanced";
		default:
			break;
	}
	return @"  HAXXX !!! ";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
//	[textField resignFirstResponder];
	[[[self tableView] viewWithTag:textField.tag+1] becomeFirstResponder];
	[[self tableView] scrollToRowAtIndexPath:[self.tableView indexPathForCell:(UITableViewCell *)[textField superview]] atScrollPosition:UITableViewScrollPositionTop animated:YES];

	return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"CELL_%d_%d", indexPath.section, indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:15.5];
    }
    switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Description";
							cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
					UITextField *dField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 170, 22)];
					[dField setAdjustsFontSizeToFitWidth:YES];
					[dField setPlaceholder:@"Enter a description"];
					[dField setTag:1];
					[dField setText:_description];
					[dField setDelegate:self];
					[dField setKeyboardAppearance:UIKeyboardAppearanceAlert];
					[dField setReturnKeyType:UIReturnKeyNext];
					[cell setAccessoryView:dField];
					[dField release];
					break;
				case 1:
					cell.textLabel.text = @"Address";
                    UITextField *address = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 170, 22)];
                    address.adjustsFontSizeToFitWidth = YES;
                    address.placeholder = @"irc.network.tld";
                    address.keyboardType = UIKeyboardTypeURL;
					address.text = _server;
                    address.returnKeyType = UIReturnKeyNext;
                    address.tag = 2;
                    address.keyboardAppearance = UIKeyboardAppearanceAlert;
                    [address setDelegate:self];
                    [cell setAccessoryView:address];
                    [address release];
					break;
				case 2:
					cell.textLabel.text = @"Port";
					UITextField *pField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 170, 22)];
					[pField setAdjustsFontSizeToFitWidth:YES];
					[pField setPlaceholder:@"6667"];
					[pField setKeyboardType:UIKeyboardTypeNumberPad];
					[pField setReturnKeyType:UIReturnKeyNext];
					[pField setTag:3];
					[pField setText:_port];
					[pField setKeyboardAppearance:UIKeyboardAppearanceAlert];
					[pField setDelegate:self];
                    [cell setAccessoryView:pField];
                    [pField release];
					break;
				case 3:
					cell.textLabel.text = @"Use SSL";
					UISwitch *cnt = [[UISwitch alloc] init];
					[cnt setOn:hasSSL];
					[cnt addTarget:self action:@selector(sslSwitched:) forControlEvents:UIControlEventValueChanged];
					[cell setAccessoryView:cnt];
					[cnt release];
					break;
			}
			break;
		case 1:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Username";
					break;
				case 1:
					cell.textLabel.text = @"Nickname";
					break;
				case 2:
					cell.textLabel.text = @"Real Name";
					break;
			}
			break;
		case 2:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"NickServ";
					break;
				case 1:
					cell.textLabel.text = @"Server";
					break;
			}
			break;
		case 3:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Connect At Launch";
					UISwitch *cnt = [[UISwitch alloc] init];
					[cnt setOn:connectAtLaunch];
					[cnt addTarget:self action:@selector(launchSwitched:) forControlEvents:UIControlEventValueChanged];
					[cell setAccessoryView:cnt];
					[cnt release];
					break;
				case 1:
					cell.textLabel.text = @"Alternate Nicknames";
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
					break;
				case 2:
					cell.textLabel.text = @"Auto Commands";
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
					break;
			}
			break;
	}
    // Configure the cell...
    
    return cell;
}

- (void)sslSwitched:(UISwitch *)s {
	hasSSL = s.on;
}

- (void)launchSwitched:(UISwitch *)s {
	connectAtLaunch = s.on;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
