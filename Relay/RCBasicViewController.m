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
	if ((self = [super initWithStyle:UITableViewStylePlain])) {
		titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 40)];
		titleView.backgroundColor = [UIColor clearColor];
		titleView.textAlignment = UITextAlignmentCenter;
		titleView.font = [UIFont boldSystemFontOfSize:18];
		titleView.textColor = [UIColor whiteColor];
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
	self.view.backgroundColor = [UIColor colorWithRed:43/255.0f green:43/255.0f blue:46/255.0f alpha:1.0f];
	self.tableView.backgroundView.backgroundColor = [UIColor colorWithRed:43/255.0f green:43/255.0f blue:46/255.0f alpha:1.0f];
	self.tableView.backgroundColor = [UIColor colorWithRed:43/255.0f green:43/255.0f blue:46/255.0f alpha:1.0f];
	self.tableView.separatorColor = [UIColor colorWithRed:43/255.0f green:43/255.0f blue:46/255.0f alpha:1.0f];
	titleView.text = [self titleText];
}

- (void)backButtonTapped:(id)of {
	[self.navigationController popViewControllerAnimated:YES];	
}

- (void)setupDoneButton {
	UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(edit)];	
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
}

@end
