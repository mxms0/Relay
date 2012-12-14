//
//  NSString+IRCStringSupport.m
//  Relay
//
//  Created by qwertyoruiop on 12/08/12.
//

#import "NSString+IRCStringSupport.h"
#import <CoreText/CoreText.h>
#import "RCChatView.h"
typedef struct {
	NSString *escapeSequence;
	unichar uchar;
} HTMLEscapeMap;

// Taken from http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
// Ordered by uchar lowest to highest for bsearching
static HTMLEscapeMap gAsciiHTMLEscapeMap[] = {
	{ @"&quot;", 34 },
	{ @"&amp;", 38 },
	{ @"&apos;", 39 },
	{ @"&lt;", 60 },
	{ @"&gt;", 62 },
	
	{ @"&nbsp;", 160 }, 
	{ @"&iexcl;", 161 }, 
	{ @"&cent;", 162 }, 
	{ @"&pound;", 163 }, 
	{ @"&curren;", 164 }, 
	{ @"&yen;", 165 }, 
	{ @"&brvbar;", 166 }, 
	{ @"&sect;", 167 }, 
	{ @"&uml;", 168 }, 
	{ @"&copy;", 169 }, 
	{ @"&ordf;", 170 }, 
	{ @"&laquo;", 171 }, 
	{ @"&not;", 172 }, 
	{ @"&shy;", 173 }, 
	{ @"&reg;", 174 }, 
	{ @"&macr;", 175 }, 
	{ @"&deg;", 176 }, 
	{ @"&plusmn;", 177 }, 
	{ @"&sup2;", 178 }, 
	{ @"&sup3;", 179 }, 
	{ @"&acute;", 180 }, 
	{ @"&micro;", 181 }, 
	{ @"&para;", 182 }, 
	{ @"&middot;", 183 }, 
	{ @"&cedil;", 184 }, 
	{ @"&sup1;", 185 }, 
	{ @"&ordm;", 186 }, 
	{ @"&raquo;", 187 }, 
	{ @"&frac14;", 188 }, 
	{ @"&frac12;", 189 }, 
	{ @"&frac34;", 190 }, 
	{ @"&iquest;", 191 }, 
	{ @"&Agrave;", 192 }, 
	{ @"&Aacute;", 193 }, 
	{ @"&Acirc;", 194 }, 
	{ @"&Atilde;", 195 }, 
	{ @"&Auml;", 196 }, 
	{ @"&Aring;", 197 }, 
	{ @"&AElig;", 198 }, 
	{ @"&Ccedil;", 199 }, 
	{ @"&Egrave;", 200 }, 
	{ @"&Eacute;", 201 }, 
	{ @"&Ecirc;", 202 }, 
	{ @"&Euml;", 203 }, 
	{ @"&Igrave;", 204 }, 
	{ @"&Iacute;", 205 }, 
	{ @"&Icirc;", 206 }, 
	{ @"&Iuml;", 207 }, 
	{ @"&ETH;", 208 }, 
	{ @"&Ntilde;", 209 }, 
	{ @"&Ograve;", 210 }, 
	{ @"&Oacute;", 211 }, 
	{ @"&Ocirc;", 212 }, 
	{ @"&Otilde;", 213 }, 
	{ @"&Ouml;", 214 }, 
	{ @"&times;", 215 }, 
	{ @"&Oslash;", 216 }, 
	{ @"&Ugrave;", 217 }, 
	{ @"&Uacute;", 218 }, 
	{ @"&Ucirc;", 219 }, 
	{ @"&Uuml;", 220 }, 
	{ @"&Yacute;", 221 }, 
	{ @"&THORN;", 222 }, 
	{ @"&szlig;", 223 }, 
	{ @"&agrave;", 224 }, 
	{ @"&aacute;", 225 }, 
	{ @"&acirc;", 226 }, 
	{ @"&atilde;", 227 }, 
	{ @"&auml;", 228 }, 
	{ @"&aring;", 229 }, 
	{ @"&aelig;", 230 }, 
	{ @"&ccedil;", 231 }, 
	{ @"&egrave;", 232 }, 
	{ @"&eacute;", 233 }, 
	{ @"&ecirc;", 234 }, 
	{ @"&euml;", 235 }, 
	{ @"&igrave;", 236 }, 
	{ @"&iacute;", 237 }, 
	{ @"&icirc;", 238 }, 
	{ @"&iuml;", 239 }, 
	{ @"&eth;", 240 }, 
	{ @"&ntilde;", 241 }, 
	{ @"&ograve;", 242 }, 
	{ @"&oacute;", 243 }, 
	{ @"&ocirc;", 244 }, 
	{ @"&otilde;", 245 }, 
	{ @"&ouml;", 246 }, 
	{ @"&divide;", 247 }, 
	{ @"&oslash;", 248 }, 
	{ @"&ugrave;", 249 }, 
	{ @"&uacute;", 250 }, 
	{ @"&ucirc;", 251 }, 
	{ @"&uuml;", 252 }, 
	{ @"&yacute;", 253 }, 
	{ @"&thorn;", 254 }, 
	{ @"&yuml;", 255 },
	
	{ @"&OElig;", 338 },
	{ @"&oelig;", 339 },
	{ @"&Scaron;", 352 },
	{ @"&scaron;", 353 },
	{ @"&Yuml;", 376 },
	
	{ @"&fnof;", 402 },
	
	{ @"&circ;", 710 },
	{ @"&tilde;", 732 },
	
	{ @"&Alpha;", 913 }, 
	{ @"&Beta;", 914 }, 
	{ @"&Gamma;", 915 }, 
	{ @"&Delta;", 916 }, 
	{ @"&Epsilon;", 917 }, 
	{ @"&Zeta;", 918 }, 
	{ @"&Eta;", 919 }, 
	{ @"&Theta;", 920 }, 
	{ @"&Iota;", 921 }, 
	{ @"&Kappa;", 922 }, 
	{ @"&Lambda;", 923 }, 
	{ @"&Mu;", 924 }, 
	{ @"&Nu;", 925 }, 
	{ @"&Xi;", 926 }, 
	{ @"&Omicron;", 927 }, 
	{ @"&Pi;", 928 }, 
	{ @"&Rho;", 929 }, 
	{ @"&Sigma;", 931 }, 
	{ @"&Tau;", 932 }, 
	{ @"&Upsilon;", 933 }, 
	{ @"&Phi;", 934 }, 
	{ @"&Chi;", 935 }, 
	{ @"&Psi;", 936 }, 
	{ @"&Omega;", 937 }, 
	{ @"&alpha;", 945 }, 
	{ @"&beta;", 946 }, 
	{ @"&gamma;", 947 }, 
	{ @"&delta;", 948 }, 
	{ @"&epsilon;", 949 }, 
	{ @"&zeta;", 950 }, 
	{ @"&eta;", 951 }, 
	{ @"&theta;", 952 }, 
	{ @"&iota;", 953 }, 
	{ @"&kappa;", 954 }, 
	{ @"&lambda;", 955 }, 
	{ @"&mu;", 956 }, 
	{ @"&nu;", 957 }, 
	{ @"&xi;", 958 }, 
	{ @"&omicron;", 959 }, 
	{ @"&pi;", 960 }, 
	{ @"&rho;", 961 }, 
	{ @"&sigmaf;", 962 }, 
	{ @"&sigma;", 963 }, 
	{ @"&tau;", 964 }, 
	{ @"&upsilon;", 965 }, 
	{ @"&phi;", 966 }, 
	{ @"&chi;", 967 }, 
	{ @"&psi;", 968 }, 
	{ @"&omega;", 969 }, 
	{ @"&thetasym;", 977 }, 
	{ @"&upsih;", 978 }, 
	{ @"&piv;", 982 }, 
	
	{ @"&ensp;", 8194 },
	{ @"&emsp;", 8195 },
	{ @"&thinsp;", 8201 },
	{ @"&zwnj;", 8204 },
	{ @"&zwj;", 8205 },
	{ @"&lrm;", 8206 },
	{ @"&rlm;", 8207 },
	{ @"&ndash;", 8211 },
	{ @"&mdash;", 8212 },
	{ @"&lsquo;", 8216 },
	{ @"&rsquo;", 8217 },
	{ @"&sbquo;", 8218 },
	{ @"&ldquo;", 8220 },
	{ @"&rdquo;", 8221 },
	{ @"&bdquo;", 8222 },
	{ @"&dagger;", 8224 },
	{ @"&Dagger;", 8225 },

	{ @"&bull;", 8226 }, 
	{ @"&hellip;", 8230 }, 
	
	{ @"&permil;", 8240 },
	
	{ @"&prime;", 8242 }, 
	{ @"&Prime;", 8243 }, 
	
	{ @"&lsaquo;", 8249 },
	{ @"&rsaquo;", 8250 },
	
	{ @"&oline;", 8254 }, 
	{ @"&frasl;", 8260 }, 
	
	{ @"&euro;", 8364 },
	 
	{ @"&image;", 8465 },
	{ @"&weierp;", 8472 }, 
	{ @"&real;", 8476 }, 
	{ @"&trade;", 8482 }, 
	{ @"&alefsym;", 8501 }, 
	{ @"&larr;", 8592 }, 
	{ @"&uarr;", 8593 }, 
	{ @"&rarr;", 8594 }, 
	{ @"&darr;", 8595 }, 
	{ @"&harr;", 8596 }, 
	{ @"&crarr;", 8629 }, 
	{ @"&lArr;", 8656 }, 
	{ @"&uArr;", 8657 }, 
	{ @"&rArr;", 8658 }, 
	{ @"&dArr;", 8659 }, 
	{ @"&hArr;", 8660 }, 
	{ @"&forall;", 8704 }, 
	{ @"&part;", 8706 }, 
	{ @"&exist;", 8707 }, 
	{ @"&empty;", 8709 }, 
	{ @"&nabla;", 8711 }, 
	{ @"&isin;", 8712 }, 
	{ @"&notin;", 8713 }, 
	{ @"&ni;", 8715 }, 
	{ @"&prod;", 8719 }, 
	{ @"&sum;", 8721 }, 
	{ @"&minus;", 8722 }, 
	{ @"&lowast;", 8727 }, 
	{ @"&radic;", 8730 }, 
	{ @"&prop;", 8733 }, 
	{ @"&infin;", 8734 }, 
	{ @"&ang;", 8736 }, 
	{ @"&and;", 8743 }, 
	{ @"&or;", 8744 }, 
	{ @"&cap;", 8745 }, 
	{ @"&cup;", 8746 }, 
	{ @"&int;", 8747 }, 
	{ @"&there4;", 8756 }, 
	{ @"&sim;", 8764 }, 
	{ @"&cong;", 8773 }, 
	{ @"&asymp;", 8776 }, 
	{ @"&ne;", 8800 }, 
	{ @"&equiv;", 8801 }, 
	{ @"&le;", 8804 }, 
	{ @"&ge;", 8805 }, 
	{ @"&sub;", 8834 }, 
	{ @"&sup;", 8835 }, 
	{ @"&nsub;", 8836 }, 
	{ @"&sube;", 8838 }, 
	{ @"&supe;", 8839 }, 
	{ @"&oplus;", 8853 }, 
	{ @"&otimes;", 8855 }, 
	{ @"&perp;", 8869 }, 
	{ @"&sdot;", 8901 }, 
	{ @"&lceil;", 8968 }, 
	{ @"&rceil;", 8969 }, 
	{ @"&lfloor;", 8970 }, 
	{ @"&rfloor;", 8971 }, 
	{ @"&lang;", 9001 }, 
	{ @"&rang;", 9002 }, 
	{ @"&loz;", 9674 }, 
	{ @"&spades;", 9824 }, 
	{ @"&clubs;", 9827 }, 
	{ @"&hearts;", 9829 }, 
	{ @"&diams;", 9830 }
};

