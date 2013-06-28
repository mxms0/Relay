//
//  RCServerChangeAlertView.h
//  Relay
//
//  Created by Fionn Kelleher on 28/06/2013.
//

#import "RCPrettyAlertView.h"

@interface RCServerChangeAlertView : RCPrettyAlertView

@property (nonatomic, retain) NSString *server;
@property (nonatomic, assign) int port;

@end
