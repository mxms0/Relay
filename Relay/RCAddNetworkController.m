//
//  RCAddNetworkController.m
//  Relay
//
//  Created by Max Shavrick on 3/4/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCAddNetworkController.h"

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

@implementation RCAddNetworkController
@synthesize _user, _nick, _name, _sPass, _nPass, _description, _server, _port, hasSSL, connectAtLaunch, tableView;

- (id)initWithNetwork:(RCNetwork *)net {
	if ((self = [super init])) {
		network = net;
		hasSSL = NO;
		connectAtLaunching = YES;
		if (network) {
			[self set_user:[network username]];
			[self set_nick:[network nick]];
			[self set_name:[network realname]];
			[self set_port:[NSString stringWithFormat:@"%d", [network port]]];
			[self set_nPass:[network npass]];
			[self set_sPass:[network spass]];
			[self set_description:[network sDescription]];
			[self setHasSSL:[network useSSL]];
			[self setConnectAtLaunch:[network COL]];
			[self set_server:[network server]];
			 
		}
		tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 416)]; // guess.
		tableView.delegate = self;
		tableView.dataSource = self;
	}
	return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self.view findAndResignFirstResponder];
}

- (void)loadView {
	[super loadView];
	[self.view addSubview:tableView];
	[tableView release];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

- (void)textFieldDidEndEditing:(UITextField *)textField {
	NSLog(@"FF %@",textField);
	switch ([textField tag]) {
		case 1:
			[self set_description:[textField text]];
			NSLog(@"Hai. %@", _description);
			break;
		case 2:
			[self set_server:[textField text]];
			[self.navigationItem.rightBarButtonItem setEnabled:([textField text].length > 0)];
						NSLog(@"Hai. %@", _server);
			break;
		case 3:
			[self set_port:[textField text]];
			break;
		case 4:
			[self set_user:[textField text]];
			break;
		case 5:
			[self set_nick:[textField text]];
			break;
		case 6:
			[self set_name:[textField text]];
			break;
		case 7:
			break;
		case 8:
			[self set_sPass:[textField text]];
			break;
		default:
			break;
	}
}

- (void)doneConnection {
	if (_server != nil) {
		[[RCNetworkManager sharedNetworkManager] ircNetworkWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:
																	 (_user ? _user : @"Guest"), USER_KEY, 
																	 (_nick ? _nick : @"Guest01"), NICK_KEY,
																	 (_name ? _name : @"Dave"), NAME_KEY,
																	 (_sPass ? _sPass : @""), S_PASS_KEY,
																	 (_nPass ? _nPass : @""), N_PASS_KEY,
																	 (_description ? _description : _server), DESCRIPTION_KEY,
																	 _server, SERVR_ADDR_KEY,
																	 (_port ? _port : @"6667"), PORT_KEY,
																	 [NSNumber numberWithBool:hasSSL], SSL_KEY,
																	 [NSNumber numberWithBool:connectAtLaunching], COL_KEY,
																	 [NSArray arrayWithObject:@"IRC"], CHANNELS_KEY,
																	 nil] isNew:YES];
	}
	[self doneWithJoin];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
			return 4;
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
	if ([textField tag] == 2) 
		if ([[textField text] length] > 2)
			self.navigationItem.rightBarButtonItem.enabled = YES;
	[[[self tableView] viewWithTag:textField.tag+1] becomeFirstResponder];
	[[self tableView] scrollToRowAtIndexPath:[self.tableView indexPathForCell:(UITableViewCell *)[textField superview]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	
	return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField tag] == 2 || [textField tag] == 3/* || [textField tag] == 12343*/) {
        if ([string isEqualToString:@" "]) {
            return NO;
        }
    }
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"CELL_%d_%d", indexPath.section, indexPath.row];
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
					address.autocorrectionType = UITextAutocorrectionTypeNo;
					address.autocapitalizationType = UITextAutocapitalizationTypeNone;
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
					UITextField *uField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 170, 22)];
					[uField setAdjustsFontSizeToFitWidth:YES];
					[uField setPlaceholder:@"John"];
					[uField setTag:4];
					[uField setText:_user];
					[uField setDelegate:self];
					[uField setKeyboardAppearance:UIKeyboardAppearanceAlert];
					[uField setReturnKeyType:UIReturnKeyNext];
					[cell setAccessoryView:uField];
					[uField release];
					break;
				case 1:
					cell.textLabel.text = @"Nickname";
					UITextField *nField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 170, 22)];
					[nField setAdjustsFontSizeToFitWidth:YES];
					@try {
						[nField setPlaceholder:[[UIDevice currentDevice] name]];
					}
					@catch (id bs) {
						NSLog(@"BS!");
						[nField setPlaceholder:@"John_iPhone"];	
					}
					[nField setTag:5];
					[nField setText:_nick];
					[nField setDelegate:self];
					[nField setKeyboardAppearance:UIKeyboardAppearanceAlert];
					[nField setReturnKeyType:UIReturnKeyNext];
					[cell setAccessoryView:nField];
					[nField release];
					break;
				case 2:
					cell.textLabel.text = @"Real Name";
					UITextField *rField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 170, 22)];
					[rField setAdjustsFontSizeToFitWidth:YES];
					[rField setPlaceholder:@"Johnathan"];
					[rField setTag:6];
					[rField setText:_name];
					[rField setDelegate:self];
					[rField setKeyboardAppearance:UIKeyboardAppearanceAlert];
					[rField setReturnKeyType:UIReturnKeyNext];
					[cell setAccessoryView:rField];
					[rField release];
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
					UITextField *seField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 170, 22)];
					[seField setAdjustsFontSizeToFitWidth:YES];
					[seField setPlaceholder:@"privateircftw"];
					[seField setTag:8];
					[seField setSecureTextEntry:YES];
					[seField setText:_name];
					[seField setDelegate:self];
					[seField setKeyboardAppearance:UIKeyboardAppearanceAlert];
					[seField setReturnKeyType:UIReturnKeyNext];
					[cell setAccessoryView:seField];
					[seField release];
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
				case 3:
					cell.textLabel.text = @"Rooms";
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					cell.selectionStyle = UITableViewCellSelectionStyleBlue;
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

- (void)dealloc {
	if (_sPass) [_sPass release];
	if (_nPass) [_nPass release];
	if (_name) [_name release];
	if (_nick) [_nick release];
	if (_user) [_user release];
	if (_description) [_description release];
	if (_server) [_server release];
	if (_port) [_port release];
	[super dealloc];
	// RELEASE TABLE VIEW.
}


- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[_tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
