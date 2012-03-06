//
//  RCViewController.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import "RCViewController.h"
#import "RCNetworkManager.h"
#import "RCNavigator.h"


@implementation RCViewController

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - VIEW SHIT

- (void)viewDidLoad {
    [super viewDidLoad];
	CGSize screenWidth = [[UIScreen mainScreen] applicationFrame].size;
	RCNavigator *navigator = [RCNavigator sharedNavigator];
	[navigator setFrame:CGRectMake(0, 0, screenWidth.width, screenWidth.height)];
	[self.view addSubview:navigator];
	[navigator release];
	[self.navigationController setNavigationBarHidden:YES];
	
/*	[[RCNetworkManager sharedNetworkManager] ircNetworkWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:
										  @"_m", USER_KEY, 
										  @"_m", NICK_KEY,
										  @"0_m_hai", NAME_KEY,
										  @"privateircftw", S_PASS_KEY,
										  @"", N_PASS_KEY,
										  @"feer", DESCRIPTION_KEY,
										  @"fr.ac3xx.com", SERVR_ADDR_KEY,
										  @"6667", PORT_KEY,
										  [NSNumber numberWithBool:0], SSL_KEY,
										  [NSNumber numberWithBool:1], COL_KEY,
										  [NSArray arrayWithObjects:@"#chat", @"#tttt", nil], CHANNELS_KEY,
										  nil]];
	[[RCNetworkManager sharedNetworkManager] ircNetworkWithInfo:[NSDictionary dictionaryWithObjectsAndKeys:
										@"_m", USER_KEY,
										@"_m", NICK_KEY,
										@"0_m_hai", NAME_KEY,
										@"", S_PASS_KEY,
										@"", N_PASS_KEY,
										@"SK", DESCRIPTION_KEY,
										@"irc.saurik.com", SERVR_ADDR_KEY,
										@"6667", PORT_KEY,
										[NSNumber numberWithBool:0], SSL_KEY,
										[NSNumber numberWithBool:1], COL_KEY,
										[NSArray arrayWithObjects:@"#bacon", @"#kk",nil], CHANNELS_KEY,
										nil]];*/
	
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return ((interfaceOrientation == UIInterfaceOrientationPortrait) || (interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}

@end
