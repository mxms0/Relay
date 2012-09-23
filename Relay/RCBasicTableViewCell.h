//
//  RCBasicTableViewCell.h
//  Relay
//
//  Created by Max Shavrick on 8/7/12.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface RCBasicTableViewCell : UITableViewCell {
    CGFloat transform;
    int _state;
}
@end
