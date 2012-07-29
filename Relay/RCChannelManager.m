//
//  RCRoomsController.m
//  Relay
//
//  Created by Max Shavrick on 3/24/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChannelManager.h"

@implementation RCChannelManager

- (id)initWithStyle:(UITableViewStyle)style andNetwork:(RCNetwork *)net {
	if ((self = [super initWithStyle:style])) {
		[net setNamesCallback:self];
		network = net;
		_rEditing = NO;
		channels = [[NSMutableArray alloc] initWithArray:[[net _channels] allKeys]];
		[channels removeObject:@"IRC"];
    }
    return self;
}

- (NSString *)titleText {
	return @"Channels";
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self.tableView reloadData];
	UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
	[self.navigationItem setRightBarButtonItem:edit];
	[edit release];
	self.tableView.allowsSelectionDuringEditing = YES;
	if ([network isConnected]) {
		[self addStupidWarningView];
	}
}

- (void)addStupidWarningView {
	UIView *back = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
	UILabel *warning = [[UILabel alloc] initWithFrame:CGRectMake(47, 5, 280, 40)];
	[warning setShadowColor:[UIColor blackColor]];
	[warning setShadowOffset:CGSizeMake(0, 1)];
	[warning setFont:[UIFont systemFontOfSize:14]];
	[warning setNumberOfLines:0];
	[warning setTextColor:[UIColor whiteColor]];
	[warning setBackgroundColor:[UIColor clearColor]];
	[warning setText:@"Requesting channel list from the server..."];
	UIActivityIndicatorView *vv = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
	[vv startAnimating];
	[back addSubview:vv];
	[vv release];
	[back addSubview:warning];
	[warning release];
	[self.tableView setTableHeaderView:back];
	[back release];
}

- (void)removeStupidWarningView {
	[self.tableView setTableHeaderView:nil];
}

- (void)edit {
	_rEditing = !_rEditing;
	[((UITableView *)self.tableView) setEditing:!_rEditing animated:NO];
	[((UITableView *)self.tableView) setEditing:_rEditing animated:YES];
	
	UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:([((UITableView *)self.view) isEditing] ? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit) target:self action:@selector(edit)];
	[self.navigationItem setRightBarButtonItem:rightBarButtonItem animated:YES];
	[rightBarButtonItem release];
	[((UITableView *)self.view) beginUpdates];
	if (_rEditing)
		[((UITableView *)self.view) insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[channels count] inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
	else [((UITableView *)self.view) deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[channels count] inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
	[((UITableView *)self.view) endUpdates];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated { 
    [super setEditing:editing animated:animated];
	if (editing) {
		NSMutableArray *items = [[self.navigationItem.rightBarButtonItems mutableCopy] autorelease];
		[items addObject: addBtn];
		self.navigationItem.rightBarButtonItems = items;
	}
	else {
		NSMutableArray *items = [[self.navigationItem.rightBarButtonItems mutableCopy] autorelease];
		[items removeObject: addBtn];
		self.navigationItem.rightBarButtonItems = items;

		//        for (NSString *channel in pendingChannels) {
		//   [network addChannel:channel join:NO];
        //}
        //[pendingChannels removeAllObjects];
	}
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [addBtn release];
    addBtn = nil;
    [channels release];
    channels = nil;
    network = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([channels count] == indexPath.row) {
        return UITableViewCellEditingStyleInsert;
    }
	return UITableViewCellEditingStyleDelete;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([channels count] + (_rEditing ? 1 : 0));
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"0_addCell";
    RCAddCell *cell = (RCAddCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RCAddCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
		cell.textLabel.textColor = UIColorFromRGB(0x545758);
	}
	if ([channels count] == indexPath.row) {
		cell.textLabel.text = @"Add Channel";
	}
	else {
		cell.textLabel.text = [channels objectAtIndex:indexPath.row];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		RCChannel *chan = [network channelWithChannelName:[channels objectAtIndex:indexPath.row]];
        [network removeChannel:chan];
        [channels removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)addNewItem {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Add New Channel" message:@"Enter the channel name below" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add channel", nil];
    [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [av show];
    [av release];                           
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {  
    if (buttonIndex == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        NSString *tempString = @"#";
		if (![textField.text hasPrefix:@"#"])
			tempString = [tempString stringByAppendingString:textField.text];  
        else 
            tempString = textField.text;
        [channels addObject:tempString];
		//   [pendingChannels addObject:tempString];
        [self.tableView reloadData];
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    if([inputText length] > 0) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
