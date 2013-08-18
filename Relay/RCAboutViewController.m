//
//  RCAboutViewController.m
//  Relay
//
//  Created by Fionn Kelleher on 15/08/2013.
//

#import "RCAboutViewController.h"
#import <objc/objc.h>

@implementation RCAboutViewController

- (id)init {
	if ((self = [super init])) {
        titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 40)];
		titleView.backgroundColor = [UIColor clearColor];
		titleView.textAlignment = UITextAlignmentCenter;
		titleView.font = [UIFont boldSystemFontOfSize:18];
		titleView.textColor = [UIColor whiteColor];
		self.navigationItem.titleView = titleView;
		[titleView release];
		[self setTitle:@"About Relay"];
		if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
			[self performSelector:@selector(setEdgesForExtendedLayout:) withObject:[NSNumber numberWithInt:0]];
		[self.view setBackgroundColor:[UIColor colorWithRed:53/255.0f green:53/255.0f blue:56/255.0f alpha:1.0f]];
		UIColor *lightText = [UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1.0f];
		UIColor *darkText = [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f];
		attributedString = [[NSMutableAttributedString alloc] initWithString:@"Relay 1.0\r\n\r\nBuilt by\r\nMax Shavrick\r\n\r\nDesigned by\r\nArron Hunt\r\n\r\nA thousand thanks to Fionn Kelleher, Guillermo Moran, James Matoe, Dustin Howett, James Long, Matthew, David Murray, Winocm, et al. Oh and everyone except Nolan!\r\n\r\nhttp://relayapp.com"];
		NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
		[style setAlignment:NSTextAlignmentCenter];
		[attributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [[attributedString string] length])];
		[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:20] range:NSMakeRange(0, 13)];
		[attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, 13)];
		[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] range:NSMakeRange(13, 8)];
		[attributedString addAttribute:NSForegroundColorAttributeName value:darkText range:NSMakeRange(13, 8)];
		[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:15] range:NSMakeRange(21, 14)];
		[attributedString addAttribute:NSForegroundColorAttributeName value:lightText range:NSMakeRange(21, 14)];
		[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] range:NSMakeRange(39, 11)];
		[attributedString addAttribute:NSForegroundColorAttributeName value:darkText range:NSMakeRange(39, 11)];
		[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:15] range:NSMakeRange(50, 11)];
		[attributedString addAttribute:NSForegroundColorAttributeName value:lightText range:NSMakeRange(50, 12)];
		[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] range:NSMakeRange(62, 165)];
		[attributedString addAttribute:NSForegroundColorAttributeName value:darkText range:NSMakeRange(62, 165)];
		[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:15] range:NSMakeRange(227, 23)];
		[attributedString addAttribute:NSForegroundColorAttributeName value:lightText range:NSMakeRange(227, 23)];
		[style release];
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	float iconWidth = 116.5;
	float iconHeight = 118.5;
	UIImage *icon = [UIImage imageNamed:@"about"];
	UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2 - (iconWidth / 2)), 17, iconWidth, iconHeight)];
	iconView.image = icon;
	[self.view addSubview:iconView];
	[iconView release];
	
	RCAboutInfoView *infos = [[RCAboutInfoView alloc] initWithFrame:CGRectMake(0, iconHeight + 50, 320, 280)];
	[infos setBackgroundColor:[UIColor colorWithRed:53/255.0f green:53/255.0f blue:56/255.0f alpha:1.0f]];
	[infos setAttributedString:attributedString];
	[attributedString release];
	[self.view addSubview:infos];
	[infos setNeedsDisplay];
	[infos release];
	titleView.text = @"About Relay";
	RCActionSheetButton *support = [[RCActionSheetButton alloc] initWithFrame:CGRectMake(21, self.view.frame.size.height - 60, self.view.frame.size.width - (2 * 21), 46) type:RCActionSheetButtonTypeNormal];
	[support addTarget:self action:@selector(joinIRCNodeAndConnectToSupportChannel) forControlEvents:UIControlEventTouchUpInside];
	[support setTitle:@"Get Support at #Relay" forState:UIControlStateNormal];
	[self.view addSubview:support];
	[support release];
}

- (void)joinIRCNodeAndConnectToSupportChannel {
	RCNetwork *net = [[RCNetwork alloc] init];
	[net setSDescription:@"IRCNode"];
	[net setServer:@"irc.ircnode.org"];
	[net setPort:6667];
	[net setUseSSL:NO];
	[net setSASL:NO];
	[net setUsername:@"SupportUser"];
	[net setRealname:@"SupportUser"];
	[net setNick:[NSString stringWithFormat:@"RelayUser%d", arc4random_uniform(200)]];
	[net setCOL:NO];
	[net setExpanded:YES];
	[net setupRooms:[NSArray arrayWithObjects:@"\x01IRC", @"#Relay", nil]];
	CFUUIDRef uRef = CFUUIDCreate(NULL);
	CFStringRef uStringRef = CFUUIDCreateString(NULL, uRef);
	CFRelease(uRef);
	[net setUUID:(NSString *)uStringRef];
	CFRelease(uStringRef);
	[[RCNetworkManager sharedNetworkManager] addNetwork:net];
	[net release];
	reloadNetworks();
	[net connect];
	[[RCChatController sharedController] selectChannel:@"#Relay" fromNetwork:net];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
