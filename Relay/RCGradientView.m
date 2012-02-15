//
//  RCGradientView.m
//  Relay
//
//  Created by Maximus on 1/13/12.
//

#import "RCGradientView.h"

@implementation RCGradientView

+ (Class)layerClass {
	return [CAGradientLayer class];
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		CAGradientLayer *gLayer = (CAGradientLayer *)self.layer;
		gLayer.colors = [NSArray arrayWithObjects:
						 (id)[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0].CGColor,
						 (id)[UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:1.0].CGColor, nil];
		self.backgroundColor = [UIColor blackColor];
		gLayer.shouldRasterize = YES;
    }
    return self;
}


@end
