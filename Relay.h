//
//  Relay.h
//  Relay
//
//  Created by Maximus on 1/16/12.
//

#ifndef Relay_Relay_h
	#define Relay_Relay_h

	#define PREFS_ABSOLUT [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_PLIST]
	#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
	#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

	#define UIApp [UIApplication sharedApplication]

	#define CMLog(format, ...) NSLog(@"(%s) in [%s:%d] ::: %@", __PRETTY_FUNCTION__, __FILE__, __LINE__, [NSString stringWithFormat:format, ## __VA_ARGS__])
	#define MARK CMLog(@"%s", __PRETTY_FUNCTION__);
	#define BACKTRACE CMLog(@"%@", [NSThread callStackSymbols]);

#endif
