//
//  RCResponseParser.h
//  Relay
//
//  Created by Max Shavrick on 12/23/11.
//  Copyright (c) 2011 American Heritage School. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RCResponseParser : NSObject {
	NSOperationQueue *queue;
	id delegate;
}
@property (nonatomic, retain) id delegate;
- (void)messageRecieved:(NSString *)message;
- (void)parseHostmask:(NSString *)mask intoNick:(NSString **)nick intoUser:(NSString **)user intoHostmask:(NSString **)hostmask;
@end
