//
//  C4Color.m
//  Created by Travis Kirton
//

#import "C4Color.h"

@implementation C4Color

@synthesize color;

+(void)load {
	if(VERBOSELOAD) printf("C4Color\n");
}

+(C4Color *)colorWithGrey:(CGFloat)grey {
	return [self colorWithRed:grey green:grey blue:grey alpha:1.0f];
}

+(C4Color *)colorWithGrey:(CGFloat)grey alpha:(CGFloat)alpha {
	return [self colorWithRed:grey green:grey blue:grey alpha:alpha];
}

+(C4Color *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
	return [self colorWithRed:red green:green blue:blue alpha:1.0f];
}
																			
+(C4Color *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
	return [[[C4Color alloc] initWithRed:red green:green blue:blue alpha:alpha] autorelease];
}

+(C4Color *)colorWithNSColor:(NSColor *)aColor {
	return [[[C4Color alloc] initWithNSColor:aColor] autorelease];
}

+(NSColor *)colorFromObject:(id)aColor {
	NSColor *newColor;
	if ([aColor isKindOfClass:[NSColor class]]) {
		newColor = (NSColor *)aColor;
	} else if ([aColor isKindOfClass:[C4Color class]]) {
		newColor = (NSColor *)[(C4Color *)aColor nsColor];
	} else {
		C4Log(@"color object must be NSColor or C4Color");
		return nil;
	}
	return newColor;
}

-(id)init {
	[self initWithGrey:0];
	return self;
}

-(id)initWithGrey:(CGFloat)grey {
	return [self initWithRed:grey green:grey blue:grey alpha:1.0f];
}

-(id)initWithGrey:(CGFloat)grey alpha:(CGFloat)alpha {
	return [self initWithRed:grey green:grey blue:grey alpha:alpha];
}

-(id)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
	return [self initWithRed:red green:green blue:blue alpha:1.0f];
}

-(id)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha {
	if(![super init]) {
		return nil;
	}
	[self setColor:[NSColor colorWithCalibratedRed:red green:green blue:blue alpha:alpha]];
	return self;
}

-(id)initWithNSColor:(NSColor *)aColor {
	if(![super init]) {
		return nil;
	}
	[self setColor:aColor];
	return self;
}

-(void)dealloc {
	[self setColor:nil];
	[super dealloc];
}

-(void)set {
	[color set];
}

-(CGColorRef)cgColor {
    CGColorRef returnColor = (CGColorRef)[(id)CGColorCreateGenericRGB([color redComponent], [color greenComponent], [color blueComponent], [color alphaComponent]) autorelease];
    return returnColor;
}

-(NSColor *)nsColor {
	return color;
}

-(CGFloat)redComponent {
	return [color redComponent];
}

-(CGFloat)greenComponent {
	return [color greenComponent];
}

-(CGFloat)blueComponent {
	return [color blueComponent];
}

-(CGFloat)alphaComponent {
    return [color alphaComponent];
}

+(CGColorRef)NSColorToCGColor:(NSColor *)aColor {
	aColor = [aColor colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	CGColorRef returnColor =  (CGColorRef)[(id)CGColorCreateGenericRGB([aColor redComponent], [aColor greenComponent], [aColor blueComponent], [aColor alphaComponent]) autorelease];
    
    return returnColor;
}
@end