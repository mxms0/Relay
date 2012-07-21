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
		network = net;
        titleView.text = @"Channels";
		channels = [[NSMutableArray alloc] initWithArray:[[net _channels] allKeys]];
        pendingChannels = [[NSMutableArray alloc] init];
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
    addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem)];
    NSArray *array = [NSArray arrayWithObjects:self.editButtonItem, nil];
    [self.navigationItem setRightBarButtonItems:array animated:YES];
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

        for (NSString *channel in pendingChannels) {
            [network addChannel:channel join:NO];
        }
        [pendingChannels removeAllObjects];
	}
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [addBtn release];
    addBtn = nil;
    [channels release];
    channels = nil;
    network = nil;
    [pendingChannels release];
    pendingChannels = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [channels count];
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
	cell.textLabel.text = [channels objectAtIndex:indexPath.row];
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
        [pendingChannels addObject:tempString];
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
