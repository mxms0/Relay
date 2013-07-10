//
//  NSData+Instance.m
//  Relay
//
//  Created by Max Shavrick on 7/10/13.
//

#import "NSData+Instance.h"

@implementation NSData (RCNewLineSet)

static id _existingSet = nil;

+ (id)nlCharacterDataSet {
	if (!_existingSet) _existingSet = [[NSData dataWithBytes:"\r\n" length:2] retain];
	return _existingSet;
}

@end