// Taken from http://www.w3.org/TR/xhtml1/dtds.html#a_dtd_Special_characters
// This is table A.2.2 Special Characters
static HTMLEscapeMap gUnicodeHTMLEscapeMap[] = {
	{ @"&quot;", 34 },
	{ @"&amp;", 38 },
	{ @"&apos;", 39 },
	{ @"&lt;", 60 },
	{ @"&gt;", 62 },
	
	{ @"&OElig;", 338 },
	{ @"&oelig;", 339 },
	{ @"&Scaron;", 352 },
	{ @"&scaron;", 353 },
	{ @"&Yuml;", 376 },
	
	{ @"&circ;", 710 },
	{ @"&tilde;", 732 },
    
	{ @"&ensp;", 8194 },
	{ @"&emsp;", 8195 },
	{ @"&thinsp;", 8201 },
	{ @"&zwnj;", 8204 },
	{ @"&zwj;", 8205 },
	{ @"&lrm;", 8206 },
	{ @"&rlm;", 8207 },
	{ @"&ndash;", 8211 },
	{ @"&mdash;", 8212 },
	{ @"&lsquo;", 8216 },
	{ @"&rsquo;", 8217 },
	{ @"&sbquo;", 8218 },
	{ @"&ldquo;", 8220 },
	{ @"&rdquo;", 8221 },
	{ @"&bdquo;", 8222 },
	{ @"&dagger;", 8224 },
	{ @"&Dagger;", 8225 },
	{ @"&permil;", 8240 },
	{ @"&lsaquo;", 8249 },
	{ @"&rsaquo;", 8250 },
	{ @"&euro;", 8364 },
};


