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
        titleView.text = @"Nicknames"; //Doesn't fit. >_<
        
        if ([network nick])
            nicknames = [[NSMutableArray alloc] initWithArray:[network _nicknames]];
        else 
            nicknames = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObject:@"Guest01"]];
        
    }
    return self;
}

- (NSString *)titleText {
	return @"Nicknames";
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
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [nicknames count];
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
	cell.textLabel.text = [nicknames objectAtIndex:indexPath.row];
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

- (void)presentAddAlert {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Add New Nickname" message:@"Enter the nickname below" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add nickname", nil];
    [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [av show];
    [av release];                           
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {  
    if (buttonIndex == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        [nicknames addObject:[textField text]];
        [self.tableView reloadData];
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
	NSString *inputText = [[alertView textFieldAtIndex:0] text];
    if ([inputText length] > 0) {
		return YES;
	}
	else {
		return NO;
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView reloadData];
    addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(presentAddAlert)];
    NSArray *array = [NSArray arrayWithObjects:self.editButtonItem, nil];
    [self.navigationItem setRightBarButtonItems:array animated:YES];
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
