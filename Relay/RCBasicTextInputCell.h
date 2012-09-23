//
//  RCBasicTextInputCell.h
//  Relay
//
//  Created by Max Shavrick on 8/7/12.
//

#import <UIKit/UIKit.h>
#import "RCTextField.h"
#import "RCBasicTableViewCell.h"

@interface RCBasicTextInputCell : RCBasicTableViewCell {
	RCTextField *textField;
}
@property (nonatomic, retain) RCTextField *textField;

@end
