//
//  C4Font.m
//  C4A
//
//  Created by Travis Kirton on 11-01-30.
//  Copyright 2011 Travis Kirton. All rights reserved.
//

#import "C4Font.h"

@implementation C4Font
@synthesize font;

+(void)load {
	if(VERBOSELOAD) printf("C4Font\n");
}

-(id)init {
	if(!(self = [super init])) return nil;
	return self;
}

-(id)initWithName:(id)name {
	return [self initWithName:name size:14.0f];
}

-(id)initWithName:(id)name size:(CGFloat)size {
	if([name isKindOfClass:[NSString class]]) {
		self.font = [NSFont fontWithName:(NSString *)name size:size];
		return self;
	} else if ([name isKindOfClass:[C4String class]]) {
		self.font = [NSFont fontWithName:((C4String *)name).string size:size];
		return self;
	}
	return nil;
}

-(id)initWithFont:(id)aFont {
	if([aFont isKindOfClass:[NSFont class]]) {
		self.font = (NSFont *)aFont;
		return self;
	} else if ([aFont isKindOfClass:[C4Font class]]) {
		self.font = ((C4Font *)aFont).font;
		return self;
	}
	return nil;
}

+(C4Font *)fontWithFont:(id)aFont {
	return [[[C4Font alloc] initWithFont:aFont] autorelease];
}

+(C4Font *)fontWithName:(id)name {
	return [[[C4Font alloc] initWithName:name size:14.0f] autorelease];
}

+(C4Font *)fontWithName:(id)name size:(CGFloat)size {
	return [[[C4Font alloc] initWithName:name size:size] autorelease];
}

+(C4Font *)userFontOfSize:(CGFloat)size {
	return [C4Font fontWithFont:[NSFont userFontOfSize:size]];
}

+(C4Font *)boldSystemFontOfSize:(CGFloat)size {
	return [C4Font fontWithFont:[NSFont boldSystemFontOfSize:size]];
}

+(C4Font *)messageFontOfSize:(CGFloat)size {
	return [C4Font fontWithFont:[NSFont messageFontOfSize:size]];
}

+(C4Font *)systemFontOfSize:(CGFloat)size {
	return [C4Font fontWithFont:[NSFont systemFontOfSize:size]];
}

+(CGFloat)smallSystemFontSize {
	return [NSFont smallSystemFontSize];
}

+(CGFloat)systemFontSize {
	return [NSFont systemFontSize];
}


-(CGFloat)ascender {
	return self.font.ascender;
}

-(CGFloat)capHeight {
	return self.font.capHeight;
}

-(CGFloat)descender {
	return self.font.descender;
}

-(CGFloat)italicAngle {
	return self.font.italicAngle;
}

-(CGFloat)leading {
	return self.font.leading;
}

-(CGFloat)pointSize {
	return self.font.pointSize;
}

-(CGFloat)underlinePosition {
	return self.font.underlinePosition;
}

-(CGFloat)underlineThickness {
	return self.font.underlineThickness;
}

-(CGFloat)xHeight {
	return self.font.xHeight;
}


-(C4String *)displayName {
	return [C4String stringWithString:self.font.displayName];
}

-(C4String *)familyName {
	return [C4String stringWithString:self.font.familyName];
}

-(C4String *)fontName {
	return [C4String stringWithString:self.font.fontName];
}

+(NSArray *)availableFonts {
	return [[NSFontManager sharedFontManager] availableFonts];
}

@end
