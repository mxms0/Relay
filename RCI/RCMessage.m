//
//  RCMessage.m
//  Relay
//
//  Created by Max Shavrick on 7/18/13.
//

#import "RCMessage.h"

@implementation RCMessage
@synthesize tags, sender, numeric;

- (id)initWithString:(NSString *)string {
	if ((self = [super init])) {
		message = [string retain];
		if ([string characterAtIndex:0] == '@') {
			[self parseIRCV3MessageTags];
		}
	}
	return self;
}

- (void)parse {
	NSScanner *scanner = [[NSScanner alloc] initWithString:message];
	NSString *message_ = nil;
	NSString *sender_ = nil;
	NSString *numeric_ = nil;
	[scanner scanUpToString:@" " intoString:&sender_];
	[scanner scanUpToString:@" " intoString:&numeric_];
	[scanner scanUpToString:@"" intoString:&message_];
	if ([message_ hasPrefix:@":"]) {
		message_ = [message_ substringFromIndex:1];
	}
	else {
		NSMutableArray *comps = [[[message_ componentsSeparatedByString:@" "] mutableCopy] autorelease];
		NSMutableArray *properComponents = [[NSMutableArray alloc] init];
		for (int i = 0; i < [comps count]; i++) {
			NSString *cmp = [comps objectAtIndex:i];
			if (![cmp hasPrefix:@":"]) {
				[properComponents addObject:cmp];
			}
			else {
				NSArray *subArray = [comps subarrayWithRange:NSMakeRange(i, [comps count] - i)];
				NSString *compose = [[subArray componentsJoinedByString:@" "] substringFromIndex:1];
				[properComponents addObject:compose];
				break;
			}
		}
		messageParameters = [properComponents retain];
		[properComponents release];
	}
	if ([sender_ hasPrefix:@":"])
		sender_ = [sender_ substringFromIndex:1];
	self.sender = sender_;
	self.numeric = numeric_;
	[message release];
	message = [message_ retain];
	[scanner release];
}

- (void)parseIRCV3MessageTags {
	// this logic is kind of flawed.
	// not the code, but storing it
	// whatever. i'll fix it when it needs to be.
	NSRange range = [message rangeOfString:@" :"];
	if (range.location != NSNotFound) {
		// naming for historical purposes.
		NSString *superImportantMessage = [message substringWithRange:NSMakeRange(range.location, message.length - range.location)];
		NSString *messageTags = [message substringWithRange:NSMakeRange(0, range.location)];
		if ([superImportantMessage hasPrefix:@" "])
			superImportantMessage = [superImportantMessage substringFromIndex:1];
		NSArray *tagString = [messageTags componentsSeparatedByString:@";"];
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
#if LOGALL
		NSLog(@"IRCV3 Tags %@", tagsDictionary);
#endif
		self.tags = tagsDictionary;
		[tagsDictionary release];
		[message release];
		message = [superImportantMessage retain];
	}
}

- (id)parameterAtIndex:(int)index {
	if (!messageParameters) return message;
	if ([messageParameters count] <= index) {
		NSLog(@"Please report this data to Maximus:");
		NSLog(@"<Sender = [%@]; Numeric = [%@]; Message = [%@]>", sender, numeric, message);
		NSLog(@"Requesting param %d in an array of %ld elements.", index - 1, [messageParameters count]);
		return @"IF YOU SEE THIS, CHECK YOUR SYSTEM LOG.";
	}
	return [messageParameters objectAtIndex:index];
}

- (id)description {
	return [@[(tags ?: [NSNull null]), (sender ?: [NSNull null]), (numeric ?: @"-1"), (message ?: @"wat, no message?")] description];
}

- (void)dealloc {
	[messageParameters release];
	[tags release];
	[message release];
	[numeric release];
	[sender release];
	[super dealloc];
}

@end