//
//  RCChatCell.h
//  Relay
//
//  Created by Max Shavrick on 2/17/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>
#import "OHAttributedLabel.h"
#import "RCMessage.h"
#import "CHAttributedString.h"

@interface RCChatCell : UITableViewCell {
	BOOL needsLayout;
	OHAttributedLabel *textLabel;
	RCMessage *message;
	float height;
}
@property (nonatomic, retain) OHAttributedLabel *textLabel;
@property (nonatomic, retain) RCMessage *message;
@end
