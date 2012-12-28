//
//  RCBasicViewController.m
//  Relay
//
//  Created by Max Shavrick on 7/1/12.
//

#import "RCBasicViewController.h"

@implementation UIView (FindAndResignFirstResponder)
- (BOOL)findAndResignFirstResponder {
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;
    }
    for (UIView *subView in self.subviews) {
        if ([subView findAndResignFirstResponder])
            return YES;
    }
    return NO;
}
@end

@implementation RCBasicViewController

- (id)initWithStyle:(UITableViewStyle)style {
	if ((self = [super initWithStyle:style])) {
		titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 40)];
		titleView.backgroundColor = [UIColor clearColor];
		titleView.textAlignment = UITextAlignmentCenter;
		titleView.font = [UIFont boldSystemFontOfSize:22];
		titleView.shadowColor = [UIColor whiteColor];
		titleView.textColor = UIColorFromRGB(0x424343);
		titleView.shadowOffset = CGSizeMake(0, 1);
		self.navigationItem.titleView = titleView;
		[titleView release];
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (section == 0) return 35.0;
	return 25.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 240, 20)];
	label.text = [self tableView:tableView titleForHeaderInSection:section];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor whiteColor];
	label.shadowColor = [UIColor blackColor];
	label.shadowOffset = CGSizeMake(0, 1);
	label.font = [UIFont boldSystemFontOfSize:14];
	return [label autorelease];
}

- (NSString *)titleText {
	return @"An error occured.";
}

- (void)viewDidLoad {
    [super viewDidLoad];
	UIImageView *bg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"0_bg"]];
	[bg setFrame:self.view.frame];
	self.tableView.backgroundView = bg;
	[bg release];
	titleView.text = [self titleText];
}

- (void)backButtonTapped:(id)of {
	[self.navigationController popViewControllerAnimated:YES];	
}

- (void)setupDoneButton {
	UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(edit)];
	[doneBtn setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:UIColorFromRGB(0xf7f7f7), UITextAttributeTextColor, [UIFont boldSystemFontOfSize:11],UITextAttributeFont, (CGSize){0,1},UITextAttributeTextShadowOffset, nil] forState:UIControlStateNormal];	
	[doneBtn setTitlePositionAdjustment:UIOffsetMake(0, 0.5) forBarMetrics:UIBarMetricsDefault];
	
	[doneBtn setBackgroundImage:[[UIImage imageNamed:@"0_navbtn_d"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	[doneBtn setBackgroundImage:[[UIImage imageNamed:@"0_navbtn_dp"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
	
	[self.navigationItem setRightBarButtonItem:doneBtn];
	[doneBtn release];
}

- (void)setupEditButton {
	UIBarButtonItem *editBtn = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(edit)];
	[self.navigationItem setRightBarButtonItem:editBtn];
	[editBtn release];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotate {
	return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	float y = 44;
	float width = 320;
	if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
		y = 32; width = 480;
	}
	for (UIView *subvc in [self.navigationController.navigationBar subviews]) {

		if ([subvc isKindOfClass:[UIImageView class]]) {
			subvc.frame = CGRectMake(0, y, width, 10);
			break;
		}
	}
	r_shadow.frame = CGRectMake(0, y, width, 10);
}

@end
