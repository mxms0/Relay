//
//  RCChannelManagementViewController.m
//  Relay
//
//  Created by Max Shavrick on 8/7/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChannelManagementViewController.h"
#import "RCNetwork.h"

@implementation RCChannelManagementViewController

- (id)initWithStyle:(UITableViewStyle)style network:(RCNetwork *)_net channel:(NSString *)_chan {
	if ((self = [super initWithStyle:style])) {
		net = _net;
		chan = [_chan retain];
		jOC = NO;
		orig = [@"" retain];
		if ((chan != nil) && ![chan isEqualToString:@""]) {
			orig = [chan retain];
			jOC = [[net channelWithChannelName:chan] joinOnConnect];
			RCKeychainItem *item = [[RCKeychainItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%@%@rpass", [_net _description], chan]  accessGroup:nil];
			pass = [item objectForKey:(id)kSecValueData];
			[item release];
		}
	}
	return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	RCBasicTextInputCell *cell = (RCBasicTextInputCell *)[tableView dequeueReusableCellWithIdentifier:@"0_CELLD"];
	if (!cell) {
		cell = [[RCBasicTextInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"0_CELLD"];
		switch (indexPath.row) {
			case 0: {
				RCTextField *field = (RCTextField *)[cell accessoryView];
				[field addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
				[field setText:chan];
				[field setTag:1];
				break;
			}
			case 1: {
				RCTextField *field = (RCTextField *)[cell accessoryView];
				[field setSecureTextEntry:YES];
				[field addTarget:self action:@selector(passTextChanged:) forControlEvents:UIControlEventEditingChanged];
				[field setDelegate:self];
				[field setText:pass];
				[field setTag:2];
				break;
			}
			case 2: {
				[cell setAccessoryView:nil];
				UISwitch *jocSwitch = [[UISwitch alloc] init];
				[jocSwitch addTarget:self action:@selector(jocSwitched:) forControlEvents:UIControlEventValueChanged];
				[cell setAccessoryView:jocSwitch];
				[jocSwitch release];
				break;
			}
				
		}
	}
	switch (indexPath.row) {
		case 0:
			cell.textLabel.text = @"Channel Name";
			break;
		case 1:
			cell.textLabel.text = @"Password";
			break;
		case 2:
			cell.textLabel.text = @"Join On Connect";
			break;			
	}
	return cell;
}

- (void)jocSwitched:(UISwitch *)sw {
	jOC = sw.on;
}

- (void)viewWillAppear:(BOOL)animated {
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneWithMod:)];
	[self.navigationItem setRightBarButtonItem:done];
	[done release];
}

- (void)doneWithMod:(id)pfff {
	chan = [(UILabel *)self.navigationItem.titleView text];
	if (![chan isEqualToString:orig]) {
		[net removeChannel:[net channelWithChannelName:orig]];
		[net addChannel:chan join:NO];
	}
	RCChannel *rchan = [net channelWithChannelName:chan];
	if ([pass length] > 0) {
		[rchan setPassword:pass];
	}
	[rchan setJoinOnConnect:jOC];
	[self.navigationController popViewControllerAnimated:YES];
	[[net namesCallback] reloadData];
}

- (BOOL)textFieldShouldReturn:(RCTextField *)textField {
	if (textField.tag == 1)
		[[[self tableView] viewWithTag:2] becomeFirstResponder];
	return NO;
}

- (void)passTextChanged:(UITextField *)textField {
	pass = textField.text;
}

- (void)textChanged:(UITextField *)textField {
	chan = textField.text;
	[((UILabel *)self.navigationItem.titleView) setText:[self titleText]];
}

- (NSString *)titleText {
	return ([chan isEqualToString:@""] ? @"New Channel" : chan);
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
