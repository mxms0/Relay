//
//  RCDateManager.m
//  Relay
//
//  Created by Max Shavrick on 7/16/12.
//

#import "RCDateManager.h"

@implementation RCDateManager
static id _dManager = nil;
- (id)init {
	if ((self = [super init])) {
		formatter = [[NSDateFormatter alloc] init];
		formatter.dateStyle = NSDateFormatterNoStyle;
		formatter.PMSymbol = @"";
		formatter.AMSymbol = @"";
		formatter.timeStyle = NSDateFormatterShortStyle;
	}
	_dManager = self;
	return _dManager;
}

+ (id)sharedInstance {
	if (!_dManager) [[self alloc] init];
	return _dManager;
}

- (NSString *)currentDateAsString {
	return [formatter stringFromDate:[NSDate date]];
}

@end