// Utility function for Bsearching table above
static int EscapeMapCompare(const void *ucharVoid, const void *mapVoid) {
	const unichar *uchar = (const unichar *)ucharVoid;
	const HTMLEscapeMap *map = (const HTMLEscapeMap*)mapVoid;
	int val;
	if (*uchar > map->uchar) val = 1;
	else if (*uchar < map->uchar) val = -1;
	else val = 0;
	return val;
}

@implementation NSString (HTML)

- (NSString *)gtm_stringByEscapingHTMLUsingTable:(HTMLEscapeMap *)table ofSize:(NSUInteger)size escapingUnicode:(BOOL)escapeUnicode {  
	NSUInteger length = [self length];
	if (!length) return self;
	
	NSMutableString *finalString = [NSMutableString string];
	NSMutableData *data2 = [NSMutableData dataWithCapacity:sizeof(unichar) * length];
	
	const unichar *buffer = CFStringGetCharactersPtr((CFStringRef)self);
	if (!buffer) {
		NSMutableData *data = [NSMutableData dataWithLength:length * sizeof(UniChar)];
		if (!data) {
			return nil;
		}
		[self getCharacters:[data mutableBytes]];
		buffer = [data bytes];
	}
	
	if (!buffer || !data2) {
		return nil;
	}
	unichar *buffer2 = (unichar *)[data2 mutableBytes];
	
	NSUInteger buffer2Length = 0;
	
	for (NSUInteger i = 0; i < length; ++i) {
		HTMLEscapeMap *val = bsearch(&buffer[i], table, size / sizeof(HTMLEscapeMap), sizeof(HTMLEscapeMap), EscapeMapCompare);
		if (val || (escapeUnicode && buffer[i] > 127)) {
			if (buffer2Length) {
				CFStringAppendCharacters((CFMutableStringRef)finalString, buffer2, buffer2Length);
				buffer2Length = 0;
			}
			if (val) {
				[finalString appendString:val->escapeSequence];
			}
			else {
				[finalString appendFormat:@"&#%d;", buffer[i]];
			}
		} else {
			buffer2[buffer2Length] = buffer[i];
			buffer2Length += 1;
		}
	}
	if (buffer2Length) {
		CFStringAppendCharacters((CFMutableStringRef)finalString, buffer2, buffer2Length);
	}
	return finalString;
}

