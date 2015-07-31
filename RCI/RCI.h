//
//  RCI.h
//  RCI
//
//  Created by Max Shavrick on 7/20/15.
//  Copyright (c) 2015 Mxms. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for RCI.
FOUNDATION_EXPORT double RCIVersionNumber;

//! Project version string for RCI.
FOUNDATION_EXPORT const unsigned char RCIVersionString[];

#import "RCMIRCParser.h"

typedef enum RCMessageType {
	RCMessageTypeAction = 0,
	RCMessageTypeNormal,
	RCMessageTypeNotice,
	RCMessageTypeKick,
	RCMessageTypeBan,
	RCMessageTypePart,
	RCMessageTypeJoin,
	RCMessageTypeTopic,
	RCMessageTypeQuit,
	RCMessageTypeMode,
	RCMessageTypeError,
	RCMessageTypeEvent,
	RCMessageTypeNormalE,
	RCMessageTypeNormalE2
} RCMessageType;

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

#define CMLog(format, ...) NSLog(@"(%s) in [%s:%d] ::: %@", __PRETTY_FUNCTION__, __FILE__, __LINE__, [NSString stringWithFormat:format, ## __VA_ARGS__])
#define MARK CMLog(@"%s", __PRETTY_FUNCTION__);
#define BACKTRACE CMLog(@"%@", [NSThread callStackSymbols]);

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

// In this header, you should import all the public headers of your framework using statements like #import <RCI/PublicHeader.h>


