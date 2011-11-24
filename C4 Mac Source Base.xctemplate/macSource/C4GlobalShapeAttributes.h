//
//  C4GlobalShapeAttributes.h
//  C4A
//
//  Created by moi on 11-02-28.
//  Copyright 2011 Travis Kirton. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "C4Object.h"

@interface C4GlobalShapeAttributes : C4Object {
    BOOL useFill, useStroke, checkShape, firstPoint, drawShapesToPDF, isClean;
    
    CGContextRef pdfContext;
    
    NSInteger rectMode, ellipseMode;
    
    CGFloat strokeWidth;
    
    C4Color		*fillColor;
    C4Color		*strokeColor;
    NSBezierPath	*vertexPath;
    CGFloat			fillColorComponents[4];
    CGFloat			strokeColorComponents[4];
    
    CGMutablePathRef currentShape;
}

+(C4GlobalShapeAttributes *)sharedManager;

@property(readwrite) NSInteger rectMode, ellipseMode;
@property(readwrite) CGFloat strokeWidth;
@property(readwrite) BOOL useFill, useStroke, checkShape, firstPoint, drawShapesToPDF, isClean;
@property(readwrite) CGContextRef pdfContext;
@property(readwrite,retain) C4Color *fillColor, *strokeColor;
@property(readwrite) CGMutablePathRef currentShape;
@property(readwrite, retain) NSBezierPath *vertexPath;
@end
