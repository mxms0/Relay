//
//  RCDateManager.m
//  Relay
//
//  Created by Max Shavrick on 7/16/12.
//

#import "RCDateManager.h"
#import "RCNetworkManager.h"

@implementation RCDateManager
static id _dManager = nil;

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dateFormatChanged) name:SETTINGS_CHANGED_KEY object:nil];
		formatter = [[NSDateFormatter alloc] init];
		formatter.dateStyle = NSDateFormatterNoStyle;
		formatter.PMSymbol = @"";
		formatter.AMSymbol = @"";
		formatter.dateFormat = @"hh:mm";
		// :ss for seconds
		// HH for 24 hour time
		[formatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"] autorelease]];
		[formatter setTimeZone:[NSTimeZone localTimeZone]];
		eightsixohoneformatter = [[ISO8601DateFormatter alloc] init];
	}
	_dManager = self;
	return _dManager;
}

+ (id)sharedInstance {
	if (!_dManager) [[self alloc] init];
	return _dManager;
}

- (void)dateFormatChanged {
	NSString *hour = @"hh";
	NSString *seconds = @"";
	BOOL twentyFourHour = [[[RCNetworkManager sharedNetworkManager] valueForSetting:TWENTYFOURHOURTIME_KEY] boolValue];
	BOOL useSeconds = [[[RCNetworkManager sharedNetworkManager] valueForSetting:TIMESECONDS_KEY] boolValue];
	if (twentyFourHour)
		hour = @"HH";
	if (useSeconds)
		seconds = @":ss";
	formatter.dateFormat = [NSString stringWithFormat:@"%@:mm%@", hour, seconds];
}

- (NSString *)currentDateAsString {
	NSString *time = [formatter stringFromDate:[NSDate date]];
	return [[[NSString stringWithFormat:@"<div class=\"ts\">%@</div>", time] retain] autorelease];
}

- (NSString *)properlyFormattedTimeFromISO8601DateString:(NSString *)str {
	NSDate *date = [eightsixohoneformatter dateFromString:str];	
	return [[[formatter stringFromDate:date] retain] autorelease];
}

@end
