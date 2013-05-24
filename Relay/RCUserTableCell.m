//
//  RCUserTableCell.m
//  Relay
//
//  Created by Max Shavrick on 3/15/12.
//

#import "RCUserTableCell.h"
#import "RCChatController.h"
#import "NSString+IRCStringSupport.h"

@implementation RCUserTableCell
@synthesize isLast, isWhois;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		self.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:15];
		self.textLabel.textColor = [UIColor colorWithRed:0.236 green:0.239 blue:0.243 alpha:1.000];
		self.textLabel.shadowColor = [UIColor whiteColor];
		self.textLabel.shadowOffset = CGSizeMake(0, 1);
		self.selectionStyle = UITableViewCellSelectionStyleNone;
		isWhois = NO;
		fakeSelected = NO;
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
}

- (void)setSelected:(BOOL)selected {
	[super setSelected:selected];
	[self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	fakeSelected = YES;
	[self setNeedsDisplay];
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	fakeSelected = NO;
	[self setNeedsDisplay];
	[super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	fakeSelected = NO;
	[self setNeedsDisplay];
	[super touchesEnded:touches withEvent:event];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	self.textLabel.hidden = NO;
	if (isWhois) {
		self.textLabel.hidden = YES;
		[UIColorFromRGB(0xEEF2F4) set];
		UIRectFill(rect);
		RCPMChannel *chan = (RCPMChannel *)[[[RCChatController sharedController] currentPanel] channel];
		if (![chan isKindOfClass:[RCPMChannel class]]) return;
		NSMutableString *whois = nil;
		if ([chan chanInfos] != nil) {
			whois = [[NSString stringWithFormat:@"%@ is in %@\r\nHELLO", [chan channelName], [chan chanInfos]] mutableCopy];
		}
		else {
			whois = [@"Loading.. (not really)" mutableCopy];
			dispatch_async(dispatch_get_current_queue(), ^ {
				[chan requestWhoisInformation];
			});
		}
		if (!whois) return;
		if (!NSClassFromString(@"NSRegularExpression")) return;
		NSString *pattern1 = @"\\B[#&](\\w+)\\b";
		NSError *error;
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern1 options:0 error:&error];
		NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
		while ([whois rangeOfString:@"#"].location != NSNotFound) {
			NSRange rf = [regex rangeOfFirstMatchInString:whois options:0 range:NSMakeRange(0, [whois length])];
			if (rf.location == NSNotFound) break;
			NSString *beforeChan = [whois substringWithRange:NSMakeRange(0, rf.location+rf.length)];
			NSMutableAttributedString *tmp = [[NSMutableAttributedString alloc] initWithString:beforeChan];
			[tmp addAttribute:(NSString *)NSForegroundColorAttributeName value:[UIColor blueColor] range:rf];
			[attr appendAttributedString:tmp];
			[tmp release];
			[whois deleteCharactersInRange:NSMakeRange(0, [beforeChan length])];
		}
		if ([attr length] == 0) {
			[attr appendAttributedString:[[[NSAttributedString alloc] initWithString:whois] autorelease]];
		}
		[attr drawInRect:CGRectMake(10, 5, 200, 200)];
	}

	else {
		UIImage *bg = [UIImage imageNamed:@"0_strangebg"];
		[bg drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height+1) blendMode:(fakeSelected ? kCGBlendModeDarken : kCGBlendModeNormal) alpha:(fakeSelected ? 0.6 : 1.0)];
	}
	if (!isLast) {
		UIImage *ul = [UIImage imageNamed:@"0_usl"];
		[ul drawAsPatternInRect:CGRectMake(0, 43, rect.size.width, 1)];
	}

}

@end
