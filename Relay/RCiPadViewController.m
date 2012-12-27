//
//  RCiPadViewController.m
//  Relay
//
//  Created by Max Shavrick on 3/24/12.
//

#import "RCiPadViewController.h"

@implementation RCiPadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	UILabel *ffs = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 300)];
	[ffs setText:@"hihi"];
	[self.view addSubview:ffs];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
