//
//  RCUserTableCellContentView.m
//  Relay
//
//  Created by Max Shavrick on 6/21/13.
//

#import "RCUserTableCellContentView.h"

@implementation RCUserTableCellContentView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	fakeSelected = YES;
	[self setNeedsDisplay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	fakeSelected = NO;
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	fakeSelected = NO;
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	RCUserTableCell *cc;
	UIView *v = [self superview];
	if ([[self superview] isKindOfClass:[RCUserTableCell class]]) {
		cc = (RCUserTableCell *)v;
	}
	else {
		cc = (RCUserTableCell *)[v superview];
	}
	// kill me.
	
	if ([cc isWhois]) {
		[UIColorFromRGB(0xEEF2F4) set];
		UIRectFill(rect);
		/*
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
		 */
	}
	else {
		UIImage *bg = [UIImage imageNamed:@"0_strangebg"];
		[bg drawInRect:CGRectMake(0, 0, rect.size.width, rect.size.height+1) blendMode:kCGBlendModeNormal alpha:(fakeSelected ? 0.9 : 1.0)];
	}
	if (![cc isLast]) {
		UIImage *ul = [UIImage imageNamed:@"0_usl"];
		[ul drawAsPatternInRect:CGRectMake(0, 43, rect.size.width, 1)];
	}
}

@end
