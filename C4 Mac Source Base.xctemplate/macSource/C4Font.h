//
//  C4Font.h
//  C4A
//
//  Created by Travis Kirton on 11-01-30.
//  Copyright 2011 Travis Kirton. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface C4Font : C4Object {
	NSFont *font;
}

-(id)init;
-(id)initWithName:(id)name;
-(id)initWithName:(id)name size:(CGFloat)size;
-(id)initWithFont:(id)aFont;

+(C4Font *)fontWithFont:(id)aFont;
+(C4Font *)fontWithName:(id)name size:(CGFloat)size;
+(C4Font *)userFontOfSize:(CGFloat)size;
+(C4Font *)boldSystemFontOfSize:(CGFloat)size;
+(C4Font *)messageFontOfSize:(CGFloat)size;
+(C4Font *)systemFontOfSize:(CGFloat)size;

+(CGFloat)smallSystemFontSize;
+(CGFloat)systemFontSize;

+(NSArray *)availableFonts;

-(CGFloat)ascender;
-(CGFloat)capHeight;
-(CGFloat)descender;
-(CGFloat)italicAngle;
-(CGFloat)leading;
-(CGFloat)pointSize;
-(CGFloat)underlinePosition;
-(CGFloat)underlineThickness;
-(CGFloat)xHeight;

-(C4String *)displayName;
-(C4String *)familyName;
-(C4String *)fontName;

@property(readwrite, retain) NSFont *font;
@end