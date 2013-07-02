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
		channelDatas = [[NSMutableArray alloc] init];
		CALayer *cv = [[CALayer alloc] init];
		[cv setContents:(id)[UIImage imageNamed:@"0_nvs"].CGImage];
		[cv setFrame:CGRectMake(0, -46, 320, 46)];
		[self.layer addSublayer:cv];
		[cv release];
		channels = [[RCSuperSpecialTableView alloc] initWithFrame:CGRectMake(0, 44, frame.size.width, frame.size.height-44)];
		[channels setSeparatorStyle:UITableViewCellSeparatorStyleNone];
		[channels setBackgroundColor:UIColorFromRGB(0xDDE0E5)];
		[channels setShowsVerticalScrollIndicator:YES];
		[channels setDelegate:self];
		[channels setDataSource:self];
		[channels setScrollEnabled:YES];
		[self addSubview:channels];
		[channels release];
	}
	return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (updating) return 0;
	return [channelDatas count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cc = [tableView dequeueReusableCellWithIdentifier:@"0_CSL"];
	if (!cc) {
		cc = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"0_CSL"] autorelease];
	}
	[cc setBackgroundColor:[UIColor blackColor]];
	[[cc textLabel] setText:@"HELLO"];
	return cc;
}

- (void)setUpdating:(BOOL)ud {
	updating = ud;
	dispatch_sync(dispatch_get_main_queue(), ^{
		if (!updating) {
			[channels reloadData];
			[[self navigationBar] setSubtitle:[NSString stringWithFormat:@"%d Channels", [channelDatas count]]];
			[[self navigationBar] setNeedsDisplay];
		}
	});
}

- (void)recievedChannel:(NSString *)chan withCount:(int)cc andTopic:(NSString *)topics {
	if (!updating) updating = YES;
	RCChannelInfo *ifs = [[RCChannelInfo alloc] init];
	[ifs setChannel:chan];
	[ifs setUserCount:cc];
	[ifs setTopic:topics];
	[channelDatas addObject:ifs];
	[ifs release];
}

- (void)dealloc {
	[channelDatas release];
	[super dealloc];
}

@end
