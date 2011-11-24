//
//  C4Color.h
//  Created by Travis Kirton
//

#import <Cocoa/Cocoa.h>

@interface C4Color : C4Object {
	@private
	NSColor *color;
}

+(C4Color *)colorWithGrey:(CGFloat)grey;
+(C4Color *)colorWithGrey:(CGFloat)grey alpha:(CGFloat)alpha;
+(C4Color *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
+(C4Color *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+(C4Color *)colorWithNSColor:(NSColor *)aColor;
+(NSColor *)colorFromObject:(id)aColor;
+(CGColorRef)NSColorToCGColor:(NSColor *)aColor;

-(id)initWithGrey:(CGFloat)grey;
-(id)initWithGrey:(CGFloat)grey alpha:(CGFloat)alpha;
-(id)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
-(id)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
-(id)initWithNSColor:(NSColor *)aColor;

-(void)set;

-(CGColorRef)cgColor;
-(NSColor *)nsColor;

-(CGFloat)redComponent;
-(CGFloat)greenComponent;
-(CGFloat)blueComponent;
-(CGFloat)alphaComponent;

@property(readwrite,retain) NSColor *color;
@end
