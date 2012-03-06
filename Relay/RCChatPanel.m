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
		[self setBackgroundColor:[UIColor clearColor]];
		[self setChannel:chan];
		self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 385) style:style];
		self.tableView.delegate = self;
		self.tableView.dataSource = self;
		[self.tableView setBackgroundColor:[UIColor clearColor]];
		[self addSubview:tableView];
		[tableView release];
		[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		messages = [[NSMutableArray alloc] init];

		_bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 340, 372, 44)];
		[_bar setTintColor:UIColorFromRGB(0x1E1F28)];
		field = [[UITextField alloc] initWithFrame:CGRectMake(0, 5, 307, 31)];
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
		[self addSubview:_bar];
		[_bar release];

    }
    return self;
}

- (BOOL)becomeFirstResponder {
	[self repositionKeyboardForUse:YES];
	[field becomeFirstResponder];
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self repositionKeyboardForUse:NO];
}

- (BOOL)resignFirstResponder {
	[self repositionKeyboardForUse:NO];
	[field resignFirstResponder];
	return YES;
}

- (void)setHidesEntryField:(BOOL)entry {
	[_bar setHidden:entry];
	if (entry) [tableView setFrame:CGRectMake(0, 0, 320, 384)];
	else [tableView setFrame:CGRectMake(0, 0, 320, 340)];	
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([textField.text isEqualToString:@""] || textField.text == nil) return NO;
	[channel userWouldLikeToPartakeInThisConversation:textField.text];
	[textField setText:@""];
	return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[textField setEnablesReturnKeyAutomatically:!(textField.text != nil && ![textField.text isEqualToString:@""])];
	[self repositionKeyboardForUse:YES];
}

- (void)repositionKeyboardForUse:(BOOL)key {

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
	if (key) {
		[_bar setFrame:CGRectMake(0, 124, 320, 44)];
	}
	else {
		[_bar setFrame:CGRectMake(0, 340, 320, 44)];
	}
	[self.tableView setFrame:CGRectMake(0, 0,  320, _bar.frame.origin.y)];
	[UIView commitAnimations];
}

- (void)postMessage:(NSString *)_message withFlavor:(RCMessageFlavor)flavor isHighlight:(BOOL)high {

	RCMessage *message = [[RCMessage alloc] init];
	[message setMessage:_message];
	[message setFlavor:flavor];
	[message setIsHighlight:high];
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}


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
//	NSString *CellIdentifier = [NSString stringWithFormat:@"0_cell-%d", indexPath.row];;
    static NSString *CellIdentifier = @"0_CELLID";
    RCChatCell *cell = (RCChatCell *)[_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RCChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
//	[cell _setText:[messages objectAtIndex:indexPath.row]];
    // Configure the cell...
	RCMessage *_message = [messages objectAtIndex:indexPath.row];
	cell.textLabel.text = [_message message];
	[cell _textHasBeenSet:(RCMessageFlavor)_message.flavor isHighlight:NO];

//	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//	dateFormatter.dateStyle = NSDateFormatterNoStyle;
//	dateFormatter.timeStyle = NSDateFormatterShortStyle;
//	NSString *timestamp = [dateFormatter stringFromDate:[NSDate date]];
//	NSLog(@"Hai. %@", timestamp);
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc {
	[messages release];
	[super dealloc];
}

@end