- (NSString *)gtm_stringByEscapingForHTML {
	return [self gtm_stringByEscapingHTMLUsingTable:gUnicodeHTMLEscapeMap 
											 ofSize:sizeof(gUnicodeHTMLEscapeMap) 
									escapingUnicode:NO];
} // gtm_stringByEscapingHTML

- (NSString *)gtm_stringByEscapingForAsciiHTML {
	return [self gtm_stringByEscapingHTMLUsingTable:gAsciiHTMLEscapeMap 
											 ofSize:sizeof(gAsciiHTMLEscapeMap) 
									escapingUnicode:YES];
} // gtm_stringByEscapingAsciiHTML

- (NSString *)gtm_stringByUnescapingFromHTML {
	NSRange range = NSMakeRange(0, [self length]);
	NSRange subrange = [self rangeOfString:@"&" options:NSBackwardsSearch range:range];
	
	// if no ampersands, we've got a quick way out
	if (subrange.length == 0) return self;
	NSMutableString *finalString = [NSMutableString stringWithString:self];
	do {
		NSRange semiColonRange = NSMakeRange(subrange.location, NSMaxRange(range) - subrange.location);
		semiColonRange = [self rangeOfString:@";" options:0 range:semiColonRange];
		range = NSMakeRange(0, subrange.location);
		// if we don't find a semicolon in the range, we don't have a sequence
		if (semiColonRange.location == NSNotFound) {
			continue;
		}
		NSRange escapeRange = NSMakeRange(subrange.location, semiColonRange.location - subrange.location + 1);
		NSString *escapeString = [self substringWithRange:escapeRange];
		NSUInteger length = [escapeString length];
		// a squence must be longer than 3 (&lt;) and less than 11 (&thetasym;)
		if (length > 3 && length < 11) {
			if ([escapeString characterAtIndex:1] == '#') {
				unichar char2 = [escapeString characterAtIndex:2];
				if (char2 == 'x' || char2 == 'X') {
					// Hex escape squences &#xa3;
					NSString *hexSequence = [escapeString substringWithRange:NSMakeRange(3, length - 4)];
					NSScanner *scanner = [NSScanner scannerWithString:hexSequence];
					unsigned value;
					if ([scanner scanHexInt:&value] && 
						value < USHRT_MAX &&
						value > 0 
						&& [scanner scanLocation] == length - 4) {
						unichar uchar = value;
						NSString *charString = [NSString stringWithCharacters:&uchar length:1];
						[finalString replaceCharactersInRange:escapeRange withString:charString];
					}
					
				} else {
					// Decimal Sequences &#123;
					NSString *numberSequence = [escapeString substringWithRange:NSMakeRange(2, length - 3)];
					NSScanner *scanner = [NSScanner scannerWithString:numberSequence];
					int value;
					if ([scanner scanInt:&value] && 
						value < USHRT_MAX &&
						value > 0 
						&& [scanner scanLocation] == length - 3) {
						unichar uchar = value;
						NSString *charString = [NSString stringWithCharacters:&uchar length:1];
						[finalString replaceCharactersInRange:escapeRange withString:charString];
					}
				}
			} else {
				// "standard" sequences
				for (unsigned i = 0; i < sizeof(gAsciiHTMLEscapeMap) / sizeof(HTMLEscapeMap); ++i) {
					if ([escapeString isEqualToString:gAsciiHTMLEscapeMap[i].escapeSequence]) {
						[finalString replaceCharactersInRange:escapeRange withString:[NSString stringWithCharacters:&gAsciiHTMLEscapeMap[i].uchar length:1]];
						break;
					}
				}
			}
		}
	} while ((subrange = [self rangeOfString:@"&" options:NSBackwardsSearch range:range]).length != 0);
	return finalString;
}

