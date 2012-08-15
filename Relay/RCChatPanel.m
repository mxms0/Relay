//
//  RCChatPanel.m
//  Relay
//
//  Created by Max Shavrick on 2/17/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChatPanel.h"
#import "RCChannel.h"
#import "RCNavigator.h"

@implementation RCChatPanel
@synthesize messages, channel;

- (id)initWithStyle:(UITableViewStyle)style andChannel:(RCChannel *)chan {
	if ((self = [super init])) {
		[self setBackgroundColor:[UIColor clearColor]];
		[self setChannel:chan];
		mainView = [[RCChatView alloc] initWithFrame:CGRectMake(0, 0, 320, 344)];
        [mainView setChatpanel:self];
		[self addSubview:mainView];
		UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponder)];
		[tapper setNumberOfTapsRequired:2];
		[tapper setNumberOfTouchesRequired:1];
		[tapper setCancelsTouchesInView:NO];
		[mainView addGestureRecognizer:tapper];
		[tapper release];
		[mainView release];
		currentWord = [[NSMutableString alloc] init];
		prev = @"";
		_bar = [[RCTextFieldBackgroundView alloc] initWithFrame:CGRectMake(0, 343, 320, 40)];
		[_bar setOpaque:NO];
		field = [[RCTextField alloc] initWithFrame:CGRectMake(15, 5, 295, 31)];
		[field setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
		[field setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[field setBorderStyle:UITextBorderStyleNone];
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
    }
    return self;
}

- (void)didPresentView
{
    [mainView scrollToBottom];
}

- (void)suggestNick:(UIGestureRecognizer *)gestr {
	prev = [channel userWithPrefix:currentWord pastUser:prev];
}

- (void)setFrame:(CGRect)frame {
	[_bar setFrame:CGRectMake(0, frame.size.height, frame.size.width, 40)];
	[self repositionKeyboardForUse:[field isFirstResponder] animated:NO];
	[super setFrame:CGRectMake(0, frame.origin.y, frame.size.width, frame.size.height+40)];
}

- (BOOL)isFirstResponder {
	return field.isFirstResponder;
}

- (BOOL)becomeFirstResponder {
	[self repositionKeyboardForUse:YES animated:YES];
	[field becomeFirstResponder];
	return YES;
}

- (void)becomeFirstResponderNoAnimate {
	[self repositionKeyboardForUse:YES animated:NO];
	[field becomeFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self repositionKeyboardForUse:NO animated:YES];
}

- (BOOL)resignFirstResponder {
	[self repositionKeyboardForUse:NO animated:YES];
	[field resignFirstResponder];
	return YES;
}

- (void)setHidesEntryField:(BOOL)entry {
	[_bar setHidden:entry];
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
	[self repositionKeyboardForUse:YES animated:YES];
    [mainView scrollToBottom];
}

- (void)repositionKeyboardForUse:(BOOL)key animated:(BOOL)anim {
	if (anim) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.25];
	}
	[_bar setFrame:[self frameForInputField:key]];
	field.frame = CGRectMake(15, 5, _bar.frame.size.width-30, 31);
	if (anim) [UIView commitAnimations];
	[mainView setFrame:CGRectMake(0, 0, _bar.frame.size.width, _bar.frame.origin.y)];
	[mainView setNeedsDisplay];
	[_bar performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

- (CGRect)frameForInputField:(BOOL)activ {
	if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
		return CGRectMake(0, (activ ? 66 : 227), 480, 40);
	}
	return CGRectMake(0, (activ ? 127 : 345), 320, 40);
}

- (void)postMessage:(NSString *)_message withType:(RCMessageType)type highlight:(BOOL)high {
	[self postMessage:_message withType:type highlight:high isMine:NO];
}

- (void)postMessage:(NSString *)_message withType:(RCMessageType)type highlight:(BOOL)high isMine:(BOOL)mine {
	RCMessageFormatter *message = [[RCMessageFormatter alloc] initWithMessage:_message isOld:NO isMine:mine isHighlight:high type:type];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [mainView layoutMessage:message];
        [mainView setNeedsDisplay];
        [message release];
    });
}

- (void)dealloc {
	[currentWord release];
	[super dealloc];
}

@end
