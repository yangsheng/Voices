
//  Created by Greg Price

#import "NSString+Additions.h"
#import <CommonCrypto/CommonDigest.h>



@implementation NSString (Additions)


- (NSString *)stringByURLEncoding
{
	NSString *_mlfilterChars = @";/?:@&=+$,";
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
													 NULL, 
													 (__bridge CFStringRef)self,
													 NULL, 
													 (__bridge CFStringRef)_mlfilterChars,
													 kCFStringEncodingUTF8);
}

- (NSString *)stringByHtmlifying {
	return [self stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
}

- (NSString *)uncapitalizeFirstCharacter {
	NSString *firstCharacter = [[self substringToIndex:1] lowercaseString];
	NSString *lastPart = [self substringFromIndex:1];
	
	return [NSString stringWithFormat:@"%@%@", firstCharacter, lastPart];	
}

- (NSString *)capitalizeFirstCharacter {
	NSString *firstCharacter = [[self substringToIndex:1] uppercaseString];
	NSString *lastPart = [self substringFromIndex:1];
	
	return [NSString stringWithFormat:@"%@%@", firstCharacter, lastPart];	
}

+ (NSString *)localizedDateStringWithUnixTimestamp:(NSInteger)unixTimeStamp withTime:(BOOL)withTime {
	//get the game date in gmt/utc
	NSDate *gameDate = [NSDate dateWithTimeIntervalSince1970:unixTimeStamp];
	
	//get the user's local time zone and a localized time zone string
	NSTimeZone *systemZone = [NSTimeZone systemTimeZone];
//	NSString *timeZoneString = [systemZone localizedName:NSTimeZoneNameStyleShortStandard locale:[NSLocale currentLocale]];
//	if ([systemZone isDaylightSavingTimeForDate:[NSDate date]]){
//		timeZoneString = [systemZone localizedName:NSTimeZoneNameStyleShortDaylightSaving locale:[NSLocale currentLocale]];
//	}
	
	//format the date correctly
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setTimeZone:systemZone];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[dateFormatter setDateFormat:@"d"];
	NSString *ordinalDay = [NSString ordinalStringForNumber:[[dateFormatter stringFromDate:gameDate] intValue]];
	[dateFormatter setDateFormat:@"MMMM"];
	NSString *monthName = [dateFormatter stringFromDate:gameDate];
	[dateFormatter setDateFormat:@"h:mma"];
	NSString *timeStr = [dateFormatter stringFromDate:gameDate];
	
	NSString *format = withTime ? @"%@ %@ AT %@" : @"%@ %@";
	
	NSString *dateString = [[NSString stringWithFormat:format, monthName, ordinalDay, timeStr] uppercaseString];
	
	return dateString;
}

+ (NSString*)ordinalStringForNumber:(NSInteger)num {
    NSString *ending;	
    int ones = num % 10;
    int tens = floor(num / 10);
    tens = tens % 10;
    if(tens == 1) {
        ending = @"th";
    } else {
        switch (ones) {
            case 1:
                ending = @"st";
                break;
            case 2:
                ending = @"nd";
                break;
            case 3:
                ending = @"rd";
                break;
            default:
                ending = @"th";
                break;
        }
    }
    return [NSString stringWithFormat:@"%d%@", num, ending];
}

- (NSString *) md5 {
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
    return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];  
}

- (NSString *)stringByStrippingExtraWhiteSpace {
    if ([self length] <= 5) {
        return self;
    }
    NSString *doubleTrimmed = [self stringByReplacingOccurrencesOfString:@"[ \r\n\t]+" withString:@" " options:NSRegularExpressionSearch range:NSMakeRange(0, [self length])];
    return [doubleTrimmed stringByReplacingOccurrencesOfString:@"^[ \r\n\t]+(.*)[ \r\n\t]+$" withString:@"$1" options:NSRegularExpressionSearch range:NSMakeRange(0, [doubleTrimmed length])]; 
}

+ (NSString *)base64StringFromData:(NSData *)data length:(int)length {
    
    static char base64EncodingTable[64] = {
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
        'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
        'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
        'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/'
    };
    
	unsigned long ixtext, lentext;
	long ctremaining;
	unsigned char input[3], output[4];
	short i, charsonline = 0, ctcopy;
	const unsigned char *raw;
	NSMutableString *result;
	
	lentext = [data length]; 
	if (lentext < 1)
		return @"";
	result = [NSMutableString stringWithCapacity: lentext];
	raw = [data bytes];
	ixtext = 0; 
	
	while (true) {
		ctremaining = lentext - ixtext;
		if (ctremaining <= 0) 
			break;        
		for (i = 0; i < 3; i++) { 
			unsigned long ix = ixtext + i;
			if (ix < lentext)
				input[i] = raw[ix];
			else
				input[i] = 0;
		}
		output[0] = (input[0] & 0xFC) >> 2;
		output[1] = ((input[0] & 0x03) << 4) | ((input[1] & 0xF0) >> 4);
		output[2] = ((input[1] & 0x0F) << 2) | ((input[2] & 0xC0) >> 6);
		output[3] = input[2] & 0x3F;
		ctcopy = 4;
		switch (ctremaining) {
			case 1: 
				ctcopy = 2; 
				break;
			case 2: 
				ctcopy = 3; 
				break;
		}
		
		for (i = 0; i < ctcopy; i++)
			[result appendString: [NSString stringWithFormat: @"%c", base64EncodingTable[output[i]]]];
		
		for (i = ctcopy; i < 4; i++)
			[result appendString: @"="];
		
		ixtext += 3;
		charsonline += 4;
		
		if ((length > 0) && (charsonline >= length))
			charsonline = 0;
	}	
	return result;
}


@end

