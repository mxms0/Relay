//
//  RCNetworkCell.h
//  Relay
//
//  Created by Max Shavrick on 6/22/12.
//

#import <UIKit/UIKit.h>
#import "RCBasicTableViewCell.h"
#import "RCNetworkCellBackgroundView.h"

@interface RCNetworkCell : RCBasicTableViewCell {
	NSString *channel;
}
@property (nonatomic, retain) NSString *channel;
@end
