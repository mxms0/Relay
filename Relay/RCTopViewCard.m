//
//  RCTopViewCard.m
//  Relay
//
//  Created by Max Shavrick on 6/17/13.
//

#import "RCTopViewCard.h"
#import "RCChannel.h"
#import "RCChatController.h"

@implementation RCTopViewCard
@synthesize currentChan;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		RCBarButtonItem *bt = [[RCBarButtonItem alloc] initWithFrame:CGRectMake(2, 0, 50, 45)];
		[bt setImage:[UIImage imageNamed:@"0_backa"] forState:UIControlStateNormal];
		[bt addTarget:[RCChatController sharedController] action:@selector(popUserListWithDefaultDuration) forControlEvents:UIControlEventTouchUpInside];
		[navigationBar addSubview:bt];
		[bt release];
		tableView = [[RCSuperSpecialTableView alloc] initWithFrame:CGRectMake(0, 44, frame.size.width, frame.size.height-44)];
		[tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		[tableView setBackgroundColor:UIColorFromRGB(0xDDE0E5)];
		[tableView setShowsVerticalScrollIndicator:YES];
		[tableView setDelegate:self];
		[tableView setDataSource:self];
		[tableView setScrollsToTop:YES];
		[self addSubview:tableView];
		[tableView release];
		UIPanGestureRecognizer *panr = [[UIPanGestureRecognizer alloc] initWithTarget:[RCChatController sharedController] action:@selector(userSwiped_specialLikeAc3xx:)];
		[self addGestureRecognizer:panr];
		[panr release];
	}
	return self;
}

- (void)showUserInfoPanel {
	showingUserInfo = YES;
	[tableView reloadData];
}

- (void)showUserListPanel {
	showingUserInfo = NO;
	[tableView reloadData];
}

- (void)reloadData {
	[tableView reloadData];
}

- (void)setChannel:(RCChannel *)chan {
	[currentChan setUsersPanel:nil];
	[self setCurrentChan:chan];
	NSString *set = @"Member List";
	showingUserInfo = NO;
	if ([chan isKindOfClass:[RCPMChannel class]]) {
		showingUserInfo = YES;
		set = [chan channelName];
	}
	[((RCChatNavigationBar *)[self navigationBar]) setTitle:set];
	[tableView reloadData];
	[chan setUsersPanel:(RCUserListPanel *)tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (showingUserInfo) return 100;
	return 44;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (showingUserInfo) return 1;
	if (![currentChan isKindOfClass:[RCConsoleChannel class]])
		return [[currentChan fullUserList] count];
	return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	RCUserTableCell *c = (RCUserTableCell *)[_tableView dequeueReusableCellWithIdentifier:@"0_usc"];
	if (!c) {
		c = [[[RCUserTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"0_usc"] autorelease];
	}
	// need to clear the currentChan if the user deletes the channel while it's the active one.
	// or else crash from objc_msgSend on deallocated objc
	[c setIsWhois:NO];
	if (showingUserInfo) {
		if ([currentChan isKindOfClass:[RCPMChannel class]])
			[c setIsWhois:YES];
		[c setIsLast:YES];
		[c setNeedsDisplay];
		return c;
	}
	[c setIsLast:NO];
	if ([currentChan isKindOfClass:[RCConsoleChannel class]]) {
		c.textLabel.text = @"There are no users in this channel.";
		c.detailTextLabel.text = @":(";
		[c setIsLast:YES];
	}
	else {
		c.textLabel.text = [[currentChan fullUserList] objectAtIndex:indexPath.row];
		if (indexPath.row == [[currentChan fullUserList] count]-1)
			[c setIsLast:YES];
	}
	[c setNeedsDisplay];
	return c;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (showingUserInfo) return;
	if ([currentChan isKindOfClass:[RCConsoleChannel class]]) return;
	RCPrettyActionSheet *ac = [[RCPrettyActionSheet alloc] initWithTitle:[[currentChan fullUserList] objectAtIndex:indexPath.row] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Kick" otherButtonTitles:@"Private Message", @"User Info", @"Operator Actions", nil];
	[ac setButtonCount:5];
	[ac showInView:[UIApp keyWindow]];
	[ac release];
	[_tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
