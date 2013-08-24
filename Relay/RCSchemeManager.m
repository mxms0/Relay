//
//  RCSchemeManager.m
//  Relay
//
//  Created by Max Shavrick on 8/18/13.
//

#import "RCSchemeManager.h"
#import "RCNetworkManager.h"

@implementation RCSchemeManager
@synthesize isDark;
static id _managerInstance = nil;

+ (id)sharedInstance {
	if (!_managerInstance) _managerInstance = [[self alloc] init];
	return _managerInstance;
}

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:THEME_CHANGED_KEY object:nil];
		isRetina = [[UIScreen mainScreen] scale] > 1.0;
		NSString *themeName = [[RCNetworkManager sharedNetworkManager] valueForSetting:THEME_NAME_KEY];
		if (themeName) {
			[self loadBundleNamed:themeName];
		}
		else {
			[self loadBundleNamed:@"DarkUI"];
		}
	}
	return self;
}

- (void)themeChanged:(NSNotification *)nc {
	NSString *themeName = (NSString *)[nc object];
	[self loadBundleNamed:themeName];
	[[RCChatController sharedController] themeChanged:nil];
}

- (void)loadBundleNamed:(NSString *)name {
	char *hdir = getenv("HOME");
	if (!hdir) {
		NSLog(@"CAN'T FIND HOME DIRECTORY TO LOAD NETWORKS");
		exit(1);
	}
	char dir[4096];
	sprintf(dir, "%s/Relay.app/%s.bundle", hdir, [name UTF8String]);
	NSString *absol = [[NSString alloc] initWithUTF8String:dir];
	isDark = ([name hasPrefix:@"Dark"]);
	currentThemeBundle = [[NSBundle alloc] initWithPath:absol];
}

- (id)imageNamed:(NSString *)image {
	return [UIImage imageWithContentsOfFile:[currentThemeBundle pathForResource:[image stringByAppendingString:(isRetina ? @"@2x" : @"")] ofType:@"png"]];
}

@end
