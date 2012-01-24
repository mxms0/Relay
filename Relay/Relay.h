//
//  Relay.h
//  Relay
//
//  Created by Max Shavrick on 1/16/12.
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
	#define RELOAD_KEY @"0_RELOAD_TABLE"
	#ifndef kCFCoreFoundationVersionNumber_iPhoneOS_4_0
		#define kCFCoreFoundationVersionNumber_iPhoneOS_4_0 550.32
	#endif
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