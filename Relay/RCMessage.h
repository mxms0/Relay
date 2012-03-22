//
//  RCMessage.h
//  Relay
//
//  Created by Max Shavrick on 2/20/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum RCMessageFlavor {
	RCMessageFlavorNotice = 0,
	RCMessageFlavorAction,
	RCMessageFlavorNormal,
	RCMessageFlavorTopic,
	RCMessageFlavorJoin,
	RCMessageFlavorPart,
	RCMessageFlavorNormalE
} RCMessageFlavor;

@interface RCMessage : NSObject {
	NSString *message;
	BOOL highlight;
	RCMessageFlavor flavor;
	BOOL isHighlight;
	BOOL isMine;
}
@property (nonatomic, retain) NSString *message;
@property (nonatomic, assign) RCMessageFlavor flavor;
@property (nonatomic, assign) BOOL highlight;
@property (nonatomic, assign) BOOL isMine;
@end
