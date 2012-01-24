//
//  RCTableHeaderView.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCTableHeaderView.h"

@implementation RCTableHeaderView

- (void)setNetwork:(RCNetwork *)network {
	UIImageView *shadow = [[UIImageView alloc] initWithFrame:self.frame];
	[shadow setImage:[UIImage imageNamed:@"T_Shadow"]];
	UILabel *_networkLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, self.frame.size.width/2, 21)];
	[_networkLabel setText:[network server]];
	[_networkLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
	[_networkLabel setTextColor:[UIColor whiteColor]];
	[_networkLabel setBackgroundColor:[UIColor clearColor]];
	UILabel *_connectionStatus = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width/2)+10, 2, (self.frame.size.width/2)-15, 21)];
	[_connectionStatus setTextAlignment:UITextAlignmentRight];
	[_connectionStatus setText:[network connectionStatus]];
	[_connectionStatus setBackgroundColor:[UIColor clearColor]];
	[_connectionStatus setTextColor:[UIColor whiteColor]];
	[_connectionStatus setFont:[UIFont boldSystemFontOfSize:15.0]];
	RCGradientView *_bg = [[RCGradientView alloc] initWithFrame:self.frame];
	[self addSubview:_bg];
	[self addSubview:shadow];
	[self addSubview:_connectionStatus];
	[self addSubview:_networkLabel];
	[_bg release];
	[shadow release];
	[_connectionStatus release];
	[_networkLabel release];
}

- (void)dealloc {
	[super dealloc];
}

@end
