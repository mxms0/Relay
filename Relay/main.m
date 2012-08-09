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
+ (id)deleteImage;
+ (id)insertImage;
- (void)blank;
+ (id)nullRet;
- (void)_setRotated:(BOOL)rotated animated:(BOOL)animated;
@end
@implementation RCSpecialClass
+ (id)deleteImage {
	return [UIImage imageNamed:@"0_tminusbtn"];
}
+ (id)insertImage {
	return [UIImage imageNamed:@"0_tplusbtn"];
}
- (void)blank {}
- (void)_setRotated:(BOOL)rotated animated:(BOOL)animated { }
@end


int main(int argc, char *argv[]) {
	@autoreleasepool {
		Method origm = class_getClassMethod([objc_getClass("UITableViewCellEditControl") class], @selector(_deleteImage));
		Method newFF = class_getClassMethod([RCSpecialClass class], @selector(deleteImage));
		method_exchangeImplementations(origm, newFF);
		Method fmd = class_getClassMethod([objc_getClass("UITableViewCellEditControl") class], @selector(_insertImage));
		Method lvfg = class_getClassMethod([RCSpecialClass class], @selector(insertImage));
		method_exchangeImplementations(fmd, lvfg);
		Method rgvf = class_getClassMethod([objc_getClass("UITableViewCellEditControl") class], @selector(_updateImageView));
		Method dkv = class_getClassMethod([RCSpecialClass class], @selector(blank));
		method_exchangeImplementations(rgvf, dkv);
		Method sc = class_getClassMethod([objc_getClass("UITableViewCellEditControl") class], @selector(_toggleRotate));
		Method gd = class_getClassMethod([RCSpecialClass class], @selector(blank));
		method_exchangeImplementations(sc, gd);
		Method scd = class_getClassMethod([objc_getClass("UITableViewCellEditControl") class], @selector(setRotated:animated:));
		Method gdd = class_getClassMethod([RCSpecialClass class], @selector(_setRotated:animated:));
		method_exchangeImplementations(scd, gdd);
		Method sfscd = class_getClassMethod([objc_getClass("UITableViewCellEditControl") class], @selector(_multiselectColorChanged));
		Method gdsad = class_getClassMethod([RCSpecialClass class], @selector(blank));
		method_exchangeImplementations(sfscd, gdsad);
		
	    return UIApplicationMain(argc, argv, nil, NSStringFromClass([RCAppDelegate class]));
	}
}
