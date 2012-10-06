//
//  RCBasicTableViewCell.m
//  Relay
//
//  Created by Max Shavrick on 8/7/12.
//

#import "RCBasicTableViewCell.h"

@implementation RCBasicTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)ident {
	if ((self = [super initWithStyle:style reuseIdentifier:ident])) {
		self.textLabel.backgroundColor = [UIColor clearColor];
		[self setOpaque:YES];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.textLabel.font = [UIFont boldSystemFontOfSize:14];
		self.textLabel.textColor = UIColorFromRGB(0x545758);
        transform = 0;
        // Initialization code
    }
    return self;
}

- (void)addSubview:(UIView *)view {
	if ([view isKindOfClass:[objc_getClass("UITableViewCellEditControl") class]]) {
		for (UIView *suv in [view subviews]) {
			if ([suv isKindOfClass:[UIImageView class]]) {
                suv.tag = 500;
                [suv setFrame:CGRectMake(7, 8, suv.frame.size.height, suv.frame.size.width)];
				UIImage *gg = [UIImage imageNamed:@"0_tplusbtn"];
				if (self.editingStyle == UITableViewCellEditingStyleDelete)
					gg = [UIImage imageNamed:@"0_tminusbtn"];
				[(UIImageView *)suv setImage:gg];
				break;
			}
		}
	}
	[super addSubview:view];
}

- (void)willTransitionToState:(UITableViewCellStateMask)state {
    [super willTransitionToState:state];
	if (_state == state) return;
    if (state == 1) {
        for (UIView *subv in [self subviews]) {
            if ([subv isKindOfClass:[objc_getClass("UITableViewCellEditControl") class]]) {
				if (![self showingDeleteConfirmation])
					transform = 0;
				if (self.editingStyle == UITableViewCellEditingStyleInsert) return;
                [UIView beginAnimations:nil context:nil];
                [[self viewWithTag:500] setTransform:CGAffineTransformMakeRotation(-transform)];
                [UIView commitAnimations];
				
                if ((int)transform == (int)(M_PI/2)) {
                    transform = 0;
                }
                else {
				 	transform = (M_PI/2);
                }
                break;
            }
        }
    }
	_state = state;
}
#if USE_PRIVATE
- (void)editControlWasClicked:(id)arg1 {
    [super editControlWasClicked:arg1];
	if (self.editingStyle == UITableViewCellEditingStyleInsert) return;
    [UIView beginAnimations:nil context:nil];
    [[self viewWithTag:500] setTransform:CGAffineTransformMakeRotation(-transform)];
    [UIView commitAnimations];
    if ((int)transform == (int)(M_PI/2)) {
        transform = 0;
    }
    else {
        transform = (M_PI/2);
    }
}
#endif

@end
