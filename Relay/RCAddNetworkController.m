//
//  RCAddNetworkController.m
//  Relay
//
//  Created by Max Shavrick on 3/4/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCAddNetworkController.h"

#define FONT_SIZE 12
#define FONT_COLOR 0x56595A

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

- (id)initWithNetwork:(RCNetwork *)net {
	if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
		network = net;
		isNew = NO;
		if (!net) {
			network = [[RCNetwork alloc] init];
			isNew = YES;
		}
		else {
			[self.navigationItem.rightBarButtonItem setEnabled:YES];	
		}
	}
	return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self.view findAndResignFirstResponder];
}

- (void)loadView {
	[super loadView];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"0_addnav"] forBarMetrics:UIBarMetricsDefault];
	UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
	titleView.text = @"Add A Network";
	titleView.backgroundColor = [UIColor clearColor];
	titleView.textAlignment = UITextAlignmentCenter;
	titleView.font = [UIFont boldSystemFontOfSize:22];
	titleView.shadowColor = [UIColor whiteColor];
	titleView.textColor = UIColorFromRGB(0x424343);
	titleView.shadowOffset = CGSizeMake(0, 1);
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"0_bg"]];
	UIImageView *r_shadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 44, 320, 10)];
	[r_shadow setImage:[UIImage imageNamed:@"0_r_shadow"]];
	r_shadow.alpha = 0.5;
	[self.navigationController.navigationBar addSubview:r_shadow];
	[r_shadow release];
	// Do any additional setup after loading the view, typically from a nib.
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0) return 35.0;
	return 25.0;
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
	UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
	[btn setImage:[UIImage imageNamed:@"0_donebutton_normal"] forState:UIControlStateNormal];
	[btn setImage:[UIImage imageNamed:@"0_donebutton_pressed"] forState:UIControlStateHighlighted];
	[btn setImage:[UIImage imageNamed:@"0_donebutton_disabled"] forState:UIControlStateDisabled];
	btn.enabled = ([network server] != nil);
	[btn addTarget:self action:@selector(doneConnection) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithCustomView:btn];
	[btn release];
	[self.navigationItem setRightBarButtonItem:done];
	[done release];
	
	UIButton *cBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 40)];
	[cBtn setImage:[UIImage imageNamed:@"0_cancelbutton_normal"] forState:UIControlStateNormal];
	[cBtn setImage:[UIImage imageNamed:@"0_cancelbutton_pressed"] forState:UIControlStateHighlighted];
	[cBtn addTarget:self action:@selector(doneWithJoin) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithCustomView:cBtn];
	[cBtn release];
	[self.navigationItem setLeftBarButtonItem:cancel];
	[cancel release];
}

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
			[network setUsername:[textField text]];
			break;
		case 5:
			[network setNick:[textField text]];
			break;
		case 6:
			[network setRealname:[textField text]];
			break;
		case 7:
			break;
		case 8:
			[network setSpass:[textField text]];
			break;
		default:
			break;
	}
}

