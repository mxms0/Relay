//
//  RCSwitch.m
//  Relay
//
//  Created by Max Shavrick on 3/21/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCSwitch.h"
#import <QuartzCore/QuartzCore.h>

@implementation RCSwitch

@synthesize on;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[self.layer setCornerRadius:16];
		[self setClipsToBounds:YES];
		bg = [[UIImageView alloc] initWithFrame:CGRectMake(-38, 0, 96, 29)];
		[bg setImage:[UIImage imageNamed:@"0_toggle"]];
		[self addSubview:bg];
		[bg release];
		[self setBackgroundColor:[UIColor clearColor]];
		knob = [[UIButton alloc] initWithFrame:CGRectMake(0, 0.5, 27, 27)];
		[knob setImage:[UIImage imageNamed:@"0_toggleind_normal"] forState:UIControlStateNormal];
		[self addSubview:knob];
		[knob release];
    }
    return self;
}


- (void)dealloc {
	[super dealloc];
}

@end
