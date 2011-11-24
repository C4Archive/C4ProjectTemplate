//
//  C4String.m
//  Created by Travis Kirton
//

#import "C4String.h"
@interface C4String (private)
-(NSColor *)colorFromObject:(id)color;
-(CFDictionaryRef)CFDictionaryRefFrom:(NSDictionary *)dictionary;
@end

@implementation C4String

@synthesize string, attributes;

+(void)load {
	if(VERBOSELOAD) printf("C4String\n");
}

-(id)init {
	if(![super init]){
		return nil;
	}
	return self;
}

-(id)initWithString:(id)aString {

	if(!(self = [super init])) {
		return nil;
	}
	if([aString isKindOfClass:[NSString class]]) {
		self.string = (NSString *)aString;
		self.attributes = [[[NSMutableDictionary alloc] initWithCapacity:0] retain];
	}
	else if ([aString isKindOfClass:[C4String class]]) {
		self.string = ((C4String *)aString).string;
		self.attributes = ((C4String *)aString).attributes;
	}
	else {
		C4Log(@"Type is not C4String or NSString");
		return nil;
	}
    [C4GlobalStringAttributes sharedManager].drawStringsToPDF = NO;
	return self;
}

-(id)initWithFormat:(NSString *)aFormatString, ... {
	NSString *finalString;

	va_list args;
	va_start (args, aFormatString);
		finalString = [[[NSString alloc] initWithFormat:aFormatString arguments:args] autorelease];
	va_end (args);
	
	return [self initWithString:finalString];
}

-(void)dealloc {
	[self setString:nil];
	[self setAttributes:nil];
	[super dealloc];
}

-(C4String *)stringByAppendingString:(id)aString {
	NSString *newString;
	if([aString isKindOfClass:[NSString class]]) {
		newString = (NSString *)aString;
	}
	else if ([aString isKindOfClass:[C4String class]]) {
		newString = ((C4String *)aString).string;
	}
	else {
		C4Log(@"Type is not C4String or NSString");
		return nil;
	}
	return [C4String stringWithString:newString];
}

-(C4String *)stringByAppendingFormat:(NSString *)aFormatString, ... {
	NSString *newString;
	
	va_list args;
	va_start (args, aFormatString);
	newString = [[[NSString alloc] initWithFormat:aFormatString arguments:args] autorelease];
	va_end (args);

	NSString *s = [self.string stringByAppendingString:newString];
	return [C4String stringWithString:s];
}

-(NSInteger)length {
	return [self.string length];
}			

-(NSArray *)componentsSeparatedByString:(id)aString {
	NSString *separatorString;
	if([aString isKindOfClass:[NSString class]]) {
		separatorString = (NSString *)aString;
	}
	else if ([aString isKindOfClass:[C4String class]]) {
		separatorString = ((C4String *)aString).string;
	}
	else {
		C4Log(@"Type is not C4String or NSString");
		return nil;
	}
	NSArray *components = [self.string componentsSeparatedByString:separatorString];
	NSMutableArray *newArray = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
	for(NSString *s in components){
		[newArray addObject:[C4String stringWithString:s]];
	}
	
	return (NSArray *)newArray;
}

-(C4String *)stringByReplacingOccurencesOfString:(id)aString withString:(id)bString {
	NSString *firstString = @"";

	if([aString isKindOfClass:[NSString class]]) {
		firstString = (NSString *)aString;
	}
	else if ([aString isKindOfClass:[C4String class]]) {
		firstString = ((C4String *)aString).string;
	}

	NSString *secondString = @"";
	if([bString isKindOfClass:[NSString class]]) {
		secondString = (NSString *)bString;
	}
	else if ([bString isKindOfClass:[C4String class]]) {
		secondString = ((C4String *)bString).string;
	}
	
	NSString *newString = [self.string stringByReplacingOccurrencesOfString:firstString withString:secondString];
	return [C4String stringWithString:newString];
}


-(C4String *)substringFromIndex:(NSInteger)index {
	return [self substringWithRange:NSMakeRange(index, [self length]-index)];
}

-(C4String *)substringToIndex:(NSInteger)index {
	return [self substringWithRange:NSMakeRange(0,index)];
}

