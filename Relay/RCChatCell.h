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
#import "NSAttributedString+Attributes.h"
#import "RCMessage.h"

@interface RCChatCell : UITableViewCell {
	OHAttributedLabel *textLabel;
	RCMessageFlavor currentFlavor;
	RCMessage *message;
	float height;
}
@property (nonatomic, retain) OHAttributedLabel *textLabel;
@property (nonatomic, retain) RCMessage *message;
CTFontRef CTFontCreateFromUIFont(UIFont *font);
- (void)_textHasBeenSet;
- (float)calculateHeightForLabel;
@end
