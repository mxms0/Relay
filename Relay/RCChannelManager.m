//
//  RCRoomsController.m
//  Relay
//
//  Created by David Murray on 12-06-05.
//  Copyright (c) 2012 École Secondaire De Mortagne. All rights reserved.
//

#import "RCChannelManager.h"

@implementation RCChannelManager

- (id)initWithStyle:(UITableViewStyle)style andNetwork:(RCNetwork *)net {
	if ((self = [super initWithStyle:style])) {
		network = net;
		channels = [[NSMutableArray alloc] initWithArray:[[net _channels] allKeys]];
		[channels removeObject:@"IRC"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
	titleView.text = @"Channels";
	titleView.backgroundColor = [UIColor clearColor];
	titleView.textAlignment = UITextAlignmentCenter;
	titleView.font = [UIFont boldSystemFontOfSize:22];
	titleView.shadowColor = [UIColor whiteColor];
	titleView.textColor = UIColorFromRGB(0x424343);
	titleView.shadowOffset = CGSizeMake(0, 1);
	self.navigationItem.titleView = titleView;
	[titleView release];
	self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"0_bg"]];
	float y = 44;
	float width = 320;
	if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
		y = 33; width = 480;
	}
	r_shadow = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, width, 10)];
	[r_shadow setImage:[UIImage imageNamed:@"0_r_shadow"]];
	r_shadow.alpha = 0.5;
	[self.navigationController.navigationBar addSubview:r_shadow];
	[r_shadow release];
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
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [addBtn release];
    addBtn = nil;
    [channels release];
    channels = nil;
    network = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	return [channels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    RCAddCell *cell = (RCAddCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RCAddCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
		cell.textLabel.textColor = UIColorFromRGB(0x545758);
        cell.textLabel.text = [channels objectAtIndex:indexPath.row];

	}
    
    return cell;
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        RCChannel *channel = [[RCChannel alloc] initWithChannelName:[channels objectAtIndex:indexPath.row]];
        [network removeChannel:channel];
        [channel release];
        
        [channels removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

-(void)addNewItem {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Add New Channel" message:@"Enter the channel name below" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add channel",nil];
    [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [av show];
    [av release];                           
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{   
    if (buttonIndex == 1) {
        UITextField *textField = [alertView textFieldAtIndex:0];
        
        NSMutableString *newChannelString = [NSMutableString string];
        newChannelString = (NSMutableString *) textField.text;
        
        unichar cc = [newChannelString characterAtIndex:0]; 
        if (cc == '#') {
            
        }
        else {
            NSString *tempstr = newChannelString;
            NSString *Wat = @"#";
            newChannelString = [NSMutableString stringWithFormat:@"%@%@",Wat,tempstr];

        }
        
        [channels addObject:newChannelString];
        [network setupRooms:[NSArray arrayWithObject:newChannelString]];
         
        [self.tableView reloadData];
    }
    else if (buttonIndex == 0) {
    }
    
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    if([inputText length] >= 1 )
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     DetailViewController *detailViewController = [[DetailViewController alloc] initWithNibName:@"Nib name" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
