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
		self.tableView.allowsSelectionDuringEditing = YES;
		[self reloadData];
    }
    return self;
}

- (void)reloadData {
	if (channels) [channels release];
	channels = [[NSMutableArray alloc] initWithArray:[[network _channels] allKeys]];
	[channels removeObject:@"IRC"];
	[self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 10;
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
