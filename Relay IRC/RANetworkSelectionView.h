//
//  RANetworkSelectionView.h
//  Relay IRC
//
//  Created by Max Shavrick on 7/22/15.
//  Copyright (c) 2015 Mxms. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RANetworkSelectionView, RCChannel;
@protocol RANetworkSelectionViewDelegate <NSObject>
- (void)networkSelectionView:(RANetworkSelectionView *)view userSelectedChannel:(RCChannel *)channel;
@end

@interface RANetworkSelectionView : UIView <UITableViewDataSource, UITableViewDelegate> {
	UITableView *networkListing;
}
@property (nonatomic, unsafe_unretained) id <RANetworkSelectionViewDelegate> delegate;
@end
