//
//  RAMainViewController.m
//  Relay IRC
//
//  Created by Max Shavrick on 7/20/15.
//  Copyright (c) 2015 Mxms. All rights reserved.
//

#import "RAMainViewController.h"
#import "RANetworkManager.h"
#import "RAChatController.h"
#import "RATableHeaderView.h"

@implementation RAMainViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

	CALayer *statusBarFix = [CALayer layer];
	[statusBarFix setBackgroundColor:[[UIColor colorWithRed:49/255.0 green:67/255.0 blue:82/255.0 alpha:1.0] CGColor]];
	[statusBarFix setFrame:CGRectMake(0, 0, self.view.frame.size.width, 20)];
	[self.view.layer addSublayer:statusBarFix];
	
	self.view.backgroundColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
	
	currentChannel = nil;
	
	[(RANavigationBar *)self.navigationController.navigationBar setTapDelegate:self];
	
	controller = [[RAChatController alloc] init];
	[controller setDelegate:self];
	
	NSArray *nets = @[
					  @"irc.saurik.com",
					  @"irc.freenode.org",
					  @"irc.rizon.net"
					  ];
	
	
	for (NSString *str in nets) {
		RCNetwork *net = [[RCNetwork alloc] init];
		[net setServer:str];
		[net setDelegate:controller];
		[net setChannelDelegate:controller];
		[net setPort:6697];
		[net setUseSSL:YES];
		[net setUsername:@"Maximus"];
		[net setNick:@"Maximus"];
		[net setRealname:@"Maximus"];
		[net setChannelCreationHandler:^(RCChannel *channel) {
			static NSString *RAChannelProxyAssociationKey = @"RAChannelProxyAssociationKey";
			RAChannelProxy *proxy = objc_getAssociatedObject(channel, RAChannelProxyAssociationKey);
			if (!proxy) {
				proxy = [[RAChannelProxy alloc] initWithChannel:channel];
				objc_setAssociatedObject(channel, RAChannelProxyAssociationKey, proxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
			}
		}];
		
		[net createConsoleChannel];
		[net connect];
		[[RANetworkManager sharedNetworkManager] addNetwork:net];
		[net release];
	}
	
	currentChannel = RAChannelProxyForChannel([[[RANetworkManager sharedNetworkManager] networks][0] consoleChannel]);
	NSLog(@"Fds %@", currentChannel);
	
	conversationView = [[RATableView alloc] init];
	[self.view addSubview:conversationView];
	conversationView.delegate = self;
	conversationView.dataSource = self;
//	conversationView.sectionHeaderHeight = RANetworkHeaderViewHeight;
	conversationView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - (20 + 44));
	
	[conversationView performSelector:@selector(reloadData) withObject:nil afterDelay:2];
	
	inputField = [[RATextField alloc] init];
	[inputField setDelegate:self];
	[inputField setFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
	[self.view addSubview:inputField];
	[self.view bringSubviewToFront:inputField];
	[inputField setBackgroundColor:[UIColor lightGrayColor]];

}

- (void)networkSelectionView:(RANetworkSelectionView *)view userSelectedChannel:(RCChannel *)channel {
	currentChannel = RAChannelProxyForChannel(channel);
	[conversationView reloadData];
	[UIView beginAnimations:nil context:nil];
	[selectionView setFrame:CGRectMake(0, 44, self.view.frame.size.width, 0)];
	[UIView commitAnimations];
}

- (void)keyboardWillShow:(NSNotification *)noti {
	CGRect keyboardFrame;
	[[[noti userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];
	NSNumber *dur = [[noti userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSNumber *curve = [[noti userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	keyboardFrame = [self.view convertRect:keyboardFrame toView:nil];
	CGRect containerFrame = inputField.frame;
	BOOL isKLandscape = UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]);
	float height = [[UIScreen mainScreen] bounds].size.height;
	if (isKLandscape)
		height = [[UIScreen mainScreen] bounds].size.width;
	containerFrame.origin.y = height - (keyboardFrame.size.height + containerFrame.size.height);
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:[dur doubleValue]];
	[UIView setAnimationCurve:[curve intValue]];
	inputField.frame = containerFrame;
	inputField.frame = CGRectMake(inputField.frame.origin.x, inputField.frame.origin.y, containerFrame.size.width - inputField.frame.origin.x, inputField.frame.size.height);
	[conversationView setFrame:CGRectMake(0, conversationView.frame.origin.y, conversationView.frame.size.width, inputField.frame.origin.y - 44)];
//	suggestLocation = inputField.frame.origin.y - 25;
	[UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)noti {
	NSNumber *dur = [[noti userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey];
	NSNumber *curve = [[noti userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey];
	CGRect containerFrame = inputField.frame;
	containerFrame.origin.y = conversationView.bounds.size.height - containerFrame.size.height;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:[dur doubleValue]];
	[UIView setAnimationCurve:[curve intValue]];
	inputField.frame = containerFrame;
	
	[conversationView setFrame:CGRectMake(0, conversationView.frame.origin.y, conversationView.frame.size.width, 160)];
	[UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if ([textField.text isEqualToString:@""] || textField.text == nil) return NO;
	
	NSString *userInput = [textField.text retain];
	RCChannel *channel = [currentChannel channel];
	[channel userWouldLikeToPartakeInThisConversation:userInput];
	
	[textField setText:@""];
//	[[RCNickSuggestionView sharedInstance] dismiss];
	return NO;
}

- (void)keyboardDidHide:(NSNotification *)noti {
//	[[RCNickSuggestionView sharedInstance] dismiss];
}

- (RAChannelProxy *)currentChannelProxy {
	return currentChannel;
}

- (void)chatControllerWantsUpdateUI:(RAChatController *)controller {

}

- (void)navigationBarButtonWasPressed:(RANavigationBarButton *)btn {
	// bring down RANetworkSelectionView
	if (!selectionView) {
		selectionView = [[RANetworkSelectionView alloc] init];
		[selectionView setBackgroundColor:[UIColor whiteColor]];
		[selectionView setDelegate:self];
	}
	[selectionView setFrame:CGRectMake(0, 64, self.view.frame.size.width, 0)];
	[self.view addSubview:selectionView];
	[self.view bringSubviewToFront:selectionView];
	[UIView beginAnimations:nil context:nil];
	[selectionView setFrame:CGRectMake(0, 64, self.view.frame.size.width, 400)];
	[UIView commitAnimations];
	
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[currentChannel messages] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"f"];
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"f"];
	}
	cell.textLabel.minimumScaleFactor = .8;
	cell.textLabel.adjustsFontSizeToFitWidth = YES;
	cell.textLabel.numberOfLines = 0;
	cell.textLabel.text = [[currentChannel messages] objectAtIndex:indexPath.row];
//	cell.textLabel.text = [channelMessages objectAtIndex:indexPath.row];
	
	return cell;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end
