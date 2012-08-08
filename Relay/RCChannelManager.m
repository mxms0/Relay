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
		NSLog(@"MEH %@", [net _channels]);
		self.tableView.allowsSelectionDuringEditing = YES;
		channels = [[NSMutableArray alloc] initWithArray:[[net _channels] allKeys]];
		[channels removeObject:@"IRC"];
    }
    return self;
}

- (void)dealloc {
	[channels release];
	[network setNamesCallback:nil];
	[super dealloc]; 
}

- (NSString *)titleText {
	return @"Channels";
}

- (void)viewDidLoad {
    [super viewDidLoad];
	UIBarButtonItem *edit = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit)];
	[self.navigationItem setRightBarButtonItem:edit];
	[edit release];
	if ([network isConnected]) {
		[network sendMessage:@"LIST"];
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
	NSLog(@"CHANNELS %@", channels);
	[((UITableView *)self.tableView) setEditing:!_rEditing animated:NO];
	[((UITableView *)self.tableView) setEditing:_rEditing animated:YES];
		NSLog(@"CHANNELS %@", channels);
	UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:([((UITableView *)self.view) isEditing] ? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit) target:self action:@selector(edit)];
	[self.navigationItem setRightBarButtonItem:rightBarButtonItem animated:YES];
	[rightBarButtonItem release];
	[((UITableView *)self.view) beginUpdates];
	NSLog(@"CHANNELS %@", channels);
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
	NSLog(@"WHAT THE FUCK %@", channels);
	if (_rEditing) return [channels count]+1;
	return [channels count];
	return ([channels count] + (_rEditing ? 1 : 0));
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"0_addCell";
    RCAddCell *cell = (RCAddCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RCAddCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *chan = nil;
	if ([channels count] == indexPath.row) {
		chan = @"";
	}
	else {
		chan = [channels objectAtIndex:indexPath.row];
	}
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	RCChannelManagementViewController *management = [[RCChannelManagementViewController alloc] initWithStyle:UITableViewStyleGrouped network:network channel:chan];
	[self.navigationController pushViewController:management animated:YES];
	[management release];
}

@end
