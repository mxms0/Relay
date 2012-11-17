//
//  RCNetworkCell.h
//  Relay
//
//  Created by Max Shavrick on 6/22/12.
//

#import <UIKit/UIKit.h>
#import "RCBasicTableViewCell.h"

@interface RCNetworkCell : RCBasicTableViewCell {
	NSString *channel;
	BOOL white;
	BOOL fakeWhite;
}
@property (nonatomic, retain) NSString *channel;
@property (nonatomic, assign) BOOL white;
@end
