//
//  C4String.h
//  Created by Travis Kirton
//

#import <Cocoa/Cocoa.h>

/*
 advice from cocoa-dev: change method names, change C4 prefix...
 
 NOT TOO SERIOUS
 CFAttributedString objects have problems in drawing underlines and strikethrough.
 
 In particular, there are NO strikethrough options for drawing and the underline objects appear over top of one another.
 I wonder if Apple will fix these in the future... Not entirely essential...
 
 */

@interface C4String : C4Object {
	NSString			*string;
	NSMutableDictionary	*attributes;
}
/*
 Instance Methods
 */
-(id)initWithString:(id)aString;
-(id)initWithFormat:(NSString *)aFormatString, ...;
-(C4String *)stringByAppendingString:(id)aString;
-(C4String *)stringByAppendingFormat:(NSString *)aFormatString, ...;
-(C4String *)substringWithRange:(NSRange)range;
-(C4String *)substringFromIndex:(NSInteger)index;
-(C4String *)substringToIndex:(NSInteger)index;
-(C4String *)stringByReplacingOccurencesOfString:(id)aString withString:(id)bString;
-(NSArray *)componentsSeparatedByString:(id)aString;

-(BOOL)hasPrefix:(id)aString;
-(BOOL)hasSuffix:(id)aString;
-(void)capitalizedString;
-(void)lowercaseString;
-(void)uppercaseString;

-(NSInteger) length;

-(double)doubleValue;
-(float)floatValue;
-(NSInteger)intValue;
-(NSInteger)integerValue;
-(BOOL)boolValue;

-(void)drawAtPoint:(NSPoint)point;
-(void)drawAtPoint:(NSPoint)point withAttributes:(NSDictionary *)attribs;
-(void)drawInRect:(NSRect)rect;
-(void)drawInRect:(NSRect)rect withAttributes:(NSDictionary *)attribs;


-(NSSize)size;
-(NSSize)sizeWithAttributes:(NSDictionary *)attribs;

-(void)font:(id)font;

-(void)fillColor:(id)color;
-(void)fill:(float)grey;
-(void)fill:(float)grey alpha:(float)alpha;
-(void)fillRed:(float)red green:(float)green blue:(float)blue;
-(void)fillRed:(float)red green:(float)green blue:(float)blue alpha:(float)a;
-(void)strokeColor:(id)color;
-(void)stroke:(float)grey;
-(void)stroke:(float)grey alpha:(float)alpha;
-(void)strokeRed:(float)red green:(float)green blue:(float)blue;
-(void)strokeRed:(float)red green:(float)green blue:(float)blue alpha:(float)a;
-(void)strokeWidth:(float)width;
-(void)underlineColor:(id)color;
-(void)underlineStyle:(NSInteger)style;
-(void)strikethroughColor:(id)color;
-(void)strikethroughStyle:(NSInteger)style;
-(void)backgroundColor:(id)color;
-(void)baselineOffset:(float)value;
-(void)kern:(float)value;

-(void)noFill;
-(void)noStroke;

/*
 Class Methods
 */
+(C4String *)stringWithString:(id)aString;
+(C4String *)stringWithFormat:(NSString *)aFormatString, ...;

// change global settings in GlobalTypeAttributes
+(void)font:(id)font;
+(void)fillColor:(id)color;
+(void)fill:(float)grey;
+(void)fill:(float)grey alpha:(float)alpha;
+(void)fillRed:(float)red green:(float)green blue:(float)blue;
+(void)fillRed:(float)red green:(float)green blue:(float)blue alpha:(float)a;
+(void)strokeColor:(id)color;
+(void)stroke:(float)grey;
+(void)stroke:(float)grey alpha:(float)alpha;
+(void)strokeRed:(float)red green:(float)green blue:(float)blue;
+(void)strokeRed:(float)red green:(float)green blue:(float)blue alpha:(float)a;
+(void)strokeWidth:(float)width;
+(void)underlineColor:(id)color;
+(void)underlineStyle:(NSInteger)style;
+(void)strikethroughColor:(id)color;
+(void)strikethroughStyle:(NSInteger)style;
+(void)backgroundColor:(id)color;
+(void)baselineOffset:(float)value;
+(void)kern:(float)value;
+(void)noFill;
+(void)noStroke;

+(C4String *)globalAttributes;

+(void)beginDrawStringsToPDFContext:(CGContextRef)context;
+(void)endDrawStringsToPDFContext;

+(NSString *)nsStringFromObject:(id)object;

@property(readwrite, retain) NSString *string;
@property(readwrite, retain) NSMutableDictionary *attributes;
@end