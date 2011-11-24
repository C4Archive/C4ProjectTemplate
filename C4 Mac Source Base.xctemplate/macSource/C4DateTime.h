//
//  C4DateTime.h
//  Created by Travis Kirton
//

#import <Cocoa/Cocoa.h>

@interface C4DateTime : C4Object {
	@private
    NSCalendar *gregorian;
}

#pragma mark Singleton
+(C4DateTime *)sharedManager;

#pragma mark Date & Time
+(NSInteger)day;
+(NSString *)dayString;
+(NSString *)daySuffix;
+(NSInteger)hour;
+(NSString *)hourString;
+(NSInteger)minute;
+(NSString *)minuteString;
+(NSInteger)week;
+(NSString *)weekString;
+(NSInteger)month;
+(NSInteger)millis;
+(NSString *)monthString;
+(NSInteger)second;
+(NSString *)secondString;
+(NSInteger)year;
+(NSInteger)weekday;
+(NSString *)weekdayString;
+(NSString *)dayName;
+(NSString *)monthName;

-(NSString *)dayName;
-(NSString *)monthName;

-(NSInteger)day;
-(NSString *)dayString;
-(NSString *)daySuffix;
-(NSInteger)hour;
-(NSString *)hourString;
-(NSInteger)minute;
-(NSString *)minuteString;
-(NSInteger)week;
-(NSString *)weekString;
-(NSInteger)month;
-(NSString *)monthString;
-(NSInteger)millis;

-(NSInteger)second;
-(NSString *)secondString;
-(NSInteger)year;

-(NSInteger)weekday;
-(NSString *)weekdayString;

@end
