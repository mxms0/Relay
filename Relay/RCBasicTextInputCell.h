//
//  RCBasicTextInputCell.h
//  Relay
//
//  Created by Max Shavrick on 8/7/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCTextField.h"
#import "RCBasicTableViewCell.h"

@interface RCBasicTextInputCell : RCBasicTableViewCell {
	RCTextField *textField;
}
@property (nonatomic, retain) RCTextField *textField;

@end
