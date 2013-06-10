//
//  RCDateManager.h
//  Relay
//
//  Created by Max Shavrick on 7/16/12.
//

#import <Foundation/Foundation.h>
#import "ISO8601DateFormatter.h"

@interface RCDateManager : NSObject {
	NSDateFormatter *formatter;
	ISO8601DateFormatter *eightsixohoneformatter;
}
+ (id)sharedInstance;
- (NSString *)currentDateAsString;
- (NSString *)properlyFormattedTimeFromISO8601DateString:(NSString *)str;
@end
