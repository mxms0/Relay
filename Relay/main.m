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

int main(int argc, char *argv[]) {
	@autoreleasepool {		
	    return UIApplicationMain(argc, argv, nil, NSStringFromClass([RCAppDelegate class]));
	}
}
