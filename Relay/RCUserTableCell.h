//
//  RCUserTableCell.h
//  Relay
//
//  Created by Max Shavrick on 3/15/12.
//

#import <UIKit/UIKit.h>
#import "RCBasicTableViewCell.h"
#import "RCUserTableCellContentView.h"

@class RCUserTableCellContentView;
@interface RCUserTableCell : RCBasicTableViewCell {
	RCUserTableCellContentView *contentView;
	BOOL isLast;
	BOOL isWhois;
	BOOL fakeSelected;
}
@property (nonatomic, readonly) RCUserTableCellContentView *contentView;
@property (nonatomic, assign) BOOL isLast;
@property (nonatomic, assign) BOOL isWhois;
@end
