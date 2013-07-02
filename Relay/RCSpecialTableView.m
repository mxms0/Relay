//
//  RCSpecialTableView.m
//  Relay
//
//  Created by Max Shavrick on 10/24/12.
//

#import "RCSpecialTableView.h"

@implementation RCSpecialTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
	if ((self = [super initWithFrame:frame style:style])) {
		UIView *pure = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 100)];
		[self setTableHeaderView:pure];
		[pure release];
		[self setContentInset:UIEdgeInsetsMake(-100, 0, 0, 0)];
		// this is to stop floating header views.
	}
	return self;
}

@end
