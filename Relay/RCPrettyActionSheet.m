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
		buttonView = [[RCActionSheetButtonView alloc] init];
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
	UILabel *titleLabel = [[UILabel alloc] init];
	CGSize size = [title sizeWithFont:[UIFont systemFontOfSize:12] minFontSize:10 actualFontSize:NULL forWidth:320 lineBreakMode:NSLineBreakByCharWrapping];
	[titleLabel setText:title];
	[titleLabel setFrame:CGRectMake(15, 8, screenSize.width - 30, size.height + 15)];
	[titleLabel setTextColor:[UIColor whiteColor]];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setFont:[UIFont systemFontOfSize:12]];
	[titleLabel setTextAlignment:NSTextAlignmentCenter];
	[titleLabel setShadowColor:[UIColor blackColor]];
	[titleLabel setShadowOffset:CGSizeMake(0, -1)];
	[buttonView addSubview:titleLabel];
	[titleLabel release];
	int y = -1;
	int padd = 7;
	int projectedHeight = 0;
	for (RCActionSheetButton *button in buttons) {
		y++;
		if (button.type == RCActionSheetButtonTypeCancel)
			padd = 10;
		else padd = 7;
		[button setFrame:CGRectMake(21, y * (46 + padd) + (titleLabel.frame.size.height + 10), screenSize.width - (2 * 21), 46)];
		[button setTag:y];
		[buttonView addSubview:button];
		projectedHeight = button.frame.origin.y + button.frame.size.height;
	}
	projectedHeight += 20;
	[buttonView setFrame:CGRectMake(0, screenSize.height - projectedHeight, screenSize.width, projectedHeight)];
	projectedOffset = buttonView.frame.origin.y - 20;
	[self setFrame:(CGRect){{0, (isiOS7 ? 20 : 0)}, screenSize}];
}

- (void)showInView:(UIView *)view {
	CGRect oldFrame = buttonView.frame;
	// do CALayer stuff here
	[buttonView setFrame:CGRectMake(0, view.frame.size.height, buttonView.frame.size.width, buttonView.frame.size.height)];
	CALayer *grayLayer = [[CALayer alloc] init];
	[grayLayer setFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
	[grayLayer setBackgroundColor:[UIColor colorWithWhite:0.115 alpha:0.740].CGColor];
	[grayLayer setZPosition:-1];
	[grayLayer setOpacity:0];
	[grayLayer setName:@"animationLayer"];
	[self.layer addSublayer:grayLayer];
	[grayLayer release];
	[view addSubview:self];
	CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fadeOutAnimation.fromValue = [NSNumber numberWithFloat:0.0];
	fadeOutAnimation.toValue = [NSNumber numberWithFloat:1.0];
	fadeOutAnimation.duration = 0.28;
	fadeOutAnimation.fillMode = kCAFillModeForwards;
	fadeOutAnimation.removedOnCompletion = NO;
	[grayLayer addAnimation:fadeOutAnimation forKey:@"opacity"];
	[UIView animateWithDuration:0.28 animations:^ {
		buttonView.frame = oldFrame;
	}];
}

- (void)dismissActionSheet {
	CGRect newFrame = CGRectMake(0, self.frame.size.height, buttonView.frame.size.width, buttonView.frame.size.height);
	CALayer *grayLayer = nil;
	for (CALayer *sb in self.layer.sublayers) {
		if ([[sb name] isEqualToString:@"animationLayer"]) {
			grayLayer = sb;
			break;
		}
	}
 	CABasicAnimation *fadeOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	fadeOutAnimation.fromValue = [NSNumber numberWithFloat:1.0];
	fadeOutAnimation.toValue = [NSNumber numberWithFloat:0.0];
	fadeOutAnimation.duration = 0.25;
	fadeOutAnimation.fillMode = kCAFillModeForwards;
	fadeOutAnimation.removedOnCompletion = NO;
	[grayLayer addAnimation:fadeOutAnimation forKey:@"opacity"];
	[UIView animateWithDuration:0.25 animations:^ {
		buttonView.frame = newFrame;
	} completion:^ (BOOL comp) {
		[self removeFromSuperview];
	}];
}

- (void)dealloc {
	[title release];
	[delegate release];
	[buttons release];
	[super dealloc];
}

@end
