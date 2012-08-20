//
//  RCAlternateNicknamesManager.m
//  Relay
//
//  Created by David Murray on 12-07-10.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCAlternateNicknamesManager.h"

@implementation RCAlternateNicknamesManager

- (id)initWithStyle:(UITableViewStyle)style andNetwork:(RCNetwork *)net {
	if ((self = [super initWithStyle:style])) {
        network = net;
        titleView.text = @"Nicknames";
		nicknames = [[NSMutableArray alloc] init];
        if ([network _nicknames]) {
			if ([[network _nicknames] count] > 1) {
				[nicknames addObject:[network _nicknames]];
			}
			else {
				if ([network nick])
					[nicknames addObject:[network nick]];
				if ([network username] && [network nick])
					if (![[network username] isEqualToString:[network nick]])
						[nicknames addObject:[network username]];
			}
		}
		else {
			if ([network nick]) {
				[nicknames addObject:[network nick]];
			}
			else if ([network username]) {
				[nicknames addObject:[network username]];
			}
		}
		// hopefully find SOMETHING.        
    }
    return self;
}

- (NSString *)titleText {
	return @"Nicknames";
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 10;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [nicknames count] + (_rEditing ? 1 : 0);
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
		[((UITableView *)self.view) insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[nicknames count] inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
	else [((UITableView *)self.view) deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:[nicknames count] inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
	[((UITableView *)self.view) endUpdates];
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
	if (indexPath.row == [nicknames count]) {
		cell.textLabel.text = @"Add Nick";
	}
	else cell.textLabel.text = [nicknames objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //implement server removing shit crap
        [nicknames removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView reloadData];
	if ([nicknames count] > 0) {
		[self setupEditButton];
	}
	else {
		[self setupDoneButton];
		[self edit];
	}
}

- (void)viewDidUnload {
    [super viewDidUnload];
    [addBtn release];
    addBtn = nil;
    [nicknames release];
    nicknames = nil;
    network = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