-(C4String *)substringWithRange:(NSRange)range {
	NSString *substring = [self.string substringWithRange:range];
	return [C4String stringWithString:substring];
}

-(BOOL)hasPrefix:(id)aString {
	NSString *prefix = @"";
	if([aString isKindOfClass:[NSString class]]) {
		prefix = (NSString *)aString;
	}
	else if ([aString isKindOfClass:[C4String class]]) {
		prefix = ((C4String *)aString).string;
	}
	return [self.string hasPrefix:prefix];
}

-(BOOL)hasSuffix:(id)aString {
	NSString *suffix = @"";
	if([aString isKindOfClass:[NSString class]]) {
		suffix = (NSString *)aString;
	}
	else if ([aString isKindOfClass:[C4String class]]) {
		suffix = ((C4String *)aString).string;
	}
	return [self.string hasSuffix:suffix];
}

-(void)capitalizedString {
	self.string = [self.string capitalizedString];
}

-(void)uppercaseString {
	self.string = [self.string uppercaseString];
}

-(void)lowercaseString {
	self.string = [self.string lowercaseString];
}

-(double)doubleValue {
	return [self.string doubleValue];
}

-(float)floatValue {
	return [self.string floatValue];
}

-(NSInteger)intValue {
	return [self.string intValue];
}

-(NSInteger)integerValue {
	return [self.string integerValue];
}

-(BOOL)boolValue {
	return [self.string boolValue];
}

-(void)drawAtPoint:(NSPoint)point {
	NSDictionary *attribs;
	if([self.attributes count] == 0){
		attribs = [[C4GlobalTypeAttributes sharedManager] attributes];
		[self drawAtPoint:point withAttributes:attribs];
		//C4Log(@"\n -- SharedManager Attributes At Draw-- \n %@ \n",[attribs description]);
	}
	else {
		[self drawAtPoint:point withAttributes:self.attributes];
		//C4Log(@"\n -- Instance Attributes At Draw-- \n %@ \n",[self.attributes description]);
	}
}