#pragma mark - Instance Methods

- (NSString *)stringByConvertingHTMLToPlainText {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSCharacterSet *stopCharacters = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@"< \t\n\r%C%C%C%C", (unsigned short)0x0085, (unsigned short)0x000C, (unsigned short)0x2028, (unsigned short)0x2029]];
	NSCharacterSet *newLineAndWhitespaceCharacters = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithFormat:@" \t\n\r%C%C%C%C", (unsigned short)0x0085, (unsigned short)0x000C, (unsigned short)0x2028, (unsigned short)0x2029]];
	NSCharacterSet *tagNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"];
	
	NSMutableString *result = [[NSMutableString alloc] initWithCapacity:self.length];
	NSScanner *scanner = [[NSScanner alloc] initWithString:self];
	[scanner setCharactersToBeSkipped:nil];
	[scanner setCaseSensitive:YES];
	NSString *str = nil, *tagName = nil;
	BOOL dontReplaceTagWithSpace = NO;
	do {
		if ([scanner scanUpToCharactersFromSet:stopCharacters intoString:&str]) {
			[result appendString:str];
			str = nil; // reset
		}
		
		if ([scanner scanString:@"<" intoString:NULL]) {
			if ([scanner scanString:@"!--" intoString:NULL]) {
				[scanner scanUpToString:@"-->" intoString:NULL]; 
				[scanner scanString:@"-->" intoString:NULL];
			}
			else {
				if ([scanner scanString:@"/" intoString:NULL]) {
					tagName = nil; dontReplaceTagWithSpace = NO;
					if ([scanner scanCharactersFromSet:tagNameCharacters intoString:&tagName]) {
						tagName = [tagName lowercaseString];
						dontReplaceTagWithSpace = ([tagName isEqualToString:@"a"] ||
												   [tagName isEqualToString:@"b"] ||
												   [tagName isEqualToString:@"i"] ||
												   [tagName isEqualToString:@"q"] ||
												   [tagName isEqualToString:@"span"] ||
												   [tagName isEqualToString:@"em"] ||
												   [tagName isEqualToString:@"strong"] ||
												   [tagName isEqualToString:@"cite"] ||
												   [tagName isEqualToString:@"abbr"] ||
												   [tagName isEqualToString:@"acronym"] ||
												   [tagName isEqualToString:@"label"]);
					}
					if (!dontReplaceTagWithSpace && result.length > 0 && ![scanner isAtEnd]) [result appendString:@" "];
				}
				[scanner scanUpToString:@">" intoString:NULL];
				[scanner scanString:@">" intoString:NULL];
			}
		}
		else {
			if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
				if (result.length > 0 && ![scanner isAtEnd]) [result appendString:@" "]; // Dont append space to beginning or end of result
			}
		}
	} while (![scanner isAtEnd]);
	
	[scanner release];
	NSString *retString = [[result stringByDecodingHTMLEntities] retain];
	[result release];
	[pool drain];
	return [retString autorelease];
}

