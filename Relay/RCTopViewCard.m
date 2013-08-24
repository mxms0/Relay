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
		tableView = [[RCSuperSpecialTableView alloc] initWithFrame:CGRectMake(0, navigationBar.frame.size.height, frame.size.width, frame.size.height-navigationBar.frame.size.height)];
		[tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		[tableView setBackgroundColor:[UIColor colorWithRed:53/255.0f green:53/255.0f blue:56/255.0f alpha:1.0f]];
		[tableView setShowsVerticalScrollIndicator:YES];
		[tableView setDelegate:self];
		[tableView setDataSource:self];
		[self addSubview:tableView];
		[tableView release];
		UIPanGestureRecognizer *panr = [[UIPanGestureRecognizer alloc] initWithTarget:[RCChatController sharedController] action:@selector(userSwiped_specialLikeAc3xx:)];
		[self addGestureRecognizer:panr];
		[panr release];
		currentChan = nil;
		[self loadNavigationButtons];
	}
	return self;
}

- (void)loadNavigationButtons {
	for (UIView *v in [[navigationBar.subviews copy] autorelease]) {
		[v removeFromSuperview];
	}
	RCBarButtonItem *bt = [[RCBarButtonItem alloc] initWithFrame:CGRectMake(2, 0, 50, (isiOS7 ? 40 : 0) + 45)];
	[bt setImage:[[RCSchemeManager sharedInstance] imageNamed:@"backarrow"] forState:UIControlStateNormal];
	[bt addTarget:[RCChatController sharedController] action:@selector(popUserListWithDefaultDuration) forControlEvents:UIControlEventTouchUpInside];
	[navigationBar addSubview:bt];
	[bt release];
}

- (void)findShadowAndDoStuffToIt {
	CGSize width = [UIApp statusBarFrame].size;
	CGFloat swidth = (width.width == 20.00 ? width.height : width.width);
	BOOL shouldBeVisible = (self.frame.origin.x >= swidth);
	for (CALayer *sub in [self.layer sublayers]) {
		if ([[sub name] isEqualToString:@"0_fuckingshadow"]) {
			[sub setFrame:CGRectMake(sub.frame.origin.x, sub.frame.origin.y, sub.frame.size.width, self.frame.size.height)];
			[sub setHidden:shouldBeVisible];
			break;
		}
	}
}

- (void)prepareToBecomeVisible {
	if ([currentChan isKindOfClass:[RCPMChannel class]]) {
		if (![(RCPMChannel *)currentChan hasWhois]) {
			[(RCPMChannel *)currentChan requestWhoisInformation];
			
		}
	}
}

- (void)scrollToTop {
	[tableView setContentOffset:CGPointZero animated:YES];
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
		if ([currentChan isKindOfClass:[RCPMChannel class]]) {
			[c setIsWhois:YES];
			[c setChannel:(RCPMChannel *)currentChan];
		}
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
		if ([[currentChan fullUserList] count] > 0) {
			c.textLabel.text = [[currentChan fullUserList] objectAtIndex:indexPath.row];
			if (indexPath.row == [[currentChan fullUserList] count]-1)
				[c setIsLast:YES];
		}
	}
	[c setChannel:(RCPMChannel *)currentChan];
	[c setNeedsDisplay];
	return c;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (showingUserInfo) return;
	if ([currentChan isKindOfClass:[RCConsoleChannel class]]) return;
	RCPrettyActionSheet *ac = [[RCPrettyActionSheet alloc] initWithTitle:[[currentChan fullUserList] objectAtIndex:indexPath.row] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Kick" otherButtonTitles:@"Private Message", @"User Info", @"Operator Actions", nil];
	[[RCChatController sharedController] presentActionSheetInRootView:ac];
	[ac release];
	[_tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 1:
			break;
		case 2:
			break;
		case 3:
			break;
		case 4:
			break;
		default:
			break;
	}
}

@end
