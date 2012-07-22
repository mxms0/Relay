//
//  RCPasswordRequestAlert.m
//  Relay
//
//  Created by Max Shavrick on 7/22/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCPasswordRequestAlert.h"
#import "RCnetwork.h"
#import "RCNetworkManager.h"

@implementation RCPasswordRequestAlert

- (id)initWithNetwork:(RCNetwork *)_net type:(RCPasswordRequestAlertType)ty {
	if ((self = [super initWithTitle:@"Error" message:[NSString stringWithFormat:@"There was an error retrieving your %@ password from the keychain. Please enter it again.", (ty == RCPasswordRequestAlertTypeNickServ ? @"NickServ" : @"server")] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil])) {
		net = _net;
		type = ty;
		[self setAlertViewStyle:UIAlertViewStyleSecureTextInput];
	}
	return self;
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
	switch (buttonIndex) {
		case 0: //cancel
			break;
		case 1:// ok
			if (type == RCPasswordRequestAlertTypeNickServ) {
				[net setNpass:[[self textFieldAtIndex:0] text]];
			}
			else if (type == RCPasswordRequestAlertTypeServer) {
				[net setSpass:[[self textFieldAtIndex:0] text]];
			}
			break;
		default:
			// fuck
			break;
	}
	if ([net COL]) [net connect];
	[[RCNetworkManager sharedNetworkManager] saveNetworks];
	[super dismissWithClickedButtonIndex:buttonIndex animated:animated];
}

@end
