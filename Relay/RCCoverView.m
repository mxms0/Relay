//
//  RCCoverView.m
//  Relay
//
//  Created by Max Shavrick on 8/23/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import "RCCoverView.h"
#import "RCNetwork.h"

@implementation RCCoverView
@synthesize channel;

- (id)initWithFrame:(CGRect)frame andChannel:(RCChannel *)chan {
	if ((self = [super initWithFrame:frame])) {
		[self setBackgroundColor:[UIColor clearColor]];
		self.alpha = 0;
		[self setChannel:chan];
		mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ([chan isPrivate] ? 60 : 180), 55)];
		[self addSubview:mainView];
		backgroundImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mainView.frame.size.width, 55)];
		[backgroundImage setImage:[[UIImage imageNamed:@"0_chanover"] stretchableImageWithLeftCapWidth:17 topCapHeight:17]];
		backgroundImage.contentMode = UIViewContentModeScaleToFill;
		[mainView addSubview:backgroundImage];
		[backgroundImage release];
		arrow = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 11, 8)];
		[arrow setImage:[UIImage imageNamed:@"0_chanover_arrow"]];
		[self addSubview:arrow];
		[self bringSubviewToFront:arrow];
		[self layoutButtons];
	}
	return self;
}

- (void)layoutButtons {
	if (!channel) return;
	CGRect delRect = CGRectMake(62, 18, 20, 20);
	if (![channel isPrivate]) {
		UIButton *join = [[UIButton alloc] initWithFrame:CGRectMake(20, 18, 25, 20)];
		[join setBackgroundColor:[UIColor clearColor]];
		[join setImage:[UIImage imageNamed:@"0_joinbtn"] forState:UIControlStateNormal];
		[join addTarget:self action:@selector(joinPressed:) forControlEvents:UIControlEventTouchUpInside];
		if ([channel joined]) [join setEnabled:NO];
		else [join setEnabled:YES];
		[mainView addSubview:join];
		[join release];
		UIButton *user = [[UIButton alloc] initWithFrame:CGRectMake(102, 18, 23, 20)];
		[user setBackgroundColor:[UIColor clearColor]];
		[user addTarget:self action:@selector(userPressed:) forControlEvents:UIControlEventTouchUpInside];
		[user setImage:[UIImage imageNamed:@"0_usericon"] forState:UIControlStateNormal];
		[mainView addSubview:user];
		[user release];
		UIButton *part = [[UIButton alloc] initWithFrame:CGRectMake(138, 18, 25, 20)];
		[part setBackgroundColor:[UIColor clearColor]];
		[part addTarget:self action:@selector(partPressed:) forControlEvents:UIControlEventTouchUpInside];
		[part setImage:[UIImage imageNamed:@"0_partbtn"] forState:UIControlStateNormal];
		if ([channel joined]) [part setEnabled:YES];
		else [part setEnabled:NO];
		[mainView addSubview:part];
		[part release];
	}
	else {
		delRect = CGRectMake(20, 18, 20, 20);
	}
	UIButton *del = [[UIButton alloc] initWithFrame:delRect];
	[del setBackgroundColor:[UIColor clearColor]];
	[del addTarget:self action:@selector(deletePressed:) forControlEvents:UIControlEventTouchUpInside];
	[del setImage:[UIImage imageNamed:@"0_deletebtn"] forState:UIControlStateNormal];
	[mainView addSubview:del];
	[del release];
}

- (void)partPressed:(id)arg1 {
	[channel setJoined:NO withArgument:@""];
	[self hide];
}

- (void)userPressed:(id)ar1 {
		[self hide];
	[[RCNavigator sharedNavigator] tearDownForChannelList:[channel bubble]];
}

- (void)deletePressed:(id)arg1 {
	[[RCNavigator sharedNavigator] channelWantsSuicide:[channel bubble]];
	[self hide];
}

- (void)joinPressed:(id)arg1 {
	[channel setJoined:YES withArgument:nil];
	[self hide];
}

- (void)dealloc {
	[mainView release];
	[arrow release];
	[super dealloc];
}

- (void)setArrowPosition:(CGPoint)ppt {
	[arrow setFrame:(CGRect){ppt, {arrow.frame.size.width, arrow.frame.size.height}}];
	[mainView setFrame:CGRectMake((arrow.frame.origin.x+(arrow.frame.size.width/2))-(mainView.frame.size.width/2), ppt.y-4, mainView.frame.size.width, mainView.frame.size.height)];
	if ([[RCNavigator sharedNavigator] _isLandscape]) {
		[arrow setFrame:CGRectMake(arrow.frame.origin.x+240, arrow.frame.origin.y, arrow.frame.size.width, arrow.frame.size.height)];
		[mainView setFrame:CGRectMake(mainView.frame.origin.x+240, mainView.frame.origin.y, mainView.frame.size.width, mainView.frame.size.height)];
		if (mainView.frame.origin.x+mainView.frame.size.width > 480)
			mainView.frame = CGRectMake((480-mainView.frame.size.width), mainView.frame.origin.y, mainView.frame.size.width, mainView.frame.size.height);
		if (arrow.frame.origin.x < 240)
			arrow.frame = CGRectMake(243, arrow.frame.origin.y, arrow.frame.size.width, arrow.frame.size.height);
		else if (arrow.frame.origin.x+arrow.frame.size.width > 480)
			arrow.frame = CGRectMake(465-(arrow.frame.size.width), arrow.frame.origin.y, arrow.frame.size.width, arrow.frame.size.height);
	}
	else {
		if (mainView.frame.origin.x < 0)
			[mainView setFrame:(CGRect){{0, mainView.frame.origin.y}, mainView.frame.size}];
		else if (mainView.frame.origin.x + mainView.frame.size.width > 318)
			[mainView setFrame:CGRectMake(320-mainView.frame.size.width, mainView.frame.origin.y, mainView.frame.size.width, mainView.frame.size.height)];
		if (mainView.frame.origin.x+13 > arrow.frame.origin.x)
			arrow.frame = CGRectMake(mainView.frame.origin.x+13, arrow.frame.origin.y, arrow.frame.size.width, arrow.frame.size.height);
		else if (arrow.frame.origin.x+arrow.frame.size.width > 312)
			arrow.frame = CGRectMake(((mainView.frame.size.width+mainView.frame.origin.x)-arrow.frame.size.width)-13, arrow.frame.origin.y, arrow.frame.size.width, arrow.frame.size.height);
	}
}

- (void)show {
	self.alpha = 0;
	[UIView animateWithDuration:0.25 animations:^{
		self.alpha = 1;
	}];
}

- (void)hide {
	[UIView animateWithDuration:0.25 animations:^{
		self.alpha = 0;
	} completion:^(BOOL fin) {
		if (fin) {
			[self removeFromSuperview];
		}
	}];
	[[RCNavigator sharedNavigator] setCover:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (CGRectContainsPoint(mainView.frame, [[touches anyObject] locationInView:self])) {
	}
	else {
		[self hide];
	}	
}

@end
