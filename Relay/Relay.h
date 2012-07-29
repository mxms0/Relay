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
	#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_4_0
		#define kCFCoreFoundationVersionNumber_iPhoneOS_4_0 550.32
	#endif
	#define PREFS_PLIST @"/Networks.plist"
	#define NETS_PLIST @"/Chat.plist"
	#define PREFS_ABSOLUT [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_PLIST]
	#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
	#define isPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	#define TEAM_TOKEN @"35b8aa0d259ae0c61c57bc770aeafe63_Mzk5NDYyMDExLTExLTA5IDE4OjQ0OjEwLjc4MTM3MQ"
	#define USE_PRIVATE 1
	#define _deg(x) ((x * M_PI)/180.0)
	#define UIApp [UIApplication sharedApplication]
	#define LOGALL 0
	#define CMLog(format, ...) NSLog(@"(%s) in [%s:%d] ::: %@", __PRETTY_FUNCTION__, __FILE__, __LINE__, [NSString stringWithFormat:format, ## __VA_ARGS__])
	#define MARK CMLog(@"%s", __PRETTY_FUNCTION__);
	typedef NSMutableAttributedString RCAttributedString;
#endif

/* NOTES
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