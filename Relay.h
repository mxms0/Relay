//
//  Relay.h
//  Relay
//
//  Created by Maximus on 1/16/12.
//

#ifndef Relay_Relay_h
	#define Relay_Relay_h
	#define USER_KEY @"0_USER"
	#define NICK_KEY @"0_NICK"
	#define NAME_KEY @"0_NAME"
	#define CONSOLECHANNEL @"\x01IRC"
	#define S_PASS_KEY @"0_S_PASS"
	#define N_PASS_KEY @"0_N_PASS"
	#define DESCRIPTION_KEY @"0_DESCRIPTION"
	#define SERVR_ADDR_KEY @"0_SERV_ADDR"
	#define PORT_KEY @"0_PORT"
	#define SSL_KEY @"0_SSL"
	#define CHANNELS_KEY @"0_CHANNELS"
	#define NETS_KEY @"0_NETWORKS"
	#define NET_INFO_KEY @"0_NET_INFO"
	#define COL_KEY @"0_CONNECT_ON_LAUNCH"
	#define RELOAD_KEY @"0_RELOAD_LIST"
	#define BG_NOTIF @"0_BGNOTIF"
	#define CHANNAMEKEY @"0_CHANKEYNAME"
	#define UUID_KEY @"0_UDIDKEY"
	#define SETTINGS_CHANGED_KEY @"0_settschanged"
// settings save keys
	#define SHOW_MOTD_KEY @"motddss"
	#define SETTINGS_KEY @"0_SETTINGSKEY"
	#define TIMESECONDS_KEY @"0_useseconds"
	#define AUTOCAPITALIZE_KEY @"0_autocapitlize"
	#define AUTOCORRECTION_KEY @"0_autocorct"
	#define TWENTYFOURHOURTIME_KEY @"0_24hrtime"
	#define THEME_CHANGED_KEY @"themechange"
	#define THEME_NAME_KEY @"themename"
	#define INLINEWHOIS_KEY @"inlinewhois"
	#define OPEN_IN_SAFARI_KEY @"openinsafari"
	#define DEF_NICK @"defaultNick"
	#define DEF_USER @"defaultUsername"
	#define DEF_REALNAME @"defaultRealName"
	#define DEF_QUITMSG @"defaultQuitMsg"
	#define LARGER_FONT_KEY @"shouldUseLargerFont"
	#define EXPANDED_KEY @"expanded"
	#define SHOULD_AWAY_KEY @"awaykeycykey"
//
	#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_4_0
		#define kCFCoreFoundationVersionNumber_iPhoneOS_4_0 550.32
	#endif
	#define RCCurrentNetKey @"0_CURRENTNET"
	#define DEFAULT_NICK @"Guest"
	#define RCCurrentChanKey @"0_CURRENTCHAN"
	#define PREFS_ABSOLUT [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_PLIST]
	#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
	#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	#define TEAM_TOKEN @"b6b92f88-8b8b-4d6b-ae0c-53cc8adf1038"
	#define DEL_CONFIRM_KEY 1112
    #define DEL_CHANNEL_KEY 1113
	#define USE_PRIVATE 1
	#define UIApp [UIApplication sharedApplication]
	#define _DEBUG 0
	#if _DEBUG
	#define LOGALL 1
	#else
	#define LOGALL 0
	#endif
	#define IGNORE_SAVE 0
// alerts
	#define RCALERR_INCNICK 666
	#define RCALERR_INCUNAME 667
	#define RCALERR_INCSPASS 668
    #define RCALERR_SERVCHNGE 669
// actions sheets
	#define	RCALERR_GLOPTIONS 200
	#define RCALERR_INDVOPTIONS 201
// buttons
	#define RCChannelListButtonTag 101
	#define RCUserListButtonTag 102
	#define CMLog(format, ...) NSLog(@"(%s) in [%s:%d] ::: %@", __PRETTY_FUNCTION__, __FILE__, __LINE__, [NSString stringWithFormat:format, ## __VA_ARGS__])
	#define MARK CMLog(@"%s", __PRETTY_FUNCTION__);
	#define BACKTRACE CMLog(@"%@", [NSThread callStackSymbols]);

	typedef enum RCPasswordRequestAlertType {
		RCPasswordRequestAlertTypeNickServ,
		RCPasswordRequestAlertTypeServer
	} RCPasswordRequestAlertType;

	typedef enum RCActionSheetButtonType {
		RCActionSheetButtonTypeDestructive,
		RCActionSheetButtonTypeNormal,
		RCActionSheetButtonTypeCancel
	} RCActionSheetButtonType;

	static inline void reloadNetworks(void);
	static inline void reloadNetworks(void) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"us.mxms.relay.reload" object:nil];
	}
#endif

/* ::: NOTES :::
 * \x03 - begin/end color segment
 * \x02 - begin/end bold segment 
 * \x16 - begin/end italics segment
 * \x1F - begin/end underline segment
 * \x30 - White 
 * \x31 - Black
 * \x32 - Blue
 * \x33 - Green
 * \x34 - Light Red
 * \x35 - Brown
 * \x36 - Purple
 * \x37 - Orange
 * \x38 - Yellow
 * \x39 - Light Green
 * \x31\x30 - Cyan
 * \x31\x31 - Light Cyan
 * \x31\x32 - Light Blue
 * \x31\x33 - Pink
 * \x31\x34 - Gray
 * \x31\x35 - Light Gray
 */