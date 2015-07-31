//
//  RCMessageConstruct.h
//  Relay
//
//  Created by Siberia on 6/10/14.
//  Copyright (c) 2014 American Heritage School. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableAttributedString+RCAdditions.h"

@interface RCMessageConstruct : NSObject
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *sender;
@property (nonatomic, retain) NSAttributedString *attributedString;
@property (nonatomic, assign) char color;
@property (nonatomic, readonly) CGFloat height;
@property (nonatomic, readonly) CGFloat landscapeHeight;
@property (nonatomic, readonly) CGFloat nameWidth;

- (id)initWithMessage:(NSString *)message;
@end
