//
//  RAChatController.h
//  Relay IRC
//
//  Created by Max Shavrick on 7/22/15.
//  Copyright (c) 2015 Mxms. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RANavigationBar.h"
#import "RCNetwork.h"

@class RAChannelProxy, RAChatController, RCChannel;

RAChannelProxy *RAChannelProxyForChannel(RCChannel *channel);

@protocol RAChatControllerDelegate <NSObject>
- (RAChannelProxy *)currentChannelProxy;
- (void)chatControllerWantsUpdateUI:(RAChatController *)controller;

@end

@interface RAChatController : NSObject <UINavigationBarDelegate, RCChannelDelegate, RCNetworkDelegate> {

}
@property (unsafe_unretained) id <RAChatControllerDelegate> delegate;
@end