- (NSString *)stringByDecodingHTMLEntities {
    return [NSString stringWithString:[self gtm_stringByUnescapingFromHTML]];
}

- (NSString *)stringByEncodingHTMLEntities {
    return [NSString stringWithString:[self gtm_stringByEscapingForAsciiHTML]];
}

- (NSString *)stringByEncodingHTMLEntities:(BOOL)isUnicode {
    return [NSString stringWithString:(isUnicode ? [self gtm_stringByEscapingForHTML] : [self gtm_stringByEscapingForAsciiHTML])];
}

- (NSString *)stringWithNewLinesAsBRs {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSScanner *scanner = [[NSScanner alloc] initWithString:self];
	[scanner setCharactersToBeSkipped:nil];
	NSMutableString *result = [[NSMutableString alloc] init];
	NSString *temp;
	NSCharacterSet *newLineCharacters = [NSCharacterSet characterSetWithCharactersInString:
										 [NSString stringWithFormat:@"\n\r%C%C%C%C", (unsigned short)0x0085, (unsigned short)0x000C, (unsigned short)0x2028, (unsigned short)0x2029]];
	// Scan
	do {
		temp = nil;
		[scanner scanUpToCharactersFromSet:newLineCharacters intoString:&temp];
		if (temp) [result appendString:temp];
		temp = nil;
		
		if ([scanner scanString:@"\r\n" intoString:nil]) {
			[result appendString:@"<br />"];
			
		}
		else if ([scanner scanCharactersFromSet:newLineCharacters intoString:&temp]) {
			if (temp) {
				for (NSUInteger i = 0; i < temp.length; i++) {
					[result appendString:@"<br />"];
				}
			}
		}
	} while (![scanner isAtEnd]);
	
	[scanner release];
	NSString *retString = [[NSString stringWithString:result] retain];
	[result release];
	[pool drain];
	return [retString autorelease];
}

- (NSString *)stringByRemovingNewLinesAndWhitespace {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSScanner *scanner = [[NSScanner alloc] initWithString:self];
	[scanner setCharactersToBeSkipped:nil];
	NSMutableString *result = [[NSMutableString alloc] init];
	NSString *temp;
	NSCharacterSet *newLineAndWhitespaceCharacters = [NSCharacterSet characterSetWithCharactersInString:
													  [NSString stringWithFormat:@" \t\n\r%C%C%C%C", (unsigned short)0x0085, (unsigned short)0x000C, (unsigned short)0x2028, (unsigned short)0x2029]];
	// Scan
	while (![scanner isAtEnd]) {
		
		temp = nil;
		[scanner scanUpToCharactersFromSet:newLineAndWhitespaceCharacters intoString:&temp];
		if (temp) [result appendString:temp];
		
		// Replace with a space
		if ([scanner scanCharactersFromSet:newLineAndWhitespaceCharacters intoString:NULL]) {
			if (result.length > 0 && ![scanner isAtEnd]) // Dont append space to beginning or end of result
				[result appendString:@" "];
		}
	}
	
	[scanner release];
	NSString *retString = [[NSString stringWithString:result] retain];
	[result release];
	
	[pool drain];
	return [retString autorelease];
}

