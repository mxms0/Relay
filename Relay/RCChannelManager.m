//
//  RCRoomsController.m
//  Relay
//
//  Created by Max Shavrick on 3/24/12.
//

#import "RCChannelManager.h"

@implementation RCChannelManager

- (id)initWithStyle:(UITableViewStyle)style andNetwork:(RCNetwork *)net {
	if ((self = [super initWithStyle:style])) {
		network = net;
		_rEditing = NO;
		self.tableView.allowsSelectionDuringEditing = YES;
		self.tableView.separatorColor = UIColorFromRGB(0x393d4a);
		[self reloadData];
		if ([[net _channels] count] == 0) {
			[self edit];
			[self setupDoneButton];
		}
		else [self setupEditButton];
	}
    return self;
}

- (void)reloadData {
	if (channels) [channels release];
	channels = [[NSMutableArray alloc] init];
    for (RCChannel *chn in [network _channels]) {
        [channels addObject:[chn channelName]];
    }
	[channels removeObject:@"\x01IRC"];
	[self.tableView reloadData];
}

- (void)addChannel:(NSString *)chan {
	if ([channels containsObject:chan]) return;
	[channels insertObject:chan atIndex:[channels count]];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[channels count] inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
	[self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 0;
}

- (void)dealloc {
	[channels release];
	[network setListCallback:nil];
	[super dealloc];
}

- (NSString *)titleText {
	return @"Channels";
}

- (void)setupEditButton {
	RCBarButtonItem *base = [[RCBarButtonItem alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
	[base setImage:[UIImage imageNamed:@"0_editr"] forState:UIControlStateNormal];
	[base addTarget:self action:@selector(edit) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:base];
	[base release];
	[self.navigationItem setRightBarButtonItem:backButton];
	[backButton release];
}

- (void)setupDoneButton {
	RCBarButtonItem *base = [[RCBarButtonItem alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
	[base setImage:[UIImage imageNamed:@"0_checkr"] forState:UIControlStateNormal];
	[base addTarget:self action:@selector(edit) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:base];
	[base release];
	[self.navigationItem setRightBarButtonItem:backButton];
	[backButton release];
}

- (void)beginEditing:(id)btn {
	[self setupEditButton];
	[self.tableView setEditing:YES];
}

- (void)doneEditing:(id)btn {
	[self setupDoneButton];
	[self.tableView setEditing:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	RCBarButtonItem *base = [[RCBarButtonItem alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
	[base setImage:[UIImage imageNamed:@"0_backd"] forState:UIControlStateNormal];
	[base addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:base];
	[base release];
	[self.navigationItem setLeftBarButtonItem:backButton];
	[backButton release];
	UIView *footerBase = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320,60)];
	RCPrettyButton *td = [[RCPrettyButton alloc] initWithFrame:CGRectMake(10, 0, 300, 44)];
	[td setFrame:CGRectMake(10, 5, 300, 44)];
	[footerBase addSubview:td];
	[self.tableView setTableFooterView:footerBase];
	[footerBase release];
	BOOL allCOL = YES;
	for (RCChannel *chan in [network _channels]) {
		if (![chan joinOnConnect]) {
			allCOL = NO;
			break;
		}
	}
	if (allCOL) {
		[td setTitle:@"Do not join all channels on connect" forState:UIControlStateNormal];
	}
	else {
		[td setTitle:@"Join all channels on connect" forState:UIControlStateNormal];
	}
	[td setTag:(int)allCOL];
	[td addTarget:self action:@selector(toggleJoinOnConnectForAllChannels:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)goBack:(id)btn {
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)toggleJoinOnConnectForAllChannels:(RCPrettyButton *)bt {
	BOOL allCOL = !(BOOL)[bt tag];
	if (allCOL) {
		[bt setTitle:@"Do not join all channels on connect" forState:UIControlStateNormal];
	}
	else {
		[bt setTitle:@"Join all channels on connect" forState:UIControlStateNormal];
	}
	for (RCChannel *chan in [network _channels]) {
		[chan setJoinOnConnect:allCOL];
	}
	[bt setTag:(allCOL)];
	
}

- (void)edit {
	_rEditing = !_rEditing;
	[((UITableView *)self.tableView) setEditing:!_rEditing animated:NO];
	[((UITableView *)self.tableView) setEditing:_rEditing animated:YES];
	if ([((UITableView *)self.view) isEditing]) {
		[self setupDoneButton];
	}
	else {
		[self setupEditButton];	
	}
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
        cell = [[[RCAddCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
		cell.textLabel.textColor = [UIColor whiteColor];
		[cell setOpaque:YES];
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
		NSString *chan = nil;
		if ([channels count] == indexPath.row) {
			chan = @"";
		}
		else {
			chan = [channels objectAtIndex:indexPath.row];
		}
		RCChannelManagementViewController *management = [[RCChannelManagementViewController alloc] initWithStyle:UITableViewStyleGrouped network:network channel:chan];
		[management setDelegate:self];
		[self.navigationController pushViewController:management animated:YES];
		[management release];
		NSLog(@"meh %@", chan);
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSString *chan = nil;
	if ([channels count] == indexPath.row) {
		chan = @"";
	}
	else {
		chan = [channels objectAtIndex:indexPath.row];
	}
	RCChannelManagementViewController *management = [[RCChannelManagementViewController alloc] initWithStyle:UITableViewStyleGrouped network:network channel:chan];
	[management setDelegate:self];
	[self.navigationController pushViewController:management animated:YES];
	[management release];
}

@end
