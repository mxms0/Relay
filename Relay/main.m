//
//  main.m
//  Relay
//
//  Created by Max Shavrick on 1/13/12.
//

#import <UIKit/UIKit.h>
#import "RCAppDelegate.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface RCSpecialClass : NSObject 
+ (id)backgroundImage;
+ (id)_pBackgroundImage;
- (void)drawBackground;
@end
@implementation RCSpecialClass
+ (id)backgroundImage {
	return [[UIImage imageNamed:@"0_removebtn"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
}
+ (id)_pBackgroundImage {
	return [[UIImage imageNamed:@"0_removebtnpres"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
}
- (void)drawBackground {
	BOOL selected = (BOOL)[self performSelector:@selector(pressed)];
	UIImage *img = nil;
	if (selected) {
		img = [[UIImage imageNamed:@"0_navback_press"] stretchableImageWithLeftCapWidth:13 topCapHeight:3];
	}
	else {
		img = [[UIImage imageNamed:@"0_navback"] stretchableImageWithLeftCapWidth:13 topCapHeight:3];
	}
	[img drawInRect:CGRectMake(0, 0, ((UIView *)self).frame.size.width, ((UIView *)self).frame.size.height)];
}
@end


int main(int argc, char *argv[]) {
	Method orig = class_getClassMethod([objc_getClass("_UITableViewCellDeleteConfirmationControl") class], @selector(_backgroundImage));
	Method rep = class_getClassMethod([RCSpecialClass class], @selector(backgroundImage));
	method_exchangeImplementations(orig, rep);
	Method orig2 = class_getClassMethod([objc_getClass("_UITableViewCellDeleteConfirmationControl") class], @selector(_highlightedBackgroundImage));
	Method rep2 = class_getClassMethod([RCSpecialClass class], @selector(_pBackgroundImage));
	method_exchangeImplementations(orig2, rep2);
	Method ra = class_getInstanceMethod([objc_getClass("UINavigationItemButtonView") class], @selector(_drawBackground));
	Method fd = class_getInstanceMethod([RCSpecialClass class], @selector(drawBackground));
	method_exchangeImplementations(ra, fd);
	@autoreleasepool {
	    return UIApplicationMain(argc, argv, nil, NSStringFromClass([RCAppDelegate class]));
	}
}