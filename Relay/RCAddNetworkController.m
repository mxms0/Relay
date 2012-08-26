//
//  RCAddNetworkController.m
//  Relay
//
//  Created by Max Shavrick on 3/4/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCAddNetworkController.h"
#import "RCKeychainItem.h"

@implementation RCAddNetworkController

- (id)initWithNetwork:(RCNetwork *)net {
	if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
		network = net;
		isNew = NO;
		if (!net) {
			network = [[RCNetwork alloc] init];
			isNew = YES;
		}
	}
	return self;
}

- (NSString *)titleText {
	if (isNew) {
		return @"Add A Network";
	}
	else {
		return [network _description];
	}
	return nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self.view findAndResignFirstResponder];
}

- (void)loadView {
	[super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	float y = 44;
	float width = 320;
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
		y = 32; width = 480;
	}
	if (!r_shadow) {
		r_shadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, width, 10)];
		[r_shadow setImage:[UIImage imageNamed:@"0_r_shadow"]];
		r_shadow.alpha = 0.3;
		[self.navigationController.navigationBar addSubview:r_shadow];
		[r_shadow release];
	}
	UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 30)];
	[btn setTitle:@"Done" forState:UIControlStateNormal];
	[[btn titleLabel] setTextAlignment:UITextAlignmentCenter];
	[btn setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[[btn titleLabel] setShadowOffset:CGSizeMake(0, 1)];
	[[btn titleLabel] setFont:[UIFont boldSystemFontOfSize:11]];
	[btn setTitleColor:UIColorFromRGB(0x929292) forState:UIControlStateDisabled];
	[btn setTitleColor:UIColorFromRGB(0x454646) forState:UIControlStateNormal];
	[btn setBackgroundImage:[[UIImage imageNamed:@"0_navbtn"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
	[btn setBackgroundImage:[[UIImage imageNamed:@"0_navbtn_p"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateHighlighted];
	//	[btn setImage:[UIImage imageNamed:@"0_donebutton_disabled"] forState:UIControlStateDisabled];
	btn.enabled = NO;
	[btn addTarget:self action:@selector(doneConnection) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithCustomView:btn];
	[btn release];
	btn.enabled = !isNew;
	[self.navigationItem setRightBarButtonItem:done];
	[done release];
	
	UIButton *cBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 30)];
	[cBtn setTitle:@"Cancel" forState:UIControlStateNormal];
	[cBtn setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[[cBtn titleLabel] setShadowOffset:CGSizeMake(0, 1)];
		[[cBtn titleLabel] setFont:[UIFont boldSystemFontOfSize:11]];
	[cBtn setTitleColor:UIColorFromRGB(0x454646) forState:UIControlStateNormal];
	[cBtn setBackgroundImage:[[UIImage imageNamed:@"0_navbtn"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
	[cBtn setBackgroundImage:[[UIImage imageNamed:@"0_navbtn_p"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateHighlighted];
	[cBtn addTarget:self action:@selector(doneWithJoin) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithCustomView:cBtn];
	[cBtn release];
	[self.navigationItem setLeftBarButtonItem:cancel];
	[cancel release];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)doneWithJoin {
	[[RCNavigator sharedNavigator] rotateToInterfaceOrientation:self.interfaceOrientation];
	[self dismissModalViewControllerAnimated:YES];
}
#define IS_STRING_OR(a,b) (((!a) || [a isEqualToString:@""]) ? b : a)

- (void)textFieldDidEndEditing:(RCTextField *)textField {
	switch ([textField tag]) {
		case 1:
			[network setSDescription:[textField text]];
			break;
		case 2:
			[network setServer:[textField text]];
			[self.navigationItem.rightBarButtonItem setEnabled:([network server].length > 0)];
			break;
		case 3:
			[network setPort:[[textField text] intValue]];
			break;
		case 4:
			[network setNick:IS_STRING_OR([textField text],[textField placeholder])];
			break;
		case 5:
			[network setUsername:IS_STRING_OR([textField text],[textField placeholder])];
			break;
		case 6:
            [network setRealname:IS_STRING_OR([textField text],[textField placeholder])];
			break;
		case 7:
			MARK;
			[network setNpass:[textField text]];
			break;
		case 8:
			MARK;
			[network setSpass:[textField text]];
			break;
		default:
			break;
	}
}
- (void)doneConnection {
	[self.view findAndResignFirstResponder];
	if (![network server]) return;
    [network setRealname:IS_STRING_OR([network realname], @"Guest")];
    [network setNick:IS_STRING_OR([network nick], @"Guest")];
    [network setUsername:IS_STRING_OR([network username], @"Guest")];
	if (![network port]) [network setPort:6667];
	if (![network sDescription]) [network setSDescription:[network server]];
    if (isNew) {
		[network setupRooms:[NSArray arrayWithObject:@"IRC"]];
		[[RCNetworkManager sharedNetworkManager] addNetwork:network];
	}
	else {
		if ([network isConnected])	[network disconnect];
	}
	NSLog(@"HELLO %@", network);
	if (([network spass] == nil) || [[network spass] isEqualToString:@""]) {
		[network setSpass:@""];
	}
	else {
		RCKeychainItem *keychain = [[RCKeychainItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%@spass", [network _description]]];
        [keychain setObject:[network spass] forKey:(id)kSecValueData];
		[keychain release];
	}
	if (([network npass] == nil) || [[network npass] isEqualToString:@""]) {
		[network setNpass:@""];
	}
	else {
		RCKeychainItem *keychain = [[RCKeychainItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%@npass", [network _description]]];
        [keychain setObject:[network npass] forKey:(id)kSecValueData];
		[keychain release];
	}
	[[RCNetworkManager sharedNetworkManager] saveNetworks];
	[[RCNavigator sharedNavigator] refreshTitleBar:network];
	[self doneWithJoin];
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 1;
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
			return @"   CONNECTION INFORMATION";
		case 1:
			return @"   USER INFORMATION";
		case 2:
			return @"   AUTHENTICATION";
		case 3:
			return @"   ADVANCED";
		default:
			break;
	}
	return @"  HAXXX !!! ";
}

- (void)showStupidWarningsRegardingMichiganUniversity {
	RCPrettyAlertView *warning = [[RCPrettyAlertView alloc] initWithTitle:@"Error!" message:@"This server is currently not supported and may not be supported in the future. Use efnet instead" delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
	[warning show];
	[warning release];
}

- (BOOL)textFieldShouldReturn:(RCTextField *)textField {
	//	[textField resignFirstResponder];
	if ([textField tag] == 2) 
		if ([[network server] length] > 0)
			self.navigationItem.rightBarButtonItem.enabled = YES;
	[[[self tableView] viewWithTag:textField.tag+1] becomeFirstResponder];
	[[self tableView] scrollToRowAtIndexPath:[self.tableView indexPathForCell:(UITableViewCell *)[textField superview]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
	
	return NO;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
	if ([textField tag] == 2) {
		self.navigationItem.rightBarButtonItem.enabled = ([[network server] length] > 0);
	}
	return YES;
}

- (BOOL)textField:(RCTextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField tag] == 2 || [textField tag] == 3/* || [textField tag] == 12343*/) {
        if ([string isEqualToString:@" "]) {
            return NO;
        }
    }
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"CELL_%d_%d", indexPath.section, indexPath.row];
    
    RCBasicTextInputCell *cell = (RCBasicTextInputCell *)[_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RCBasicTextInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		switch (indexPath.section) {
			case 0:
				switch (indexPath.row) {
					case 0:
						cell.textLabel.text = @"Description";
						cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
						RCTextField *dField = (RCTextField *)[cell accessoryView];
						[dField setAdjustsFontSizeToFitWidth:YES];
						[dField setPlaceholder:@"Enter a description"];
						[dField setTag:1];
						[dField setText:[network sDescription]];
						[dField setDelegate:self];
						[dField setKeyboardAppearance:UIKeyboardAppearanceDefault];
						[dField setReturnKeyType:UIReturnKeyNext];
						break;
					case 1:
						cell.textLabel.text = @"Address";
						RCTextField *address = (RCTextField *)[cell accessoryView];
						address.adjustsFontSizeToFitWidth = YES;
						address.placeholder = @"irc.network.tld";
						address.keyboardType = UIKeyboardTypeURL;
						address.text = [network server];
						address.autocorrectionType = UITextAutocorrectionTypeNo;
						address.autocapitalizationType = UITextAutocapitalizationTypeNone;
						address.returnKeyType = UIReturnKeyNext;
						address.tag = 2;
						address.keyboardAppearance = UIKeyboardAppearanceDefault;
						[address setDelegate:self];
						break;
					case 2:
						cell.textLabel.text = @"Port";
						RCTextField *pField = (RCTextField *)[cell accessoryView];
						[pField setAdjustsFontSizeToFitWidth:YES];
						[pField setPlaceholder:@"6667"];
						[pField setKeyboardType:UIKeyboardTypeNumberPad];
						[pField setReturnKeyType:UIReturnKeyNext];
						[pField setTag:3];
						[pField setText:([network port] ? [NSString stringWithFormat:@"%d", [network port]] : nil)];
						[pField setKeyboardAppearance:UIKeyboardAppearanceDefault];
						[pField setDelegate:self];
						break;
					case 3:
						cell.textLabel.text = @"Use SSL";
						UISwitch *cnt = [[UISwitch alloc] init];
						[cnt setOn:[network useSSL]];
						[cnt addTarget:self action:@selector(sslSwitched:) forControlEvents:UIControlEventValueChanged];
						[cell setAccessoryView:cnt];
						[cnt release];
						break;
				}
				break;
			case 1:
				switch (indexPath.row) {
					case 0:
                        cell.textLabel.text = @"Nickname";
						RCTextField *uField = (RCTextField *)[cell accessoryView];
						[uField setAdjustsFontSizeToFitWidth:YES];
						@try {
                            NSString* name = [[UIDevice currentDevice] name];
                            int ix = [name length];
                            int px = [name rangeOfString:@" "].location;
                            if (px != NSNotFound) {
                                ix = px;
                            }
							[uField setPlaceholder:[name substringToIndex:ix]];
						}
						@catch (id bs) {
							[uField setPlaceholder:@"Guest"];
						}
						[uField setTag:4];
						[uField setText:[network nick]];
						[uField setDelegate:self];
						[uField setKeyboardAppearance:UIKeyboardAppearanceDefault];
						[uField setReturnKeyType:UIReturnKeyNext];
						break;
					case 1:
                        cell.textLabel.text = @"Username";
						RCTextField *nField = (RCTextField *)[cell accessoryView];
						[nField setAdjustsFontSizeToFitWidth:YES];
                        @try {
                            NSString* name = [[UIDevice currentDevice] name];
                            int ix = [name length];
                            int px = [name rangeOfString:@" "].location;
                            if (px != NSNotFound) {
                                ix = px;
                            }
							[nField setPlaceholder:[name substringToIndex:ix]];
						}
						@catch (id bs) {
							[nField setPlaceholder:@"Guest"];
						}
						[nField setTag:5];
						[nField setText:[network username]];
						[nField setDelegate:self];
						[nField setKeyboardAppearance:UIKeyboardAppearanceDefault];
						[nField setReturnKeyType:UIReturnKeyNext];
						break;
					case 2:
						cell.textLabel.text = @"Real Name";
						RCTextField *rField = (RCTextField *)[cell accessoryView];
						[rField setAdjustsFontSizeToFitWidth:YES];
						@try {
							[rField setPlaceholder:[[UIDevice currentDevice] name]];
						}
						@catch (id bs) {
							[rField setPlaceholder:@"Guest"];
						}
						[rField setTag:6];
						[rField setText:[network realname]];
						[rField setDelegate:self];
						[rField setKeyboardAppearance:UIKeyboardAppearanceDefault];
						[rField setReturnKeyType:UIReturnKeyNext];
						break;
				}
				break;
			case 2:
				switch (indexPath.row) {
					case 0:
						cell.textLabel.text = @"NickServ";
						RCTextField *nsField = (RCTextField *)[cell accessoryView];
						[nsField setAdjustsFontSizeToFitWidth:YES];
						[nsField setPlaceholder:@"a-password"];
						[nsField setTag:7];
						[nsField setSecureTextEntry:YES];
						[nsField setText:[network npass]];
						[nsField setDelegate:self];
						[nsField setKeyboardAppearance:UIKeyboardAppearanceDefault];
						[nsField setReturnKeyType:UIReturnKeyNext];
						break;
					case 1:
						cell.textLabel.text = @"Server";
						RCTextField *seField = (RCTextField *)[cell accessoryView];
						[seField setAdjustsFontSizeToFitWidth:YES];
						[seField setPlaceholder:@"privateircftw"];
						[seField setTag:8];
						[seField setSecureTextEntry:YES];
						[seField setText:[network spass]];
						[seField setDelegate:self];
						[seField setKeyboardAppearance:UIKeyboardAppearanceDefault];
						[seField setReturnKeyType:UIReturnKeyNext];
						break;
				}
				break;
			case 3:
				switch (indexPath.row) {
					case 0:
						cell.textLabel.text = @"Connect At Launch";
						UISwitch *cnt = [[UISwitch alloc] init];
						[cnt setOn:[network COL]];
						[cnt addTarget:self action:@selector(launchSwitched:) forControlEvents:UIControlEventValueChanged];
						[cell setAccessoryView:cnt];
						[cnt release];
						break;
					case 1:
						cell.textLabel.text = @"Alternate Nicknames";
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
						cell.selectionStyle = UITableViewCellSelectionStyleBlue;
						[cell setAccessoryView:nil];
						break;
					case 2:
						cell.textLabel.text = @"Auto Commands";
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
						cell.selectionStyle = UITableViewCellSelectionStyleBlue;
						[cell setAccessoryView:nil];
						break;
					case 3:
						cell.textLabel.text = @"Channels";
						cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
						cell.selectionStyle = UITableViewCellSelectionStyleBlue;
						[cell setAccessoryView:nil];
				}
				break;
		}
	}
    // Configure the cell...
    return cell;
}

- (void)sslSwitched:(UISwitch *)s {
	[network setUseSSL:s.on];
}

- (void)launchSwitched:(UISwitch *)s {
	[network setCOL:s.on];
}

- (void)dealloc {
	[super dealloc];
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
		case 3:
			if (indexPath.row == 3) {
				RCChannelManager *roomsController = [[RCChannelManager alloc] initWithStyle:UITableViewStyleGrouped andNetwork:network];
				[self.navigationController pushViewController:roomsController animated:YES];
				[roomsController release];
			}
            if (indexPath.row == 1) {
                RCAlternateNicknamesManager *nickManager = [[RCAlternateNicknamesManager alloc] initWithStyle:UITableViewStyleGrouped andNetwork:network];
				[self.navigationController pushViewController:nickManager animated:YES];
				[nickManager release];

            }
			break;
		default:
			break;
	}
	[_tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end