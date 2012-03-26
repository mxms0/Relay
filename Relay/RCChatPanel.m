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
@synthesize channel, tableView, messages;

- (id)initWithStyle:(UITableViewStyle)style andChannel:(RCChannel *)chan {
	if ((self = [super init])) {
		[self setBackgroundColor:[UIColor clearColor]];
		[self setChannel:chan];
		self.tableView = [[RCTableView alloc] initWithFrame:CGRectMake(0, 0, 320, 343) style:style];
		self.tableView.delegate = self;
		self.tableView.dataSource = self;
		[self.tableView setBackgroundColor:[UIColor clearColor]];
		[self addSubview:tableView];
		[tableView release];
		[self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		messages = [[NSMutableArray alloc] init];
		currentWord = [[NSMutableString alloc] init];
		prev = @"";
		_bar = [[UIView alloc] initWithFrame:CGRectMake(0, 343, 320, 40)];
		[_bar setOpaque:NO];
		[_bar setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"0_input"]]];
		field = [[UITextField alloc] initWithFrame:CGRectMake(15, 5, 295, 31)];
		[field setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
		[field setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[field setBorderStyle:UITextBorderStyleNone];
#if USE_PRIVATE
		/*
		char selector[24];
		selector[0] = 's';
		selector[1] = 'e';
		selector[2] = 't';
		selector[3] = 'I';
		selector[4] = 'n';
		selector[5] = 's';
		selector[6] = 'e';
		selector[7] = 'r';
		selector[8] = 't';
		selector[9] = 'i';
		selector[10] = 'o';
		selector[11] = 'n';
		selector[12] = 'P';
		selector[13] = 'o';
		selector[14] = 'i';
		selector[15] = 'n';
		selector[16] = 't';
		selector[17] = 'C';
		selector[18] = 'o';
		selector[19] = 'l';
		selector[20] = 'o';
		selector[21] = 'r';
		selector[22] = ':';
		selector[23] = '\0';
		
		objc_msgSend(field, sel_registerName(selector), UIColorFromRGB(0x4F94EA));
		 */
		[field setInsertionPointColor:UIColorFromRGB(0x4F94EA)];
#endif
		[field setKeyboardAppearance:UIKeyboardAppearanceDefault];
		[field setReturnKeyType:UIReturnKeySend];
		[field setFont:[UIFont fontWithName:@"Helvetica" size:12]];
		[field setMinimumFontSize:17];
		[field setAdjustsFontSizeToFitWidth:YES];
		[field setDelegate:self];
		[_bar addSubview:field];
		[field release];
		[self addSubview:_bar];
		[_bar release];
		UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(suggestNick:)];
		[field addGestureRecognizer:gesture];
		[gesture release];
		UIImageView *_shadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"0_shadow_t"]];
		[_shadow setFrame:CGRectMake(0, 0, 320, 7)];
		[self addSubview:_shadow];
		[_shadow release];
    }
    return self;
}

- (void)suggestNick:(UIGestureRecognizer *)gestr {
	prev = [channel userWithPrefix:currentWord pastUser:prev];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//	NSLog(@"Replacement.  [%@] [%@]", [textField.text substringWithRange:range], string);
//	NSLog(@"Bleh. %@", NSStringFromRange(range));	
//	if ([[textField.text substringWithRange:range] isEqualToString:@" "]) {
		// currentWord = previous Word in sentance?!?!?! D:DSofhdsdgisufdsk
		//	UITextRange *randr = [textField selectedTextRange];
		//	NSRange rangeOfLastWord = [textField.text rangeOfString:@" " options:NSBackwardsSearch range:NSMakeRange(randr.end, textField.text.length-randr.end)];
//	}
//	if (![string isEqualToString:@" "] && ([string length] == 1)) {
//		if (range.length == 0) [currentWord appendString:string];
//		else [currentWord deleteCharactersInRange:range];
//	}
//	else {
//		[currentWord setString:@""];
//	}
	return YES;
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
	[self performSelectorInBackground:@selector(__reallySend:) withObject:textField.text];
	[textField setText:@""];
	return NO;
}

- (void)__reallySend:(NSString *)msg {
	[channel performSelectorOnMainThread:@selector(userWouldLikeToPartakeInThisConversation:) withObject:msg waitUntilDone:NO];
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
	[self.tableView setFrame:CGRectMake(0, 0, 320, (key ? 129 : 343))];
	if (key) if ([messages count] != 0) [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([messages count]-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
	if (key) {
		if (self.tableView.contentSize.height > 129) {

		}
	}
	else {
	}
}

- (void)postMessage:(NSString *)_message withFlavor:(RCMessageFlavor)flavor highlight:(BOOL)high {
	[self postMessage:_message withFlavor:flavor highlight:high isMine:NO];
}

- (void)postMessage:(NSString *)_message withFlavor:(RCMessageFlavor)flavor highlight:(BOOL)high isMine:(BOOL)mine {
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
    static NSString *CellIdentifier = @"0_CELLID";
    RCChatCell *cell = (RCChatCell *)[_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[RCChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    // Configure the cell...
	RCMessage *_message = [messages objectAtIndex:indexPath.row];
	if ([cell message]) {
		if (![[cell message] isEqual:_message]) {
			[cell setMessage:_message];
			[cell _textHasBeenSet];
		}
	}
	else {
		[cell setMessage:_message];
		[cell _textHasBeenSet];
	}
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
	[currentWord release];
	[messages release];
	[super dealloc];
}

@end
