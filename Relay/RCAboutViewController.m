//
//  RCAboutViewController.m
//  Relay
//
//  Created by Fionn Kelleher on 15/08/2013.
//  Copyright (c) 2013 American Heritage School. All rights reserved.
//

#import "RCAboutViewController.h"

@interface RCAboutViewController ()

@end

@implementation RCAboutViewController

- (id)init {
    self = [super init];
    if (self) {
        [self setTitle:@"About Relay"];
        [self.view setBackgroundColor:[UIColor colorWithRed:53/255.0f green:53/255.0f blue:56/255.0f alpha:1.0f]];
    }
    return self;
}

- (void)viewDidLoad {
    float iconWidth = 116.5;
    float iconHeight = 118.5;
    
    UIColor *lightText = [UIColor colorWithRed:204/255.0f green:204/255.0f blue:204/255.0f alpha:1.0f];
    UIColor *darkText = [UIColor colorWithRed:83/255.0f green:83/255.0f blue:85/255.0f alpha:1.0f];
    
    [super viewDidLoad];
    UIImage *icon = [UIImage imageNamed:@"about"];
	UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2 - (iconWidth / 2)), 17, iconWidth, iconHeight)];
    iconView.image = icon;
    [self.view addSubview:iconView];
    
    UILabel *appName = [[UILabel alloc] initWithFrame:CGRectMake(0, iconView.frame.origin.x + 60, self.view.frame.size.width, 30)];
    [appName setText:@"Relay 1.0"];
    [appName setTextAlignment:NSTextAlignmentCenter];
    [appName setBackgroundColor:[UIColor clearColor]];
    [appName setTextColor:[UIColor whiteColor]];
    [appName setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:20]];
    [self.view addSubview:appName];
    
    UILabel *builtBy = [[UILabel alloc] initWithFrame:CGRectMake(0, iconView.frame.origin.x + 100, self.view.frame.size.width, 30)];
    [builtBy setText:@"Built by"];
    [builtBy setTextAlignment:NSTextAlignmentCenter];
    [builtBy setBackgroundColor:[UIColor clearColor]];
    [builtBy setTextColor:darkText];
    [builtBy setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    [self.view addSubview:builtBy];
    
    UILabel *devNames = [[UILabel alloc] initWithFrame:CGRectMake(0, iconView.frame.origin.x + 118, self.view.frame.size.width, 30)];
    [devNames setText:@"Max Shavrick"];
    [devNames setTextAlignment:NSTextAlignmentCenter];
    [devNames setBackgroundColor:[UIColor clearColor]];
    [devNames setTextColor:lightText];
    [devNames setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
    [self.view addSubview:devNames];
    
    UILabel *designedBy = [[UILabel alloc] initWithFrame:CGRectMake(0, iconView.frame.origin.x + 146, self.view.frame.size.width, 30)];
    [designedBy setText:@"Designed by"];
    [designedBy setTextAlignment:NSTextAlignmentCenter];
    [designedBy setBackgroundColor:[UIColor clearColor]];
    [designedBy setTextColor:darkText];
    [designedBy setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    [self.view addSubview:designedBy];
    
    UILabel *designerNames = [[UILabel alloc] initWithFrame:CGRectMake(0, iconView.frame.origin.x + 166, self.view.frame.size.width, 30)];
    [designerNames setText:@"Arron Hunt"];
    [designerNames setTextAlignment:NSTextAlignmentCenter];
    [designerNames setBackgroundColor:[UIColor clearColor]];
    [designerNames setTextColor:lightText];
    [designerNames setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
    [self.view addSubview:designerNames];
    
    UILabel *dontSendComplaintsToFudge = [[UILabel alloc] initWithFrame:CGRectMake(10, iconView.frame.origin.x + 206, self.view.frame.size.width - 10, 60)];
    [dontSendComplaintsToFudge setText:@"Do you have questions or want to complain? Contact Fionn Kelleher, it's probably his fault."];
    [dontSendComplaintsToFudge setNumberOfLines:0];
    [dontSendComplaintsToFudge setTextAlignment:NSTextAlignmentCenter];
    [dontSendComplaintsToFudge setBackgroundColor:[UIColor clearColor]];
    [dontSendComplaintsToFudge setTextColor:darkText];
    [dontSendComplaintsToFudge setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    [self.view addSubview:dontSendComplaintsToFudge];
    
    UILabel *url = [[UILabel alloc] initWithFrame:CGRectMake(10, iconView.frame.origin.x + 276, self.view.frame.size.width - 10, 30)];
    [url setText:@"http://relayapp.com"];
    [url setTextAlignment:NSTextAlignmentCenter];
    [url setBackgroundColor:[UIColor clearColor]];
    [url setTextColor:lightText];
    [url setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
    [self.view addSubview:url];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
