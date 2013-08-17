//
//  RCPrettyActionSheet.m
//  Relay
//
//  Created by Max Shavrick on 10/20/12.
//

#import "RCPrettyActionSheet.h"

@implementation RCPrettyActionSheet

- (id)initWithTitle:(NSString *)_title delegate:(id <UIActionSheetDelegate>)_delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
	if ((self = [super init])) {
		[self setBackgroundColor:[UIColor clearColor]];
		delegate = [_delegate retain];
		buttons = [[NSMutableArray alloc] init];
		title = [_title retain];
		buttonView = [[UIView alloc] init];
		[self addSubview:buttonView];
		if (otherButtonTitles) {
			RCActionSheetButton *firstOtherButton = [self standardActionSheetButtonWithType:RCActionSheetButtonTypeNormal andTitle:otherButtonTitles];
			[buttons addObject:firstOtherButton];
			id aTitle;
			va_list argList;
			va_start(argList, otherButtonTitles);
			while ((aTitle = va_arg(argList, id))) {
				RCActionSheetButton *button = [self standardActionSheetButtonWithType:RCActionSheetButtonTypeNormal andTitle:aTitle];
				[buttons addObject:button];
			}
			va_end(argList);
		}
		if (cancelButtonTitle) {
			RCActionSheetButton *button = [self standardActionSheetButtonWithType:RCActionSheetButtonTypeCancel andTitle:cancelButtonTitle];
			[buttons addObject:button];
		}
		if (destructiveButtonTitle) {
			RCActionSheetButton *button = [self standardActionSheetButtonWithType:RCActionSheetButtonTypeDestructive andTitle:destructiveButtonTitle];
			[buttons insertObject:button atIndex:0];
		}
		[self layoutButtons];
	}
	return self;
}

- (RCActionSheetButton *)standardActionSheetButtonWithType:(RCActionSheetButtonType)typ andTitle:(NSString *)_title {
	RCActionSheetButton *button = [[RCActionSheetButton alloc] initWithFrame:CGRectZero type:typ];
	[button setTitle:_title forState:UIControlStateNormal];
	[button addTarget:self action:@selector(generalButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	return [button autorelease];
}

- (void)generalButtonTapped:(RCActionSheetButton *)btn {
	[self dismissActionSheet];
	[delegate actionSheet:(UIActionSheet *)self clickedButtonAtIndex:btn.tag];
}

- (void)layoutButtons {
	for (UIView *v in [[[buttonView subviews] copy] autorelease]) {
		[v removeFromSuperview];
	}
	CGSize screenSize = [[UIScreen mainScreen] applicationFrame].size;
	int y = -1;
	int padd = 7;
	int projectedHeight = 0;
	for (RCActionSheetButton *button in buttons) {
		y++;
		if (button.type == RCActionSheetButtonTypeCancel)
			padd = 10;
		else padd = 7;
		[button setFrame:CGRectMake(21, y * (46 + padd), screenSize.width - (2 * 21), 46)];
		[button setTag:y];
		[buttonView addSubview:button];
		projectedHeight = (y * (46 + padd)) + 46;
	}
	[buttonView setFrame:CGRectMake(0, (screenSize.height - 20) - projectedHeight, screenSize.width, projectedHeight)];
	UILabel *titleLabel = [[UILabel alloc] init];
	CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:12] minFontSize:10 actualFontSize:NULL forWidth:320 lineBreakMode:NSLineBreakByCharWrapping];
	[titleLabel setText:title];
	[titleLabel setFrame:CGRectMake(15, buttonView.frame.origin.y - (size.height + 10), screenSize.width - 30, size.height)];
	[titleLabel setTextColor:[UIColor whiteColor]];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setFont:[UIFont systemFontOfSize:12]];
	[titleLabel setTextAlignment:NSTextAlignmentCenter];
	[titleLabel setShadowColor:[UIColor blackColor]];
	[titleLabel setShadowOffset:CGSizeMake(0, -1)];
	[self addSubview:titleLabel];
	[titleLabel release];
	projectedOffset = titleLabel.frame.origin.y - 15;
	[self setFrame:(CGRect){{0,0}, screenSize}];
}

- (void)showInView:(UIView *)view {
	// do CALayer stuff here
	[view addSubview:self];
}

- (void)dismissActionSheet {
	[self removeFromSuperview];
	[self release];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	[[UIColor colorWithRed:43/255.0f green:43/255.0f blue:46/255.0f alpha:1.0f] set];
	UIRectFill(CGRectMake(0, projectedOffset, rect.size.width, rect.size.height));
	UIImage *img = [UIImage imageNamed:@"action_sheet_top_gloss"];
	[img drawInRect:CGRectMake(0, projectedOffset, rect.size.width, img.size.height)];
}

- (void)dealloc {
	[title release];
	[delegate release];
	[buttons release];
	[super dealloc];
}

@end
