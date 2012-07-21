//
//  RCChatCell.h
//  Relay
//
//  Created by Max Shavrick on 2/17/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//	Somewhat based off Loren b's implementation
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>
#import "OHAttributedLabel.h"
#import "RCMessage.h"
#import "RCChatCellContentView.h"
#import "CHAttributedString.h"

@interface RCChatCell : UITableViewCell {
	RCChatCellContentView *contentView;
	BOOL needsLayout;
	OHAttributedLabel *textLabel;
	RCMessage *message;
	float height;
}
@property (nonatomic, retain) OHAttributedLabel *textLabel;
@property (nonatomic, retain) RCMessage *message;
- (void)drawContentView:(CGRect)rect;
@end