- (NSString *)stringByLinkifyingURLs {
	if (!NSClassFromString(@"NSRegularExpression")) return self;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *pattern1 = @"\\B[#&](\\w+)\\b";
	// don't forget about (?:\B|(?!=[^\s,]#))[#&]([^\s,]+)
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern1 options:0 error:nil];
	NSString *modifiedString = [[regex stringByReplacingMatchesInString:self options:0 range:NSMakeRange(0, [self length]) withTemplate:@"$1\x04\x30\x30<a href=\"channel:$2\" class=\"channel\">$2</a>\x05"] retain];
	[pool drain];
	return [modifiedString autorelease];
}

- (NSString *)stringByStrippingTags {
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSUInteger ampIndex = [self rangeOfString:@"<" options:NSLiteralSearch].location;
	if (ampIndex == NSNotFound) {
		return [NSString stringWithString:self]; // return copy of string as no tags found
	}
	
	NSScanner *scanner = [NSScanner scannerWithString:self];
	[scanner setCharactersToBeSkipped:nil];
	NSMutableSet *tags = [[NSMutableSet alloc] init];
	NSString *tag;
	do {
		tag = nil;
		[scanner scanUpToString:@"<" intoString:NULL];
		[scanner scanUpToString:@">" intoString:&tag];
		
		// Add to set
		if (tag) {
			NSString *t = [[NSString alloc] initWithFormat:@"%@>", tag];
			[tags addObject:t];
			[t release];
		}
		
	} while (![scanner isAtEnd]);
	
	// Strings
	NSMutableString *result = [[NSMutableString alloc] initWithString:self];
	NSString *finalString;
	
	// Replace tags
	NSString *replacement;
	for (NSString *t in tags) {
		replacement = @" ";
		if ([t isEqualToString:@"<a>"] ||
			[t isEqualToString:@"</a>"] ||
			[t isEqualToString:@"<span>"] ||
			[t isEqualToString:@"</span>"] ||
			[t isEqualToString:@"<strong>"] ||
			[t isEqualToString:@"</strong>"] ||
			[t isEqualToString:@"<em>"] ||
			[t isEqualToString:@"</em>"]) {
			replacement = @"";
		}
		[result replaceOccurrencesOfString:t withString:replacement options:NSLiteralSearch range:NSMakeRange(0, result.length)];
	}
	
	finalString = [[result stringByRemovingNewLinesAndWhitespace] retain];
	[result release];
	[tags release];
	[pool drain];
    return [finalString autorelease];
	
}
#define RENDER_WITH_OPTS [ret appendString:[istring substringWithRange:NSMakeRange(lpos, cpos-lpos)]];
- (NSString*)stringByStrippingIRCMetadata {
    unsigned int cpos = 0;
    unsigned int lpos = 0;
    BOOL isNick = NO;
    NSString* istring = self;
    NSMutableString* ret = [NSMutableString stringWithCapacity:[self length]];
    while (cpos - [istring length]) {
        switch ([istring characterAtIndex:cpos++]) {
            case RCIRCAttributeBold:
                RENDER_WITH_OPTS;
                lpos = cpos;
                break;
            case RCIRCAttributeItalic:;;
                RENDER_WITH_OPTS;
                lpos = cpos;
                break;
            case RCIRCAttributeUnderline:;;
                RENDER_WITH_OPTS;
                lpos = cpos;
                break;
            case RCIRCAttributeReset:;;
                RENDER_WITH_OPTS;
                lpos = cpos;
                break;
            case RCIRCAttributeColor:;;
                RENDER_WITH_OPTS;
                BOOL itc = YES;
                int a=0,b=0;
                if (readNumber(&a, &itc, &cpos, istring) && itc) {
                    NSLog(@"comma!");
                    itc = NO;
                    readNumber(&b, &itc, &cpos, istring);
                } 
                NSLog(@"Using %d and %d (%d,%d) [%@]", a, b, cpos, lpos, [istring substringFromIndex:cpos]);
                // BOOL readNumber(int* num, BOOL* isThereComma, int* size_of_num, char* data, int size);
                lpos = cpos;
                break;
            case RCIRCAttributeInternalNickname:;;
                RENDER_WITH_OPTS;
				cpos+=2;
                lpos = cpos;
                break;
            case RCIRCAttributeInternalNicknameEnd:;;
                RENDER_WITH_OPTS;
                isNick = NO;
                lpos = cpos;
                break;
            default:
                continue;
                break;
        }
        continue;
    }
skcolor:
    RENDER_WITH_OPTS;
    return [[ret copy] autorelease];
}

@end