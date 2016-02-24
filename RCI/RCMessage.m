//
//  RCMessage.m
//  Relay
//
//  Created by Max Shavrick on 7/18/13.
//

#import "RCMessage.h"
#import "RCI.h"

@implementation RCMessage {
	NSString *_givenMessage;
	NSArray *_arguments;
}
@synthesize messageTags=_messageTags, sender=_sender, numeric=_numeric, destination=_destination, message=_message, messageType=_messageType;

- (id)initWithString:(NSString *)string {
	if ((self = [super init])) {
		_givenMessage = [string retain];
		if ([_givenMessage characterAtIndex:0] == '@') {
			[self parseIRCV3MessageTags];
		}
		self.messageType = RCMessageTypeUnknown;
	}
	return self;
}

- (void)parse {
	NSString *localMessage = _givenMessage;
	BOOL isNormalMessage = NO;
	if ([_givenMessage characterAtIndex:0] == ':') {
		localMessage = [_givenMessage substringFromIndex:1];
		isNormalMessage = YES;
	}
	
	NSMutableArray *arguments = [NSMutableArray array];
	NSString *dataSegment = nil;
	
	NSArray *components = [localMessage componentsSeparatedByString:@" "];
	for (int argIndex = 0; argIndex < [components count]; argIndex++) {
		
		NSString *string = components[argIndex];
		if ([string hasPrefix:@":"]) {
			dataSegment = [[components subarrayWithRange:NSMakeRange(argIndex, [components count] - argIndex)] componentsJoinedByString:@" "];
			break;
		}
		else {
			[arguments addObject:components[argIndex]];
		}
	}
	if (isNormalMessage) {
		if ([arguments count] > 1) {
			self.sender = [arguments objectAtIndex:0];
			self.numeric = [arguments objectAtIndex:1];
		}
		if ([arguments count] > 2) {
			self.destination = [arguments objectAtIndex:2];
		}
	}
	else {
		self.numeric = [arguments objectAtIndex:0];
	}
	_arguments = [arguments retain];
	self.message = [dataSegment substringFromIndex:1];
#warning ASSIGN self.messageType HERE !!!!!
}

- (void)parseIRCV3MessageTags {
	// this logic is kind of flawed.
	// not the code, but storing it
	// whatever. i'll fix it when it needs to be.
	NSRange range = [_givenMessage rangeOfString:@" :"];
	if (range.location != NSNotFound) {
		// naming for historical purposes.
		NSString *superImportantMessage = [_givenMessage substringWithRange:NSMakeRange(range.location, _givenMessage.length - range.location)];
		NSString *messageTags = [_givenMessage substringWithRange:NSMakeRange(0, range.location)];
		if ([superImportantMessage hasPrefix:@" "])
			superImportantMessage = [superImportantMessage substringFromIndex:1];
		
		self.messageTags = [self serializeTagsFromString:messageTags];
#if LOGALL
		NSLog(@"IRCV3 Tags %@", tagsDictionary);
#endif
		[_givenMessage release];
		_givenMessage = [superImportantMessage retain];
	}
}

- (NSDictionary *)serializeTagsFromString:(NSString *)string {
	NSArray *tagString = [string componentsSeparatedByString:@";"];
	NSMutableDictionary *tagsDictionary = [[NSMutableDictionary alloc] init];
	for (NSString *tag in tagString) {
		NSArray *flags = [tag componentsSeparatedByString:@"="];
		if ([flags count] == 1) {
#if LOGALL
			NSLog(@"IRCV3 NOT HANDLING [%@:TRUE]", tag);
#endif
			[tagsDictionary setObject:(id)kCFBooleanTrue forKey:[flags objectAtIndex:0]];
		}
		else {
			// setup dictionary mapping so can switch/case
			NSString *key = [flags objectAtIndex:0];
			if ([key isEqualToString:@"time"]) {
				//	NSString *properTime = [[RCDateManager sharedInstance] properlyFormattedTimeFromISO8601DateString:[flags objectAtIndex:1]];
				NSString *iso8601time = [flags objectAtIndex:1];
				[tagsDictionary setObject:iso8601time forKey:@"time"];
				continue;
			}
			else {
#if LOGALL
				NSLog(@"IRCV3 NOT HANDLING [%@:%@]", [flags objectAtIndex:0], [flags objectAtIndex:1]);
#endif
				[tagsDictionary setObject:[flags objectAtIndex:1] forKey:[flags objectAtIndex:0]];
			}
		}
	}
	return [tagsDictionary autorelease];
}

- (id)parameterAtIndex:(int)index {
	if (!_arguments) return self.message;
	if ([_arguments count] <= index) {
		NSLog(@"Please report this data to Maximus:");
		NSLog(@"<Sender = [%@]; Numeric = [%@]; Message = [%@]>", self.sender, self.numeric, self.message);
		NSLog(@"Requesting param %d in an array of %ld elements.", index - 1, [_arguments count]);
		return @"IF YOU SEE THIS, CHECK YOUR SYSTEM LOG.";
	}
	return [_arguments objectAtIndex:index];
}

- (id)description {
	return [@[(self.messageTags ? self.messageTags : [NSNull null]), (self.sender ? self.sender : [NSNull null]), (self.numeric ? self.numeric: @"-1"), (self.message ? self.message: @"no message?")] description];
}

- (void)dealloc {
	[_arguments release];
	self.messageTags = nil;
	self.destination = nil;
	self.message = nil;
	self.numeric = nil;
	self.sender = nil;
	[super dealloc];
}

@end
