//
//  RCUserTableCell.h
//  Relay
//
//  Created by Max Shavrick on 3/15/12.
//

#import <UIKit/UIKit.h>
#import "RCBasicTableViewCell.h"

@class RCChannel;
@interface RCUserTableCell : RCBasicTableViewCell {
	RCChannel *channel;
	NSString *prefix;
	BOOL isLast;
	BOOL isWhois;
	BOOL fakeSelected;
}
@property (nonatomic, assign) BOOL isLast;
@property (nonatomic, assign) BOOL isWhois;
- (void)setChannel:(RCChannel *)chan;
@end
