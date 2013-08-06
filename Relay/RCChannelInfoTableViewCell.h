//
//  RCChannelInfoTableViewCell.h
//  Relay
//
//  Created by Max Shavrick on 7/11/13.
//

#import <UIKit/UIKit.h>
#import "RCChannelInfo.h"

@interface RCChannelInfoTableViewCell : UITableViewCell {
	UILabel *rightLabel;
}
@property (nonatomic, retain) RCChannelInfo *channelInfo;
@end
