//
//  RCLargeNavigator.m
//  Relay
//
//  Created by Max Shavrick on 9/15/12.
//

#import "RCLargeNavigator.h"

@implementation RCLargeNavigator

- (void)drawRect:(CGRect)rect {
	@autoreleasepool {
		if (_isLandscape) {
			UIImage *bg = [UIImage imageNamed:@"0_bg568h"];
			[bg drawInRect:CGRectMake(0, 32, 568, 320)];
		}
		else {
			UIImage *bg = [UIImage imageNamed:@"0_bg568h"];
			[bg drawInRect:CGRectMake(0, 45, 320, 568)];
		}
	}
}

- (void)presentNetworkPopover {
    if (!isFirstSetup) {
        [nWindow setFrame:CGRectMake(0, 0, (_isLandscape ? 480 : 320), (_isLandscape ? 320 : 480))];
        [nWindow reloadData];
		[self addSubview:nWindow];
		[self bringSubviewToFront:nWindow];
        [nWindow animateIn];
		if (_isLandscape) {
			if (currentPanel) {
				[nWindow setShouldRePresentKeyboardOnDismiss:[currentPanel isFirstResponder]];
				[currentPanel resignFirstResponder];
			}
		}
    }
}

- (void)rotateToInterfaceOrientation:(UIInterfaceOrientation)oi {
	[nWindow animateOut];
	[cover hide];
	_isLandscape = (UIInterfaceOrientationIsLandscape(oi));
	[scrollBar drawBG];
	[self setNeedsDisplay];
	if (currentPanel) {
		[currentPanel setFrame:[self frameForChatTable]];
	}
	if (_isLandscape) {
		bar.frame = CGRectMake(0, 0, 568, 32);
		bar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"0_navbar_landscape"]];
		scrollBar.frame = CGRectMake(240, 0, 240, 33);
		[scrollBar clearBG];
		titleLabel.frame = CGRectMake(45, 0, 150, bar.frame.size.height);
	}
	else {
		bar.frame = CGRectMake(0, 0, 320, 45);
		bar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"0_navbar"]];
		scrollBar.frame = CGRectMake(0, 45, 320, 32);
		titleLabel.frame = CGRectMake(47, 0, 225, bar.frame.size.height);
	}
	[[currentPanel mainView] scrollToBottom];
	[plus setFrame:[self frameForPlusButton]];
	[listr setFrame:[self frameForListButton]];
	[scrollBar setContentSize:(CGSize)(scrollBar.frame.size)];
	[memberPanel setFrame:[self frameForMemberPanel]];
	[nWindow correctAndRotateToInterfaceOrientation:oi];
}

- (CGRect)frameForInputField:(BOOL)activ {
	if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
		return CGRectMake(0, (activ ? 66 : 227), 568, 40);
	}
	return CGRectMake(0, (activ ? 215 : 433), 320, 40);
}

- (CGFloat)widthForTitleLabel {
	if (_isLandscape)
		return 140;
	return 200;
}

- (CGFloat)heightForNetworkBar {
	if (_isLandscape)
		return 33;
	return 45;
}

- (CGFloat)widthForNetworkBar {
	if (_isLandscape)
		return 568;
	return 320;
}

- (CGRect)frameForChatTable {
	if (_isLandscape)
		return CGRectMake(0, 32, 568, 227);
	return CGRectMake(0, 77, 320, 432);
}

- (CGRect)frameForMemberPanel {
	if (_isLandscape)
		return CGRectMake(0, 32, 568, 268);
	return CGRectMake(0, 77, 320, 471);
}

- (CGRect)frameForListButton {
	if (_isLandscape)
		return CGRectMake(3, 2, 40, 30);
    return CGRectMake(5, 5, 40, 35);
}
- (CGRect)frameForPlusButton {
	if (_isLandscape)
		return CGRectMake(197, 2, 40, 30);
    return CGRectMake(275, 5, 40, 35);
}

@end
