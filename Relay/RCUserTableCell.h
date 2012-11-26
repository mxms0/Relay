//
//  RCUserTableCell.h
//  Relay
//
//  Created by Max Shavrick on 3/15/12.
//

#import <UIKit/UIKit.h>
#import "RCBasicTableViewCell.h"

@interface RCUserTableCell : RCBasicTableViewCell {
	BOOL isLast;
}
@property (nonatomic, assign) BOOL isLast;
@end
