//
//  C4GlobalShapeAttributes.m
//  C4A
//
//  Created by moi on 11-02-28.
//  Copyright 2011 Travis Kirton. All rights reserved.
//

#import "C4GlobalShapeAttributes.h"
static C4GlobalShapeAttributes *sharedC4GlobalShapeAttributes;

@implementation C4GlobalShapeAttributes

//BOOL
@synthesize useFill, useStroke, checkShape, drawShapesToPDF, firstPoint, isClean;

//C4Color
@synthesize fillColor, strokeColor;

//NSInteger
@synthesize ellipseMode, rectMode;

//CGFloat
@synthesize strokeWidth;

//CGPathRef
@synthesize currentShape;

//CGContextRef
@synthesize pdfContext;

//NSBezierPath
@synthesize vertexPath;

#pragma mark Singleton

-(id) init
{
    if((self = [super init]))
    {
        strokeWidth = 1.0f;
        fillColor = [[C4Color colorWithGrey:1] retain];		//white
        strokeColor = [[C4Color	colorWithGrey:0] retain];	//black
        ellipseMode = CENTER;
        rectMode = CORNER;
        
        useFill = YES;
        useStroke = YES;
        checkShape = NO;
        firstPoint	= YES;
        drawShapesToPDF = NO;
        
        rectMode = CORNER;
        ellipseMode = CENTER;    
    }
    
    return self;
}

-(void)_dealloc {
}

+ (C4GlobalShapeAttributes*)sharedManager
{
    if (sharedC4GlobalShapeAttributes == nil) {
        static dispatch_once_t once;
        dispatch_once(&once, ^ { sharedC4GlobalShapeAttributes = [[super allocWithZone:NULL] init]; 
        });
        return sharedC4GlobalShapeAttributes;
        
        
    }
    return sharedC4GlobalShapeAttributes;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedManager] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

@end
