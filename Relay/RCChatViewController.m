//
//  RCChatViewController.m
//  Relay
//
//  Created by Max Shavrick on 10/28/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChatViewController.h"

@implementation RCChatViewController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
	if ((self = [super initWithRootViewController:rootViewController])) {
		CALayer *shdw = [[CALayer alloc] init];
		[shdw setName:@"0_fuckingshadow"];
		UIImage *mfs = [UIImage imageNamed:@"0_hzshdw"];
		[shdw setContents:(id)mfs.CGImage];
		[shdw setShouldRasterize:YES];
		[shdw setFrame:CGRectMake(-mfs.size.width, 0, mfs.size.width, self.view.frame.size.height)];
		[self.view.layer addSublayer:shdw];
		[shdw release];
		CALayer *hshdw = [[CALayer alloc] init];
		UIImage *hfs/*wo*/= [UIImage imageNamed:@"0_vzshdw"];
		[hshdw setContents:(id)hfs.CGImage];
		[hshdw setShouldRasterize:YES];
		[hshdw setFrame:CGRectMake(0, 44, [self navigationBar].frame.size.width, hfs.size.height)];
		[[self navigationBar].layer setMasksToBounds:NO];
		[[self navigationBar].layer addSublayer:hshdw];
		[hshdw release];
	}
	return self;
}

- (void)setFrame:(CGRect)rect {
	for (CALayer *sub in [self.view.layer sublayers]) {
		if ([[sub name] isEqualToString:@"0_fuckingshadow"]) {
			[sub setFrame:CGRectMake(sub.frame.origin.x, sub.frame.origin.y, sub.frame.size.width, self.view.frame.size.height)];
			[sub setHidden:(rect.origin.x == 0)];
			break;
		}
	}
	self.view.frame = rect;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"0_cbg"]]];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
