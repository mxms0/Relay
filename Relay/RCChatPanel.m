//
//  RCChatPanel.m
//  Relay
//
//  Created by Max Shavrick on 2/17/12.
//

#import "RCChatPanel.h"
#import "RCChannel.h"
#import "RCChatController.h"
#import <CoreText/CoreText.h>

@implementation RCChatPanel
@synthesize messages, channel, mainView;

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
		field = [[RCTextField alloc] initWithFrame:CGRectMake(15, 5, 299, 31)];
		[field setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
		[field setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[field setBorderStyle:UITextBorderStyleNone];
		[field setKeyboardAppearance:UIKeyboardAppearanceDefault];
		[field setReturnKeyType:UIReturnKeySend];
		[field setTextColor:UIColorFromRGB(0x3e3f3f)];
		[field setFont:[UIFont fontWithName:@"Helvetica" size:12]];
		[field setMinimumFontSize:17];
		[field setAdjustsFontSizeToFitWidth:YES];
		[field setDelegate:self];
		//	[field setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[field setClearButtonMode:UITextFieldViewModeWhileEditing];
		[_bar addSubview:field];
		[field release];
		[self addSubview:_bar];
		[_bar release];
		CGRect sc = [[UIScreen mainScreen] applicationFrame];
		chatViewHeights[0] = sc.size.height-83;
		chatViewHeights[1] = sc.size.height-299;
		UIPanGestureRecognizer *panr = [[UIPanGestureRecognizer alloc] initWithTarget:[RCChatController sharedController] action:@selector(userSwiped:)];
		[panr setDelegate:[RCChatController sharedController]];
		[[[self mainView] scrollView] addGestureRecognizer:panr];
		[panr release];
	}
	return self;
}

- (void)didPresentView {
    [mainView scrollToBottom];
}

- (void)setFrame:(CGRect)frame {
	CGRect sc = [[UIScreen mainScreen] applicationFrame];
	chatViewHeights[0] = sc.size.height-83;
	chatViewHeights[1] = sc.size.height-299;
	[_bar setFrame:CGRectMake(0, frame.size.height, frame.size.width, 40)];
	[self repositionKeyboardForUse:[field isFirstResponder] animated:NO];
	[super setFrame:CGRectMake(0, frame.origin.y, frame.size.width, frame.size.height+40)];
}

- (BOOL)isFirstResponder {
	return [field isFirstResponder];
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

- (void)setEntryFieldEnabled:(BOOL)en {
	[field setEnabled:en];
}

- (void)repositionKeyboardForUse:(BOOL)key animated:(BOOL)anim {
	if (anim) {
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.25];
	}
	CGRect main = CGRectMake(0, 0, 320, chatViewHeights[(int)key]);
	[mainView setFrame:main];
	[_bar setFrame:CGRectMake(0, mainView.frame.origin.x+mainView.frame.size.height, mainView.frame.size.width, 40)];
	field.frame = CGRectMake(15, 5, _bar.frame.size.width-21, 31);
	if (anim) [UIView commitAnimations];
	[mainView setNeedsDisplay];
	[_bar performSelectorOnMainThread:@selector(setNeedsDisplay) withObject:nil waitUntilDone:NO];
}

- (CGRect)frameForInputField:(BOOL)activ {
	return [[RCChatController sharedController] frameForInputField:activ];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([channel isPrivate]) return YES;
	NSString *text = [[textField text] retain];
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,0);
	dispatch_async(queue, ^ {
		NSString *lolhaiqwerty = text;
		NSRange rr = NSMakeRange(0, range.location+string.length);
		lolhaiqwerty = [lolhaiqwerty stringByReplacingCharactersInRange:range withString:string];
		for (int i = (range.location + string.length-1); i >= 0; i--) {
			if ([lolhaiqwerty characterAtIndex:i] == ' ') {
				rr.location = i + 1;
				rr.length = ((range.location + string.length) - rr.location);
				break;
			}
		}
		NSString *personMayb = [lolhaiqwerty substringWithRange:rr];
		NSLog(@"hai look wat i found :%@", [channel usersMatchingWord:personMayb]);
		[text release];
	});
	return YES;
}

- (void)postMessage:(NSString *)_message withType:(RCMessageType)type highlight:(BOOL)high {
	[self postMessage:_message withType:type highlight:high isMine:NO];
}

- (void)postMessage:(NSString *)_message withType:(RCMessageType)type highlight:(BOOL)high isMine:(BOOL)mine {
    [_message retain];
	RCMessageFormatter *message = [[RCMessageFormatter alloc] initWithMessage:_message isOld:NO isMine:mine isHighlight:high type:type];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [mainView layoutMessage:message];
        [mainView setNeedsDisplay];
        [message release];
        [_message release];
    });
}

- (void)dealloc {
	[currentWord release];
	[super dealloc];
}

@end
