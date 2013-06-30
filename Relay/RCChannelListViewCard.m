//
//  RCChannelListViewCard.m
//  Relay
//
//  Created by Siberia on 6/29/13.
//

#import "RCChannelListViewCard.h"
#import "RCChatController.h"

@implementation RCChannelListViewCard

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		[navigationBar setMaxSize:18];
		[navigationBar setNeedsDisplay];
		CALayer *cv = [[CALayer alloc] init];
		[cv setContents:(id)[UIImage imageNamed:@"0_nvs"].CGImage];
		[cv setFrame:CGRectMake(0, -46, 320, 46)];
		[self.layer addSublayer:cv];
		[cv release];
	}
	return self;
}
@end
