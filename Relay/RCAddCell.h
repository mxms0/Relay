//
//  RCAddCell.h
//  Relay
//
//  Created by Max Shavrick on 3/21/12.
//  Copyright (c) 2012 American Heritage School. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCAddCell : UITableViewCell {
	BOOL isTop;
	BOOL isBottom;
}
@property (nonatomic, assign) BOOL isTop;
@property (nonatomic, assign) BOOL isBottom;

@end
