//
//  RCChannelManagementViewController.m
//  Relay
//
//  Created by Max Shavrick on 8/7/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCChannelManagementViewController.h"
#import "RCNetwork.h"

@implementation RCChannelManagementViewController

- (id)initWithStyle:(UITableViewStyle)style network:(RCNetwork *)_net channel:(NSString *)_chan {
	if ((self = [super initWithStyle:style])) {
		net = _net;
		chan = _chan;
	}
	return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"0_CELLD"];
	if (!cell) {

	}
}

- (NSString *)titleText {
	return ([chan isEqualToString:@""] ? @"New Channel" : chan);
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
