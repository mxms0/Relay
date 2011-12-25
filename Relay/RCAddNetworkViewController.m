//
//  RCAddNetwork.m
//  Relay
//
//  Created by Max Shavrick on 12/23/11.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import "RCAddNetworkViewController.h"

@implementation RCAddNetworkViewController
@synthesize _user, _nick, _name, _sPass, _nPass, _description, _server, _port, hasSSL;

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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 4;
		case 1:
			return 5;
		case 2:
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
    }
    switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Description";
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
					break;
				case 3:
					cell.textLabel.text = @"Use SSL";
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
				case 3:
					cell.textLabel.text = @"Nick Password";
					break;
				case 4:
					cell.textLabel.text = @"Server Password";
					break;
			}
			break;
		case 2:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Connect At Launch";
					UISwitch *cnt = [[UISwitch alloc] init];
					[cnt setOn:hasSSL];
					[cnt addTarget:self action:@selector(sslSwitched:) forControlEvents:UIControlEventValueChanged];
					[cell setAccessoryView:cnt];
					[cnt release];
					break;
				case 1:
					cell.textLabel.text = @"Alternate Nicknames";
					break;
				case 2:
					cell.textLabel.text = @"Auto Commands";
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
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
