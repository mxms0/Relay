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
@synthesize channel, originalChannel;

- (id)initWithStyle:(UITableViewStyle)style network:(RCNetwork *)_net channel:(NSString *)_chan {
	if ((self = [super initWithStyle:style])) {
		net = _net;
		[self setChannel:channel]; // botched.
		jOC = NO;
		[self setOriginalChannel:_chan];
		if ((channel != nil) && ![channel isEqualToString:@""]) {
			jOC = [[net channelWithChannelName:channel] joinOnConnect];
			RCKeychainItem *item = [[RCKeychainItem alloc] initWithIdentifier:[NSString stringWithFormat:@"%@%@rpass", [_net _description], channel]  accessGroup:nil];
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
		cell = [[[RCBasicTextInputCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"0_CELLD"] autorelease];
		switch (indexPath.row) {
			case 0: {
				RCTextField *field = (RCTextField *)[cell accessoryView];
				[field addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
				[field setText:channel];
				[field setPlaceholder:@"#help"];
				[field setTag:1];
				break;
			}
			case 1: {
				RCTextField *field = (RCTextField *)[cell accessoryView];
				[field setSecureTextEntry:YES];
				[field addTarget:self action:@selector(passTextChanged:) forControlEvents:UIControlEventEditingChanged];
				[field setDelegate:self];
				[field setPlaceholder:@"password"];
				[field setText:pass];
				[field setTag:2];
				break;
			}
			case 2: {
				[cell setAccessoryView:nil];
				UISwitch *jocSwitch = [[UISwitch alloc] init];
				[jocSwitch setOn:jOC];
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
	if ([self.view findAndResignFirstResponder]) {
		// dismissed active text field
		return;
	}
	else {
		// text field already wasn't active, that means
		// we need to make this official and add it to the channel manager
	}
	NSString *_chan = [self titleText];
	if ([_chan isEqualToString:@"New Channel"]) {
		return;
	}
	MARK;
	if (![_chan isEqualToString:originalChannel]) {
		[net removeChannel:[net channelWithChannelName:originalChannel]];
		[net addChannel:_chan join:NO];
	}
	RCChannel *rchan = [net channelWithChannelName:_chan];
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
	channel = textField.text;
	[((UILabel *)self.navigationItem.titleView) setText:[self titleText]];
}

- (NSString *)titleText {
	return ([channel isEqualToString:@""] ? @"New Channel" : channel);
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
    return YES;
}

@end
