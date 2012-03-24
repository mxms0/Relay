//
//  RCBar.m
//  Relay
//
//  Created by Max Shavrick on 3/23/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCBar.h"

@implementation RCBar
@synthesize mode;
- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		mode = 0;
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
