//
//  RCAboutViewController.m
//  Relay
//
//  Created by Fionn Kelleher on 15/08/2013.
//

#import "RCAboutViewController.h"

@implementation RCAboutViewController

- (id)init {
	if ((self = [super init])) {
		[self setTitle:@"About Relay"];
        if (isiOS7)
            self.edgesForExtendedLayout = UIRectEdgeNone;
		[self.view setBackgroundColor:[UIColor colorWithRed:53/255.0f green:53/255.0f blue:56/255.0f alpha:1.0f]];
		UIColor *lightText = [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f];
		UIColor *darkText = [UIColor colorWithRed:83/255.0f green:83/255.0f blue:85/255.0f alpha:1.0f];
		attributedString = [[NSMutableAttributedString alloc] initWithString:@"Relay 1.0\r\n\r\nBuilt by\r\nMax Shavrick\r\n\r\nDesigned by\r\nArron Hunt\r\n\r\nDo you have questions or want to complain?\r\nContact Fionn Kelleher, it's probably his fault.\r\n\r\n\r\nhttp://relayapp.com"];
		NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
		[style setAlignment:NSTextAlignmentCenter];
		[attributedString addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, [[attributedString string] length])];
		[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:20] range:NSMakeRange(0, 13)];
		[attributedString addAttribute:NSForegroundColorAttributeName value:lightText range:NSMakeRange(0, 13)];
		[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] range:NSMakeRange(13, 8)];
		[attributedString addAttribute:NSForegroundColorAttributeName value:darkText range:NSMakeRange(13, 8)];
		[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:15] range:NSMakeRange(21, 14)];
		[attributedString addAttribute:NSForegroundColorAttributeName value:lightText range:NSMakeRange(21, 14)];
		[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] range:NSMakeRange(39, 11)];
		[attributedString addAttribute:NSForegroundColorAttributeName value:darkText range:NSMakeRange(39, 11)];
		[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:15] range:NSMakeRange(50, 11)];
		[attributedString addAttribute:NSForegroundColorAttributeName value:lightText range:NSMakeRange(50, 12)];
		[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:14] range:NSMakeRange(62, 96)];
		[attributedString addAttribute:NSForegroundColorAttributeName value:darkText range:NSMakeRange(62, 96)];
		[attributedString addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"HelveticaNeue-Light" size:15] range:NSMakeRange(158, 25)];
		[attributedString addAttribute:NSForegroundColorAttributeName value:lightText range:NSMakeRange(158, 25)];
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
	
	CGFloat offy = (iconView.frame.origin.y + iconView.frame.size.height + 28);
	CGFloat boxHeight = self.view.frame.size.height - offy;
	CGFloat yPos = offy + (boxHeight/2 - 140);
	RCAboutInfoView *infos = [[RCAboutInfoView alloc] initWithFrame:CGRectMake(0, yPos, 320, 280)];
	[infos setBackgroundColor:[UIColor colorWithRed:53/255.0f green:53/255.0f blue:56/255.0f alpha:1.0f]];
	[infos setAttributedString:attributedString];
	[attributedString release];
	[self.view addSubview:infos];
	[infos setNeedsDisplay];
	[infos release];
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