- (void)doneConnection {
	if (![network server]) return;
	if (![network spass]) [network setSpass:@""];
	if (![network npass]) [network setNpass:@""];
	if (![network realname]) [network setRealname:@""];
	if (![network nick]) [network setNick:@"Guest01"];
	if (![network username]) [network setUsername:[network nick]];
	if (![network port]) [network setPort:6667];
	if (![network sDescription]) [network setSDescription:[network server]];
	if (isNew) {
		[network setupRooms:[NSArray arrayWithObject:@"IRC"]];
		[[RCNetworkManager sharedNetworkManager] addNetwork:network];
		[network release];
	}
	else {
		if ([network isConnected])	[network disconnect];
	}
	[network connect];
	[[RCNetworkManager sharedNetworkManager] saveNetworks];
	[self doneWithJoin];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
			return @"   CONNECT INFORMATION";
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
    
    RCAddCell *cell = (RCAddCell *)[_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RCAddCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
		cell.textLabel.textColor = UIColorFromRGB(0x545758);
	}
    switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
					cell.textLabel.text = @"Description";
					cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
					RCTextField *dField = [[RCTextField alloc] initWithFrame:CGRectMake(0, 0, 170, 16)];
					[dField setAdjustsFontSizeToFitWidth:YES];
					[dField setPlaceholder:@"Enter a description"];
					[dField setTag:1];
					[dField setText:[network sDescription]];
					[dField setDelegate:self];
					[dField setKeyboardAppearance:UIKeyboardAppearanceDefault];
					[dField setReturnKeyType:UIReturnKeyNext];
					[dField setTextColor:UIColorFromRGB(FONT_COLOR)];
					[dField setFont:[UIFont systemFontOfSize:FONT_SIZE]];
#if USE_PRIVATE 
					[dField setInsertionPointColor:UIColorFromRGB(0x4F94EA)];
#endif
					[cell setAccessoryView:dField];
					[dField release];
					break;
				case 1:
					cell.textLabel.text = @"Address";
                    RCTextField *address = [[RCTextField alloc] initWithFrame:CGRectMake(0, 0, 170, 16)];
                    address.adjustsFontSizeToFitWidth = YES;
                    address.placeholder = @"irc.network.tld";
                    address.keyboardType = UIKeyboardTypeURL;
					address.text = [network server];
					address.autocorrectionType = UITextAutocorrectionTypeNo;
					address.autocapitalizationType = UITextAutocapitalizationTypeNone;
                    address.returnKeyType = UIReturnKeyNext;
                    address.tag = 2;
#if USE_PRIVATE 
					[address setInsertionPointColor:UIColorFromRGB(0x4F94EA)];
#endif
                    address.keyboardAppearance = UIKeyboardAppearanceDefault;
                    [address setDelegate:self];
					[address setTextColor:UIColorFromRGB(FONT_COLOR)];
					[address setFont:[UIFont systemFontOfSize:FONT_SIZE]];
                    [cell setAccessoryView:address];
                    [address release];
					break;
				case 2:
					cell.textLabel.text = @"Port";
					RCTextField *pField = [[RCTextField alloc] initWithFrame:CGRectMake(0, 0, 170, 16)];
					[pField setAdjustsFontSizeToFitWidth:YES];
					[pField setPlaceholder:@"6667"];
					[pField setKeyboardType:UIKeyboardTypeNumberPad];
					[pField setReturnKeyType:UIReturnKeyNext];
					[pField setTag:3];
					[pField setText:([network port] ? [NSString stringWithFormat:@"%d", [network port]] : nil)];
					[pField setKeyboardAppearance:UIKeyboardAppearanceDefault];
					[pField setDelegate:self];
#if USE_PRIVATE 
					[pField setInsertionPointColor:UIColorFromRGB(0x4F94EA)];
#endif
					[pField setTextColor:UIColorFromRGB(FONT_COLOR)];
					[pField setFont:[UIFont systemFontOfSize:FONT_SIZE]];
                    [cell setAccessoryView:pField];
                    [pField release];
					break;
				case 3:
					cell.textLabel.text = @"Use SSL";
				//	RCSwitch *cnt = [[RCSwitch alloc] initWithFrame:CGRectMake(0, 0, 57, 29)];
				//	[cell setAccessoryView:cnt];
				//	[cnt release];
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
					cell.textLabel.text = @"Username";
					RCTextField *uField = [[RCTextField alloc] initWithFrame:CGRectMake(0, 0, 170, 16)];
					[uField setAdjustsFontSizeToFitWidth:YES];
					[uField setPlaceholder:@"John"];
					[uField setTag:4];
					[uField setText:[network username]];
					[uField setDelegate:self];
					[uField setKeyboardAppearance:UIKeyboardAppearanceDefault];
					[uField setReturnKeyType:UIReturnKeyNext];
#if USE_PRIVATE 
					[uField setInsertionPointColor:UIColorFromRGB(0x4F94EA)];
#endif
					[uField setTextColor:UIColorFromRGB(FONT_COLOR)];
					[uField setFont:[UIFont systemFontOfSize:FONT_SIZE]];
					[cell setAccessoryView:uField];
					[uField release];
					break;
				case 1:
					cell.textLabel.text = @"Nickname";
					RCTextField *nField = [[RCTextField alloc] initWithFrame:CGRectMake(0, 0, 170, 16)];
					[nField setAdjustsFontSizeToFitWidth:YES];
					@try {
						[nField setPlaceholder:[[UIDevice currentDevice] name]];
					}
					@catch (id bs) {
						[nField setPlaceholder:@"John_iPhone"];	
					}
					[nField setTag:5];
					[nField setText:[network nick]];
					[nField setDelegate:self];
#if USE_PRIVATE 
					[nField setInsertionPointColor:UIColorFromRGB(0x4F94EA)];
#endif
					[nField setKeyboardAppearance:UIKeyboardAppearanceDefault];
					[nField setReturnKeyType:UIReturnKeyNext];
					[nField setTextColor:UIColorFromRGB(FONT_COLOR)];
					[nField setFont:[UIFont systemFontOfSize:FONT_SIZE]];
					[cell setAccessoryView:nField];
					[nField release];
					break;
				case 2:
					cell.textLabel.text = @"Real Name";
					RCTextField *rField = [[RCTextField alloc] initWithFrame:CGRectMake(0, 0, 170, 16)];
					[rField setAdjustsFontSizeToFitWidth:YES];
					[rField setPlaceholder:@"Johnathan"];
					[rField setTag:6];
					[rField setText:[network realname]];
					[rField setDelegate:self];
#if USE_PRIVATE 
					[rField setInsertionPointColor:UIColorFromRGB(0x4F94EA)];
#endif
					[rField setTextColor:UIColorFromRGB(FONT_COLOR)];
					[rField setFont:[UIFont systemFontOfSize:FONT_SIZE]];
					[rField setKeyboardAppearance:UIKeyboardAppearanceDefault];
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
					RCTextField *seField = [[RCTextField alloc] initWithFrame:CGRectMake(0, 0, 170, 16)];
					[seField setAdjustsFontSizeToFitWidth:YES];
					[seField setPlaceholder:@"privateircftw"];
					[seField setTag:8];
					[seField setSecureTextEntry:YES];
					[seField setText:[network spass]];
					[seField setDelegate:self];
#if USE_PRIVATE 
					[seField setInsertionPointColor:UIColorFromRGB(0x4F94EA)];
#endif
					[seField setTextColor:UIColorFromRGB(FONT_COLOR)];
					[seField setFont:[UIFont systemFontOfSize:FONT_SIZE]];
					[seField setKeyboardAppearance:UIKeyboardAppearanceDefault];
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
					[cnt setOn:[network COL]];
					[cnt setOnTintColor:UIColorFromRGB(0x5296ea)];
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
	[network setUseSSL:s.on];
}

- (void)launchSwitched:(UISwitch *)s {
	[network setCOL:s.on];
}

- (void)dealloc {
	[super dealloc];
	// RELEASE TABLE VIEW.
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[_tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
