//
//  RCChatPanel.m
//  Relay
//
//  Created by Max Shavrick on 2/17/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChatPanel.h"
#import "RCChannel.h"

@implementation RCChatPanel
@synthesize channel, tableView;

- (id)initWithStyle:(UITableViewStyle)style andChannel:(RCChannel *)chan {
	if ((self = [super init])) {
		[self.view setBackgroundColor:[UIColor whiteColor]];
		[self setChannel:chan];
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 768, 650) style:style];
        else
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 385) style:style];
		self.tableView.delegate = self;
		self.tableView.dataSource = self;
		[self.view addSubview:tableView];
		[tableView release];
		[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		messages = [[NSMutableArray alloc] init];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            _bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 820, 44)];
        else
            _bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 372, 44)];
		[_bar setTintColor:UIColorFromRGB(0x38475C)];
		field = [[UITextField alloc] initWithFrame:CGRectMake(0, 5, 755, 31)];
		[field setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
		[field setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[field setBorderStyle:UITextBorderStyleRoundedRect];
		[field setReturnKeyType:UIReturnKeySend];
		[field setFont:[UIFont fontWithName:@"Helvetica" size:12]];
		[field setMinimumFontSize:17];
		[field setAdjustsFontSizeToFitWidth:YES];
		[field setDelegate:self];
		UIBarButtonItem *_field = [[UIBarButtonItem alloc] initWithCustomView:field];
		[_field setStyle:UIBarButtonItemStyleBordered];
		[_bar setItems:[NSArray arrayWithObject:_field]];
		[_field release];
		[field release];
		[self.view addSubview:_bar];
		[_bar release];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)becomeFirstResponder {
	[self repositionKeyboardForUse:YES];
	[field becomeFirstResponder];
	return YES;
}

- (BOOL)resignFirstResponder {
	[self repositionKeyboardForUse:NO];
	[field resignFirstResponder];
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[channel userWouldLikeToPartakeInThisConversation:textField.text];
	[textField setText:@""];
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[textField setEnablesReturnKeyAutomatically:!(textField.text != nil && ![textField.text isEqualToString:@""])];
	[self repositionKeyboardForUse:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self repositionKeyboardForUse:NO];
}

- (void)repositionKeyboardForUse:(BOOL)key {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
	if (key) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [_bar setFrame:CGRectMake(0, 652, 768, 44)];
        else
            [_bar setFrame:CGRectMake(0, 156, 320, 44)];
	}
	else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            [_bar setFrame:CGRectMake(0, 916, 768, 44)];
        else
            [_bar setFrame:CGRectMake(0, 386, 320, 44)];
	}
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self.tableView setFrame:CGRectMake(0, 0, 768, _bar.frame.origin.y)];
    else
        [self.tableView setFrame:CGRectMake(0, 0, 320, _bar.frame.origin.y)];
	[UIView commitAnimations];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
}

- (void)postMessage:(NSString *)_message withFlavor:(RCMessageFlavor)flavor {
	RCMessage *message = [[RCMessage alloc] init];
	[message setMessage:_message];
	[message setFlavor:flavor];
	[messages addObject:message];
	[message release];
	
	[self.tableView beginUpdates];
	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:([messages count]-1) inSection:0]] withRowAnimation:UITableViewRowAnimationMiddle];
	[self.tableView endUpdates];
	if (![self.tableView indexPathForSelectedRow]) {
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([messages count]-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	}
}

- (CGFloat)tableView:(UITableView *)_tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *c = [self tableView:_tableView cellForRowAtIndexPath:indexPath];
	[c layoutSubviews];
	return (c.textLabel.frame.size.height + 4);
}

- (NSInteger)tableView:(UITableView *)_tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 0.0;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self setTitle:[channel channelName]];
}

- (void)viewDidAppear:(BOOL)animated {
//	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}
/*
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:duration];
	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		[self.tableView setFrame:CGRectMake(0, 0, <#CGFloat width#>, <#CGFloat height#>)
	}
	else {
		
	}
}*/

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [messages count];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    RCChatCell *cell = (RCChatCell *)[_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RCChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
//	[cell _setText:[messages objectAtIndex:indexPath.row]];
    // Configure the cell...
	RCMessage *_message = [messages objectAtIndex:indexPath.row];
	cell.textLabel.text = [_message message];
	[cell _textHasBeenSet:(RCMessageFlavor)_message.flavor];
//	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//	dateFormatter.dateStyle = NSDateFormatterNoStyle;
//	dateFormatter.timeStyle = NSDateFormatterShortStyle;
//	NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
//	NSLog(@"Hai. %@", timestamp);
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return channel.topic;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (void)dealloc {
	[messages release];
	// don't release table view, will be done automatically.
	[super dealloc];
}

@end
