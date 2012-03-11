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
		self.tableView = [[RCTableView alloc] initWithFrame:CGRectMake(0, 0, 320, 385) style:style];
		self.tableView.delegate = self;
		self.tableView.dataSource = self;
		
		[self.tableView setBackgroundColor:[UIColor clearColor]];
		[self addSubview:tableView];
		[tableView release];
		[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		messages = [[NSMutableArray alloc] init];

		_bar = [[UIView alloc] initWithFrame:CGRectMake(0, 343, 320, 40)];
		[_bar setOpaque:NO];
		[_bar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"0_input"]]];
		field = [[UITextField alloc] initWithFrame:CGRectMake(15, 5, 295, 31)];
		[field setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
		[field setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[field setBorderStyle:UITextBorderStyleNone];
		[field setKeyboardAppearance:UIKeyboardAppearanceAlert];
		[field setReturnKeyType:UIReturnKeySend];
		[field setFont:[UIFont fontWithName:@"Helvetica" size:12]];
		[field setMinimumFontSize:17];
		[field setAdjustsFontSizeToFitWidth:YES];
		[field setDelegate:self];
		[_bar addSubview:field];
		[field release];
		[self addSubview:_bar];
		[_bar release];
		id keyboardImpl = [objc_getClass("UIKeyboardImpl") sharedInstance];
		[keyboardImpl setAlpha:0.8];
		UIImageView *_shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"0_shadow_t"]];
		[_shadow setFrame:CGRectMake(0, 0, 320, 7)];
		[self addSubview:_shadow];
		[_shadow release];
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
		[_bar setFrame:CGRectMake(0, 129, 320, 40)];
	}
	else {
		[_bar setFrame:CGRectMake(0, 343, 320, 40)];
	}
	[UIView commitAnimations];
	[self.tableView setFrame:CGRectMake(0, 0,  320, _bar.frame.origin.y)];
	if (key) if ([messages count] != 0) [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([messages count]-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)postMessage:(NSString *)_message withFlavor:(RCMessageFlavor)flavor highlight:(NSString *)high {
	[self postMessage:_message withFlavor:flavor highlight:high isMine:NO];
}

- (void)postMessage:(NSString *)_message withFlavor:(RCMessageFlavor)flavor highlight:(NSString *)high isMine:(BOOL)mine {
	RCMessage *message = [[RCMessage alloc] init];
	[message setMessage:_message];
	[message setFlavor:flavor];
	[message setHighlight:high];
	[message setIsMine:mine];
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
	[cell setMessage:_message];
	[cell _textHasBeenSet];
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
	if ([field isFirstResponder]) [field resignFirstResponder];
}

- (void)dealloc {
	[messages release];
	[super dealloc];
}

@end
