//
//  RCACMViewController.m
//  Relay
//
//  Created by Max Shavrick on 2/17/13.
//

#import "RCACMViewController.h"

@implementation RCACMViewController

- (id)init {
	if ((self = [super initWithStyle:UITableViewStylePlain])) {
		if (self.view) {
			[self.view release];
			self.view = nil;
			self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
			[self.view setBackgroundColor:UIColorFromRGB(0x141925)];
			// .. this view should have instructions, explanations, etc.
			// atm it will just work tho. so
		}
	}
	return self;
}

- (NSString *)titleText {
	return @"Auto Commands";
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	textField = [[UITextView alloc] initWithFrame:CGRectMake(4, 4, self.view.frame.size.width-8, self.view.frame.size.height-8)];
	[textField setBackgroundColor:[UIColor whiteColor]];
	[self.view addSubview:textField];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)dealloc {
	[textField release];
	[super dealloc];
}

@end
