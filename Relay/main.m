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

static id _RCSpecialBackgroundImage(Class self, SEL _cmd) {
	return [[UIImage imageNamed:@"0_removebtn"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
}

static id _RCSpecialHighlightedBackgroundImage(Class self, SEL _cmd) {
	return [[UIImage imageNamed:@"0_removebtnpres"] stretchableImageWithLeftCapWidth:5 topCapHeight:5];
}

int main(int argc, char **argv) {
    Class deleteControl = objc_getMetaClass("_UITableViewCellDeleteConfirmationControl");
    
    Method bgOrig = class_getClassMethod(deleteControl, @selector(_backgroundImage));
    method_setImplementation(bgOrig, (IMP)_RCSpecialBackgroundImage);
    
    Method hiOrig = class_getClassMethod(deleteControl, @selector(_highlightedBackgroundImage));
    method_setImplementation(hiOrig, (IMP)_RCSpecialHighlightedBackgroundImage);
    
    @autoreleasepool {
	    return UIApplicationMain(argc, argv, nil, @"RCAppDelegate");
	}
}