//
//  RCMessage.h
//  Relay
//
//  Created by Max Shavrick on 2/20/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHAttributedString.h"
#import "OHAttributedLabel.h"
#import <QuartzCore/QuartzCore.h>

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
	NSMutableAttributedString *string;
}
- (id)initWithMessage:(NSString *)msg isOld:(BOOL)old isMine:(BOOL)m isHighlight:(BOOL)hh flavor:(RCMessageFlavor)flavor;
- (NSMutableAttributedString *)string;
@end
