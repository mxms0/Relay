//
//  RCHoverViewCard.m
//  Relay
//
//  Created by Max Shavrick on 7/29/13.
//

#import "RCHoverViewCard.h"
#import "RCCuteView.h"

@implementation RCHoverViewCard

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[navigationBar setMaxSize:18];
		[navigationBar setNeedsDisplay];
		CALayer *cv = [[CALayer alloc] init];
		[cv setContents:(id)[UIImage imageNamed:@"0_nvs"].CGImage];
		[cv setFrame:CGRectMake(0, -46, 320, 46)];
		[self.layer addSublayer:cv];
		[cv release];
	}
	return self;
}

- (void)scrollToTop {
	
}

- (void)dismiss {
	[(RCCuteView *)[self superview] dismiss];
}

@end