-(void)drawAtPoint:(NSPoint)point withAttributes:(NSDictionary *)attribs {
	[self.string drawAtPoint:point withAttributes:attribs];	
	if([C4GlobalStringAttributes sharedManager].drawStringsToPDF) {
        CFDictionaryRef C4ttribs = [[C4GlobalTypeAttributes sharedManager] CFDictionaryRefFrom:attribs];
		CFAttributedStringRef attributedString = CFAttributedStringCreate (kCFAllocatorDefault,
																		   (CFStringRef)self.string,
																		   C4ttribs);
		
		CTLineRef line = CTLineCreateWithAttributedString(attributedString);
        CGContextRef pdfContext = [C4GlobalStringAttributes sharedManager].pdfContext;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextSetFillColorSpace(pdfContext,colorSpace);
        NSColor *color = [[attribs objectForKey:NSForegroundColorAttributeName] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
		CGFloat components[4];
		[color getRed:&components[0] green: &components[1] blue: &components[2] alpha: &components[3]];		
		CGContextSetFillColor(pdfContext, components);	
		CGContextSaveGState(pdfContext);
		CGContextSetTextPosition(pdfContext,point.x,point.y);
		CTLineDraw(line,pdfContext);
		CGContextRestoreGState(pdfContext);
        CFRelease(line);
        CFRelease(attributedString);
        CFRelease(colorSpace);
	}
	
}

-(void)drawInRect:(NSRect)rect {
	if([self.attributes count] == 0) [self drawInRect:rect withAttributes:[[C4GlobalTypeAttributes sharedManager] attributes]];
	else [self drawInRect:rect withAttributes:self.attributes];
}

-(void)drawInRect:(NSRect)rect withAttributes:(NSDictionary *)attribs {
	[self.string drawInRect:rect withAttributes:attribs];
}

-(NSSize)size {
	return [self.string sizeWithAttributes:self.attributes];
}

-(NSSize)sizeWithAttributes:(NSDictionary *)attribs {
	return [self.string sizeWithAttributes:attribs];
}

-(void)font:(id)font {
	NSFont *newFont = [[[NSFont alloc] init] autorelease];
	if([font isKindOfClass:[NSFont class]]) newFont = (NSFont *)font;
	else if([font isKindOfClass:[C4Font class]]) newFont = ((C4Font *)font).font;
	[self.attributes setObject:newFont forKey:NSFontAttributeName];
}

-(void)fill:(float)grey {
	[self fillRed:grey green:grey blue:grey alpha:1];
}

-(void)fill:(float)grey alpha:(float)alpha {
	[self fillRed:grey green:grey blue:grey alpha:alpha];
}

-(void)fillRed:(float)red green:(float)green blue:(float)blue {
	[self fillRed:red green:green blue:blue alpha:1];
}

-(void)fillRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha{
	NSColor *newColor = [NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha];
	[self fillColor:newColor];
}

-(void)fillColor:(id)color {
	[self.attributes setObject:[C4Color colorFromObject:color] forKey:NSForegroundColorAttributeName];
	if ([self.attributes objectForKey:NSUnderlineStyleAttributeName] == nil) {
		[self.attributes setObject:[C4Color colorFromObject:color] forKey:NSUnderlineColorAttributeName];
	}
	//C4Log(@"\n-- Instance Attributes AFTER FILL-- \n %@ \n",[self.attributes description]);
}

-(void)strokeColor:(id)color {
	[self.attributes setObject:[C4Color colorFromObject:color] forKey:NSStrokeColorAttributeName];
}

-(void)stroke:(float)grey {
	[self strokeRed:grey green:grey blue:grey alpha:1];
}

-(void)stroke:(float)grey alpha:(float)alpha {
	[self strokeRed:grey green:grey blue:grey alpha:1];
}

-(void)strokeRed:(float)red green:(float)green blue:(float)blue {
	[self strokeRed:red green:green blue:blue alpha:1];
}

-(void)strokeRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha{
	NSColor *newColor = [NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha];
	[self.attributes setObject:newColor forKey:NSStrokeColorAttributeName];
}

-(void)strokeWidth:(float)width {
	[self.attributes setValue:[NSNumber numberWithFloat:-1*width] forKey:NSStrokeWidthAttributeName];
}

-(void)underlineColor:(id)color {
	[self.attributes setObject:[C4Color colorFromObject:color] forKey:NSUnderlineColorAttributeName];
}

-(void)backgroundColor:(id)color {
	[self.attributes setObject:[C4Color colorFromObject:color] forKey:NSBackgroundColorAttributeName];
}

-(void)strikethroughColor:(id)color {
	[self.attributes setObject:[C4Color colorFromObject:color] forKey:NSStrikethroughColorAttributeName];
}

-(void)underlineStyle:(NSInteger)style {
	if(style == NONE) {
		[self.attributes removeObjectForKey:NSUnderlineStyleAttributeName];
		[self.attributes removeObjectForKey:NSUnderlineColorAttributeName];
	} else if (style == SINGLE || style == DOUBLE || style == THICK ) {
		[self.attributes setValue:[NSNumber numberWithInteger:style] forKey:NSUnderlineStyleAttributeName];
		[self.attributes setObject:[self.attributes objectForKey:NSForegroundColorAttributeName]
							forKey:NSUnderlineColorAttributeName];
	} else {
		C4Log(@"underline style must be NONE, SINGLE, THICK, or DOUBLE) -> %d",style);
	}
}

-(void)strikethroughStyle:(NSInteger)style {
	if(style == NONE) {
		[self.attributes removeObjectForKey:NSStrikethroughStyleAttributeName];
		[self.attributes removeObjectForKey:NSStrikethroughColorAttributeName];
	} else if (style == SINGLE || style == DOUBLE || style == THICK ) {
		[self.attributes setValue:[NSNumber numberWithInteger:style] forKey:NSStrikethroughStyleAttributeName];
	} else {
		C4Log(@"strikethrough style must be NONE, SINGLE, THICK, or DOUBLE) -> %d",style);
	}
}

-(void)baselineOffset:(float)value {
	if(value <= 0.0f) [self.attributes removeObjectForKey:NSBaselineOffsetAttributeName];
	[self.attributes setValue:[NSNumber numberWithFloat:value] forKey:NSBaselineOffsetAttributeName];
}

-(void)kern:(float)value {
	if(value <= 0.0f) [self.attributes removeObjectForKey:NSKernAttributeName];
	[self.attributes setValue:[NSNumber numberWithFloat:value] forKey:NSKernAttributeName];
}

-(void)noFill {
	[self.attributes removeObjectForKey:NSForegroundColorAttributeName];
}

-(void)noStroke {
	[self.attributes removeObjectForKey:NSStrokeWidthAttributeName];
	[self.attributes removeObjectForKey:NSStrokeColorAttributeName];
}


// change global settings in GlobalTypeAttributes
+(void)font:(id)font {
    NSFont *newFont = [[[NSFont alloc] init] autorelease];
	if([font isKindOfClass:[NSFont class]]){
        newFont = (NSFont *)font;
    }
	else if([font isKindOfClass:[C4Font class]]) newFont = ((C4Font *)font).font;
	[[C4GlobalTypeAttributes sharedManager] setObject:newFont forKey:NSFontAttributeName];
}

+(void)fill:(float)grey {
	[C4String fillRed:grey green:grey blue:grey alpha:1.0f];
}

+(void)fill:(float)grey alpha:(float)alpha {
	[C4String fillRed:grey green:grey blue:grey alpha:alpha];
}

+(void)fillRed:(float)red green:(float)green blue:(float)blue {
	[C4String fillRed:red green:green blue:blue alpha:1.0f];
}

+(void)fillRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha{
	NSColor *newColor = [NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha];
	[C4String fillColor:newColor];
}

+(void)fillColor:(id)color {
	NSColor *aColor = [C4Color colorFromObject:color];
	[[C4GlobalTypeAttributes sharedManager] setObject:aColor forKey:NSForegroundColorAttributeName];
	if ([[C4GlobalTypeAttributes sharedManager] objectForKey:NSUnderlineStyleAttributeName] == nil) {
		[[C4GlobalTypeAttributes sharedManager] setObject:[C4Color colorFromObject:color] forKey:NSUnderlineColorAttributeName];
	}
	//C4Log(@"\n-- SharedManager Attributes At Fill-- \n %@ \n",[[C4GlobalTypeAttributes sharedManager].attributes description]);
}

+(void)strokeColor:(id)color {
	[[C4GlobalTypeAttributes sharedManager] setObject:[C4Color colorFromObject:color] forKey:NSStrokeColorAttributeName];
}

+(void)stroke:(float)grey {
	[self strokeRed:grey green:grey blue:grey alpha:1];
}

+(void)stroke:(float)grey alpha:(float)alpha {
	[self strokeRed:grey green:grey blue:grey alpha:1];
}

+(void)strokeRed:(float)red green:(float)green blue:(float)blue {
	[self strokeRed:red green:green blue:blue alpha:1];
}

+(void)strokeRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha{
	NSColor *newColor = [NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha];
	[[C4GlobalTypeAttributes sharedManager] setObject:newColor forKey:NSStrokeColorAttributeName];
}

+(void)strokeWidth:(float)width {
	if (width < 0.1f){
		width = 0.1f;
		NSLog(@"stroke width set to 0.1, it cannot be smaller than this");
	}
	[[C4GlobalTypeAttributes sharedManager] setValue:[NSNumber numberWithFloat:width] forKey:NSStrokeWidthAttributeName];
}

+(void)underlineColor:(id)color {
	[[C4GlobalTypeAttributes sharedManager] setObject:[C4Color colorFromObject:color] forKey:NSUnderlineColorAttributeName];
}

+(void)backgroundColor:(id)color {
	[[C4GlobalTypeAttributes sharedManager] setObject:[C4Color colorFromObject:color] forKey:NSBackgroundColorAttributeName];
}

+(void)strikethroughColor:(id)color {
	[[C4GlobalTypeAttributes sharedManager] setObject:[C4Color colorFromObject:color] forKey:NSStrikethroughColorAttributeName];
}

+(void)underlineStyle:(NSInteger)style {
	if(style == NONE) {
		[[C4GlobalTypeAttributes sharedManager] removeObjectForKey:NSUnderlineStyleAttributeName];
		[[C4GlobalTypeAttributes sharedManager] removeObjectForKey:NSUnderlineColorAttributeName];
	}
	if(style == SINGLE || style == DOUBLE || style == THICK ) {
		[[C4GlobalTypeAttributes sharedManager] setValue:[NSNumber numberWithInteger:style] forKey:NSUnderlineStyleAttributeName];
	} else {
		C4Log(@"underline style must be NONE, SINGLE, THICK, or DOUBLE) -> %d",style);
	}

}

+(void)strikethroughStyle:(NSInteger)style {
	if(style == NONE) {
		[[C4GlobalTypeAttributes sharedManager] removeObjectForKey:NSStrikethroughStyleAttributeName];
		[[C4GlobalTypeAttributes sharedManager] removeObjectForKey:NSStrikethroughColorAttributeName];
	}
	else if(style == SINGLE || style == DOUBLE || style == THICK ) {
		[[C4GlobalTypeAttributes sharedManager] setValue:[NSNumber numberWithInteger:style] forKey:NSStrikethroughStyleAttributeName];
	} else {
		C4Log(@"strikethrough style must be NONE, SINGLE, THICK, or DOUBLE) -> %d",style);
	}
}

+(void)baselineOffset:(float)value {
	if(value <= 0.0f) [[C4GlobalTypeAttributes sharedManager] removeObjectForKey:NSBaselineOffsetAttributeName];
	[[C4GlobalTypeAttributes sharedManager] setValue:[NSNumber numberWithFloat:value] forKey:NSBaselineOffsetAttributeName];
}

+(void)kern:(float)value {
	if(value <= 0.0f) [[C4GlobalTypeAttributes sharedManager] removeObjectForKey:NSKernAttributeName];
	[[C4GlobalTypeAttributes sharedManager] setValue:[NSNumber numberWithFloat:value] forKey:NSKernAttributeName];
}

+(void)noFill {
	[[C4GlobalTypeAttributes sharedManager] removeObjectForKey:NSForegroundColorAttributeName];
}

+(void)noStroke {
	[[C4GlobalTypeAttributes sharedManager] removeObjectForKey:NSStrokeWidthAttributeName];
	[[C4GlobalTypeAttributes sharedManager] removeObjectForKey:NSStrokeColorAttributeName];
}

+(C4String *)stringWithString:(id)aString {
	return [[[C4String alloc] initWithString:aString] autorelease];
}

+(C4String *)stringWithFormat:(NSString *)aFormatString, ... {
	NSString *finalString;
	
	va_list args;
	va_start (args, aFormatString);
	finalString = [[[NSString alloc] initWithFormat:aFormatString arguments:args] autorelease];
	va_end (args);
	
	return [C4String stringWithString:finalString];	
}

+(void)beginDrawStringsToPDFContext:(CGContextRef)context {
	C4Log(@"beginDrawStringsToPDFContext");
	[C4GlobalStringAttributes sharedManager].pdfContext = context;
	[C4GlobalStringAttributes sharedManager].drawStringsToPDF = YES;
	[C4GlobalStringAttributes sharedManager].isClean = NO;
}

+(void)endDrawStringsToPDFContext {
	[C4GlobalStringAttributes sharedManager].drawStringsToPDF = NO;
    [C4GlobalStringAttributes sharedManager].pdfContext = nil;
	[C4GlobalStringAttributes sharedManager].isClean = YES;
	C4Log(@"endDrawStringsToPDFContext");
}

+(C4String *)globalAttributes {
	return [[C4GlobalTypeAttributes sharedManager] description];
}

-(NSString *)description {
	return self.string;
}

+(NSString *)nsStringFromObject:(id)object {
	if([object isKindOfClass:[NSString class]]) {
		return (NSString *)object;
	} else if ([object isKindOfClass:[C4String class]]) {
		return ((C4String *)object).string;
	}
	C4Log(@"object must be C4String or NSString");
	return nil;
}

@end
