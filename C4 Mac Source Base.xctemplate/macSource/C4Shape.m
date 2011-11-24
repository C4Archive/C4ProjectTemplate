//
//  C4Shape.m
//  Created by Travis Kirton
//

#import "C4Shape.h"

static C4Shape *sharedC4Shape;

@interface C4Shape (private)
+(void)fillColorSet;
+(void)strokeColorSet;
+(void)cgFillColorSet;
+(void)cgStrokeColorSet;
@end

@implementation C4Shape

+(void)load {
	if(VERBOSELOAD) printf("C4Shape\n");
}

#pragma mark Shapes
+(void)arcWithCenterAt:(NSPoint)p radius:(float)r startAngle:(float)startAngle endAngle:(float)endAngle {
	if([C4GlobalShapeAttributes sharedManager].useFill == YES) {
		NSBezierPath *arcPath = [NSBezierPath bezierPath];
		[arcPath appendBezierPathWithArcWithCenter:p radius:r startAngle:startAngle endAngle:endAngle];
		[arcPath lineToPoint:p];
		[arcPath closePath];
		[self fillColorSet];
		[arcPath fill];
		if ([C4GlobalShapeAttributes sharedManager].drawShapesToPDF == YES) {
			[self cgFillColorSet];
			CGContextBeginPath([C4GlobalShapeAttributes sharedManager].pdfContext);
			CGContextAddArc([C4GlobalShapeAttributes sharedManager].pdfContext, p.x, p.y, r, DEGREES_TO_RADIANS(startAngle),DEGREES_TO_RADIANS(endAngle), 0);
			CGContextAddLineToPoint([C4GlobalShapeAttributes sharedManager].pdfContext,p.x,p.y);
			CGContextFillPath([C4GlobalShapeAttributes sharedManager].pdfContext);
		}
	}
	
	if ([C4GlobalShapeAttributes sharedManager].useStroke == YES) {
		NSBezierPath *arcPath = [NSBezierPath bezierPath];
		[arcPath appendBezierPathWithArcWithCenter:p radius:r startAngle:startAngle endAngle:endAngle];
		[self strokeColorSet];
		[arcPath setLineWidth:[C4GlobalShapeAttributes sharedManager].strokeWidth];
		[arcPath stroke];
		if ([C4GlobalShapeAttributes sharedManager].drawShapesToPDF == YES) {
			[self cgStrokeColorSet];
			CGContextBeginPath([C4GlobalShapeAttributes sharedManager].pdfContext);
			CGContextAddArc([C4GlobalShapeAttributes sharedManager].pdfContext, p.x, p.y, r, startAngle, endAngle, 0);
			CGContextClosePath([C4GlobalShapeAttributes sharedManager].pdfContext);
			CGContextStrokePath([C4GlobalShapeAttributes sharedManager].pdfContext);
		}
	}
    //	if ([C4GlobalShapeAttributes sharedManager].drawShapesToPDF == YES) {
    //		C4Log(@"Should draw - arc");
    //	}
}

+(void)curveFromPoint:(NSPoint)p1 toPoint:(NSPoint)p2 controlPoint1:(NSPoint)c1 controlPoint2:(NSPoint)c2 {
	if ([C4GlobalShapeAttributes sharedManager].useStroke == YES) {
		NSBezierPath *curvePath = [NSBezierPath bezierPath];
		[curvePath moveToPoint:p1];
		[curvePath curveToPoint:p2 controlPoint1:c1 controlPoint2:c2];
		[self strokeColorSet];
		[curvePath setLineWidth:[C4GlobalShapeAttributes sharedManager].strokeWidth];
		[curvePath stroke];
		if ([C4GlobalShapeAttributes sharedManager].drawShapesToPDF) {
			[self cgStrokeColorSet];
			CGContextBeginPath([C4GlobalShapeAttributes sharedManager].pdfContext);
			CGContextMoveToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, p1.x, p1.y);
			CGContextAddCurveToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, c1.x, c1.y, c2.x, c2.y, p2.x, p2.y);
			CGContextStrokePath([C4GlobalShapeAttributes sharedManager].pdfContext);
		}
	}
    //	if ([C4GlobalShapeAttributes sharedManager].drawShapesToPDF == YES) {
    //		C4Log(@"Should draw - curve");
    //	}
}

+(void)curveFromX:(int)x1 Y:(int)y1 toX:(int)x2 Y:(int)y2 controlPoint1X:(int)cx1 Y:(int)cy1 controlPoint2X:(int)cx2 Y:(int)cy2 {
	[self curveFromPoint:NSMakePoint(x1, y1) 
				 toPoint:NSMakePoint(x2, y2) 
		   controlPoint1:NSMakePoint(cx1, cy1)
		   controlPoint2:NSMakePoint(cx2, cy2)];
}

+(void)circleAt:(NSPoint)p radius:(int)r {
	[self ellipseAt:p size:NSMakeSize(r*2, r*2)];
}

+(void)ellipseAt:(NSPoint)p	size:(NSSize)s {
	NSRect circleRect = NSZeroRect;
	circleRect.origin = p;
	circleRect.size = s;
	if ([C4GlobalShapeAttributes sharedManager].ellipseMode == CENTER) {
		circleRect.origin.x -= circleRect.size.width/2;
		circleRect.origin.y -= circleRect.size.height/2;
	}
	NSBezierPath *ellipse = [NSBezierPath bezierPathWithOvalInRect:circleRect];
	
	if([C4GlobalShapeAttributes sharedManager].useFill == YES) {
		[self fillColorSet];
		[ellipse fill];
		if ([C4GlobalShapeAttributes sharedManager].drawShapesToPDF == YES) {
			[self cgFillColorSet];
			CGContextFillEllipseInRect([C4GlobalShapeAttributes sharedManager].pdfContext, NSRectToCGRect(circleRect));
		}
	}
	
	if([C4GlobalShapeAttributes sharedManager].useStroke == YES) {
		[ellipse setLineWidth:[C4GlobalShapeAttributes sharedManager].strokeWidth];
		[self strokeColorSet];
		[ellipse stroke];
		if ([C4GlobalShapeAttributes sharedManager].drawShapesToPDF == YES) {
			[self cgStrokeColorSet];
			CGContextStrokeEllipseInRect([C4GlobalShapeAttributes sharedManager].pdfContext, NSRectToCGRect(circleRect));
		}
	}
}

+(void)ellipseWithXPos:(int)x yPos:(int)y width:(int)w andHeight:(int)h {
	[self ellipseAt:NSMakePoint(x,y) size:NSMakeSize(w, h)];
}

+(void)lineFromX:(int)x1 Y:(int)y1 toX:(int)x2 Y:(int)y2 {
        [self lineFromPoint:NSMakePoint(x1, y1) toPoint:NSMakePoint(x2, y2)];
}

+(void)lineFromPoint:(NSPoint)p1 toPoint:(NSPoint)p2 {
    if([C4GlobalShapeAttributes sharedManager].strokeWidth - floorf([C4GlobalShapeAttributes sharedManager].strokeWidth) == 0) {
        
        if(((int)[C4GlobalShapeAttributes sharedManager].strokeWidth)%2 == 1 && [C4GlobalShapeAttributes sharedManager].useStroke == YES) {
            p1.x = floorf(p1.x)+0.5;
            p1.y = floorf(p1.y)+0.5;
            p2.x = floorf(p2.x)+0.5;
            p2.y = floorf(p2.y)+0.5;
        }
    }

	if([C4GlobalShapeAttributes sharedManager].useStroke == YES) {
		NSBezierPath *linePath = [NSBezierPath bezierPath];
		[linePath moveToPoint:p1];
		[linePath lineToPoint:p2];
		[self strokeColorSet];
		[linePath setLineWidth:[C4GlobalShapeAttributes sharedManager].strokeWidth];
		[linePath stroke];
        
        if ([C4GlobalShapeAttributes sharedManager].drawShapesToPDF == YES) {
            [self cgStrokeColorSet];
            
            CGContextSetLineCap([C4GlobalShapeAttributes sharedManager].pdfContext,kCGLineCapRound);
            CGContextBeginPath([C4GlobalShapeAttributes sharedManager].pdfContext);
            CGContextMoveToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, p1.x, p1.y);
            CGContextAddLineToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, p2.x, p2.y);
            CGContextClosePath([C4GlobalShapeAttributes sharedManager].pdfContext);
            CGContextStrokePath([C4GlobalShapeAttributes sharedManager].pdfContext);
        }
    }
}

+(void)pointAtX:(int)x1 Y:(int)y1 {
	[self pointAt:NSMakePoint(x1, y1)];
}

+(void)pointAt:(NSPoint)p {
	[self noStroke];
	[self fill];
	[self rectWithXPos:p.x yPos:p.y width:1 andHeight:1];
	if ([C4GlobalShapeAttributes sharedManager].useStroke == YES) [self stroke]; //set stroke on if it was on before
	if ([C4GlobalShapeAttributes sharedManager].useFill == NO) [self noFill]; //set fill off if it was off before
}

+(void)rectWithXPos:(int)x yPos:(int)y width:(float)w andHeight:(float)h {
    /*
     if (w < 1) {
     NSLog(@"Value for width (%f) invalid, width must be >= 1",w);
     return;
     }
     if (h < 1) {
     NSLog(@"Value for height (%f) invalid, width must be >= 1",h);
     return;
     }
     */
    
	NSRect rect = NSMakeRect(x, y, [C4Math ceil:w], [C4Math ceil:h]);
	if ([C4GlobalShapeAttributes sharedManager].rectMode == CENTER) {
		rect.origin.x -= w/2;
		rect.origin.y -= h/2;
	}
    
    if ([C4GlobalShapeAttributes sharedManager].useStroke == YES) {
    rect.origin.x = [C4Math floor:rect.origin.x]+0.5f;
    rect.origin.y = [C4Math floor:rect.origin.y]+0.5f;
    }
    
	
	NSBezierPath *rectPath = [NSBezierPath bezierPathWithRect:rect];
    
	if ([C4GlobalShapeAttributes sharedManager].useFill == YES) {
		[self fillColorSet];
		[rectPath fill];
		if ([C4GlobalShapeAttributes sharedManager].drawShapesToPDF == YES) {
			[self cgFillColorSet];
			CGContextFillRect([C4GlobalShapeAttributes sharedManager].pdfContext, NSRectToCGRect(rect));
		}
	}
	if ([C4GlobalShapeAttributes sharedManager].useStroke == YES) {
		[self strokeColorSet];
		[rectPath setLineWidth:[C4GlobalShapeAttributes sharedManager].strokeWidth];
		[rectPath stroke];
		if ([C4GlobalShapeAttributes sharedManager].drawShapesToPDF == YES) {
			[self cgStrokeColorSet];
			CGContextStrokeRect([C4GlobalShapeAttributes sharedManager].pdfContext, CGRectMake(x, y, w, h));
		}
	}
}

+(void)rectAt:(NSPoint)p size:(NSSize)s {
	[self rectWithXPos:p.x yPos:p.y width:s.width andHeight:s.height];
}


+(void)triangleFromX:(int)x1 Y:(int)y1 toX:(int)x2 Y:(int)y2 toX:(int)x3 Y:(int)y3 {
	[self triangleUsingPoint:NSMakePoint(x1, y1) point:NSMakePoint(x2, y2) point:NSMakePoint(x3, y3)];
}

+(void)triangleUsingPoint:(NSPoint)p1 point:(NSPoint)p2 point:(NSPoint)p3 {
	NSBezierPath *trianglePath = [NSBezierPath bezierPath];
	[trianglePath moveToPoint:p1];
	[trianglePath lineToPoint:p2];
	[trianglePath lineToPoint:p3];
	[trianglePath lineToPoint:p1];
	
	if ([C4GlobalShapeAttributes sharedManager].useFill == YES) {
		[self fillColorSet];
		[trianglePath fill];
		if([C4GlobalShapeAttributes sharedManager].drawShapesToPDF == YES) {
			[self cgFillColorSet];
			CGContextBeginPath([C4GlobalShapeAttributes sharedManager].pdfContext);
			CGContextMoveToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, p1.x, p1.y);
			CGContextAddLineToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, p2.x, p2.y);
			CGContextAddLineToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, p3.x, p3.y);
			CGContextClosePath([C4GlobalShapeAttributes sharedManager].pdfContext);
			CGContextFillPath([C4GlobalShapeAttributes sharedManager].pdfContext);
		}
	}
	if([C4GlobalShapeAttributes sharedManager].useStroke == YES){
		[self strokeColorSet];
		[trianglePath setLineWidth:[C4GlobalShapeAttributes sharedManager].strokeWidth];
		[trianglePath stroke];
		if ([C4GlobalShapeAttributes sharedManager].drawShapesToPDF == YES) {
			[self cgStrokeColorSet];
			
			CGContextBeginPath([C4GlobalShapeAttributes sharedManager].pdfContext);
			CGContextMoveToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, p1.x, p1.y);
			CGContextAddLineToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, p2.x, p2.y);
			CGContextAddLineToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, p3.x, p3.y);
			CGContextAddLineToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, p1.x, p1.y);
			CGContextClosePath([C4GlobalShapeAttributes sharedManager].pdfContext);
			CGContextStrokePath([C4GlobalShapeAttributes sharedManager].pdfContext);
		}
	}
}

+(void)quadUsingPoint:(NSPoint)p1 point:(NSPoint)p2 point:(NSPoint)p3 point:(NSPoint)p4 {
	NSBezierPath *quadPath = [NSBezierPath bezierPath];
	[quadPath moveToPoint:p1];
	[quadPath lineToPoint:p2];
	[quadPath lineToPoint:p3];
	[quadPath lineToPoint:p4];
	[quadPath lineToPoint:p1];
	
	if([C4GlobalShapeAttributes sharedManager].useFill == YES) {
		[self fillColorSet];
		[quadPath fill];
		if([C4GlobalShapeAttributes sharedManager].drawShapesToPDF) {
			[self cgFillColorSet];
			CGContextBeginPath([C4GlobalShapeAttributes sharedManager].pdfContext);
			CGContextMoveToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, p1.x, p1.y);
			CGContextAddLineToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, p2.x, p2.y);
			CGContextAddLineToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, p3.x, p3.y);
			CGContextAddLineToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, p4.x, p4.y);
			CGContextClosePath([C4GlobalShapeAttributes sharedManager].pdfContext);
			CGContextFillPath([C4GlobalShapeAttributes sharedManager].pdfContext);
		}
	}
	if([C4GlobalShapeAttributes sharedManager].useStroke == YES){ 
		[self strokeColorSet];
		[quadPath setLineWidth:[C4GlobalShapeAttributes sharedManager].strokeWidth];
		[quadPath stroke];
		if ([C4GlobalShapeAttributes sharedManager].drawShapesToPDF == YES) {
			[self cgStrokeColorSet];
			CGContextBeginPath([C4GlobalShapeAttributes sharedManager].pdfContext);
			CGContextMoveToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, p1.x, p1.y);
			CGContextAddLineToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, p2.x, p2.y);
			CGContextAddLineToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, p3.x, p3.y);
			CGContextAddLineToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, p4.x, p4.y);
			CGContextAddLineToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, p1.x, p1.y);
			CGContextClosePath([C4GlobalShapeAttributes sharedManager].pdfContext);
			CGContextStrokePath([C4GlobalShapeAttributes sharedManager].pdfContext);
		}
	}
}

+(void)quadFromX:(int)x1 Y:(int)y1 toX:(int)x2 Y:(int)y2 toX:(int)x3 Y:(int)y3 toX:(int)x4 Y:(int)y4 {	
	[self quadUsingPoint:NSMakePoint(x1, y1) point:NSMakePoint(x2, y2) point:NSMakePoint(x3, y3) point:NSMakePoint(x4, y4)];
}

#pragma mark Vertex Shapes
+(void)beginShape {
	if ([C4GlobalShapeAttributes sharedManager].checkShape == YES) {
		[NSException raise:@"[C4Shape beginShape] Exception" format:@"[C4Shape beginShape] already called, you must call [C4Shape endShape] before beginning another shape."];
	}
	[C4GlobalShapeAttributes sharedManager].checkShape = YES;
	[C4GlobalShapeAttributes sharedManager].firstPoint = YES;
	[C4GlobalShapeAttributes sharedManager].vertexPath = [NSBezierPath bezierPath];
	if ([C4GlobalShapeAttributes sharedManager].drawShapesToPDF == YES) {
		CGContextBeginPath([C4GlobalShapeAttributes sharedManager].pdfContext);
	}
}

+(void)endShape {
	if ([C4GlobalShapeAttributes sharedManager].checkShape == NO) {
		[NSException raise:@"[C4Shape endShape] Exception" format:@"[C4Shape endShape] already called, you must call [C4Shape beginShape] to start a new shape."];
	} else if ([[C4GlobalShapeAttributes sharedManager].vertexPath elementCount] < 2){
		[NSException raise:@"[C4Shape endShape] Exception" format:@"The current shape has %d points, but needs at least 2 points.", [[C4GlobalShapeAttributes sharedManager].vertexPath elementCount]];
	}
	[C4GlobalShapeAttributes sharedManager].checkShape = NO;
	
	if([C4GlobalShapeAttributes sharedManager].useFill == YES) {
		[self fillColorSet];
		[[C4GlobalShapeAttributes sharedManager].vertexPath fill];
		if ([C4GlobalShapeAttributes sharedManager].drawShapesToPDF == YES) {
			[self cgFillColorSet];
			CGContextFillPath([C4GlobalShapeAttributes sharedManager].pdfContext);
		}
	}
	if([C4GlobalShapeAttributes sharedManager].useStroke == YES){ 
		[self strokeColorSet];
		[[C4GlobalShapeAttributes sharedManager].vertexPath setLineWidth:[C4GlobalShapeAttributes sharedManager].strokeWidth];
		[[C4GlobalShapeAttributes sharedManager].vertexPath stroke];
		if([C4GlobalShapeAttributes sharedManager].drawShapesToPDF == YES) {
			[self cgStrokeColorSet];
			CGContextStrokePath([C4GlobalShapeAttributes sharedManager].pdfContext);
		}
	}
}

+(void)closeShape {
	if ([C4GlobalShapeAttributes sharedManager].checkShape == NO) {
		[NSException raise:@"[C4Shape endShape] Exception" format:@"[C4Shape endShape] already called, you must call [C4Shape beginShape] to start a new shape."];
	} else if ([[C4GlobalShapeAttributes sharedManager].vertexPath elementCount] < 2){
		[NSException raise:@"[C4Shape closeShape] Exception" format:@"The current shape has %d points, but needs at least 2 points.", [[C4GlobalShapeAttributes sharedManager].vertexPath elementCount]];
	}
	[[C4GlobalShapeAttributes sharedManager].vertexPath closePath];
	CGContextClosePath([C4GlobalShapeAttributes sharedManager].pdfContext);
}

+(void)vertexAtX:(int)x Y:(int)y {
	[self vertexAt:NSMakePoint(x, y)];
}

+(void)vertices:(NSPoint *)points length:(NSInteger)length{
    for(int i = 0; i < length; i++) {
        [self vertexAt:points[i]];
    }
}

+(void)vertexAt:(NSPoint)point {
    point.x = [C4Math floor:point.x] + 0.5;
    point.y = [C4Math floor:point.y] + 0.5;

	if ([C4GlobalShapeAttributes sharedManager].checkShape == NO) {
		[NSException raise:@"[C4Shape vertexAt:] Exception" format:@"You must call [C4Shape beginShape] before adding vertices."];
	}
	if ([C4GlobalShapeAttributes sharedManager].firstPoint == YES) {
		[[C4GlobalShapeAttributes sharedManager].vertexPath moveToPoint:point];
		if ([C4GlobalShapeAttributes sharedManager].drawShapesToPDF == YES) {
			CGContextMoveToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, point.x, point.y);
		}
		[C4GlobalShapeAttributes sharedManager].firstPoint = NO;
	} else {
		[[C4GlobalShapeAttributes sharedManager].vertexPath lineToPoint:point];
		if ([C4GlobalShapeAttributes sharedManager].drawShapesToPDF == YES) {
			CGContextAddLineToPoint([C4GlobalShapeAttributes sharedManager].pdfContext, point.x, point.y);
		}
	}
}

#pragma mark Current Shape
+(void)clearCurrentShape {
	[C4GlobalShapeAttributes sharedManager].currentShape = CGPathCreateMutable();
}

+(CGMutablePathRef)currentShape {
	return [C4GlobalShapeAttributes sharedManager].currentShape;
}
+(void)addArcWithCenterAt:(NSPoint)p radius:(float)r startAngle:(float)startAngle endAngle:(float)endAngle {
	CGPathAddArc([C4GlobalShapeAttributes sharedManager].currentShape, NULL, p.x, p.y, r, DEGREES_TO_RADIANS(startAngle),DEGREES_TO_RADIANS(endAngle), 0);
}

+(void)addCircleAt:(NSPoint)p radius:(int)r{
	CGRect circleRect;
	circleRect.origin = NSPointToCGPoint(p);
	circleRect.size = CGSizeMake(r*2, r*2);
	if ([C4GlobalShapeAttributes sharedManager].ellipseMode == CENTER) {
		circleRect.origin.x -= r;
		circleRect.origin.y -= r;
	}
	CGPathAddEllipseInRect([C4GlobalShapeAttributes sharedManager].currentShape, NULL, circleRect);
}

+(void)addCurveFromPoint:(NSPoint)p1 toPoint:(NSPoint)p2 controlPoint1:(NSPoint)c1 controlPoint2:(NSPoint)c2 {
	[self addCurveFromX:p1.x Y:p1.y toX:p2.x Y:p2.y controlPoint1X:c1.x Y:c1.y controlPoint2X:c2.x Y:c2.y];
}

+(void)addCurveFromX:(int)x1 Y:(int)y1 toX:(int)x2 Y:(int)y2 controlPoint1X:(int)cx1 Y:(int)cy1 controlPoint2X:(int)cx2 Y:(int)cy2{
	CGMutablePathRef curvePath = CGPathCreateMutable();
	CGPathMoveToPoint(curvePath, NULL, x1, y1);
	CGPathAddCurveToPoint(curvePath, NULL, cx1, cy1, cx2, cy2, x2, y2);
	CGPathAddPath([C4GlobalShapeAttributes sharedManager].currentShape, NULL, curvePath);
    CFRelease(curvePath);
}

+(void)addEllipseAt:(NSPoint)p size:(NSSize)s {
	CGRect ellipseRect;
	ellipseRect.origin = NSPointToCGPoint(p);
	ellipseRect.size = NSSizeToCGSize(s);
	if ([C4GlobalShapeAttributes sharedManager].ellipseMode == CENTER) {
		ellipseRect.origin.x -= ellipseRect.size.width/2;
		ellipseRect.origin.y -= ellipseRect.size.height/2;
	}
	CGPathAddEllipseInRect([C4GlobalShapeAttributes sharedManager].currentShape, NULL, ellipseRect);
}

+(void)addEllipseWithXPos:(int)x yPos:(int)y width:(int)w andHeight:(int)h {
	[self addEllipseAt:NSMakePoint(x, y) size:NSMakeSize(w, h)];
}

+(void)addLineFromX:(int)x1 Y:(int)y1 toX:(int)x2 Y:(int)y2{
	CGMutablePathRef linePath = CGPathCreateMutable();
	CGPathMoveToPoint(linePath, NULL, x1, y1);
	CGPathAddLineToPoint(linePath, NULL, x2, y2);
	CGPathAddPath([C4GlobalShapeAttributes sharedManager].currentShape, NULL, linePath);
    CFRelease(linePath);
}

+(void)addLineFromPoint:(NSPoint)p1 toPoint:(NSPoint)p2{ 
	[self addLineFromX:p1.x Y:p1.y toX:p2.x Y:p2.y];
}

+(void)addLineTo:(NSPoint)p {
	[self addLineToX:p.x Y:p.y];
}

+(void)addLineToX:(int)x Y:(int)y {
	CGPathAddLineToPoint([C4GlobalShapeAttributes sharedManager].currentShape, NULL, x, y);
}

+(void)addPointAt:(NSPoint)p{
	[self addRectWithXPos:p.x yPos:p.y width:1 andHeight:1];
}
+(void)addPointAtX:(int)x1 Y:(int)y1{
	[self addPointAt:NSMakePoint(x1,y1)];
}
+(void)addRectWithXPos:(int)x yPos:(int)y width:(float)w andHeight:(float)h { 
	CGPathAddRect([C4GlobalShapeAttributes sharedManager].currentShape,NULL,CGRectMake(x, y, w, h));
}
+(void)addTriangleFromX:(int)x1 Y:(int)y1 toX:(int)x2 Y:(int)y2 toX:(int)x3 Y:(int)y3{
	[self addTriangleUsingPoint:NSMakePoint(x1, y1) point:NSMakePoint(x2, y2) point:NSMakePoint(x3, y3)];
}
+(void)addTriangleUsingPoint:(NSPoint)p1 point:(NSPoint)p2 point:(NSPoint)p3 {
	CGMutablePathRef trianglePath = CGPathCreateMutable();
	CGPathMoveToPoint(trianglePath, NULL, p1.x, p1.y);
	CGPathAddLineToPoint(trianglePath, NULL, p2.x, p2.y);
	CGPathAddLineToPoint(trianglePath, NULL, p3.x, p3.y);
	CGPathAddLineToPoint(trianglePath, NULL, p1.x, p1.y);
	CGPathAddPath([C4GlobalShapeAttributes sharedManager].currentShape, NULL, trianglePath);
    CFRelease(trianglePath);
}
+(void)addQuadUsingPoint:(NSPoint)p1 point:(NSPoint)p2 point:(NSPoint)p3 point:(NSPoint)p4{
	[self addQuadFromX:p1.x Y:p1.y toX:p2.x Y:p2.y toX:p3.x Y:p3.y toX:p4.x Y:p4.y];
}
+(void)addQuadFromX:(int)x1 Y:(int)y1 toX:(int)x2 Y:(int)y2 toX:(int)x3 Y:(int)y3 toX:(int)x4 Y:(int)y4{
	CGMutablePathRef quadPath = CGPathCreateMutable();
	CGPathMoveToPoint(quadPath, NULL, x1, y1);
	CGPathAddLineToPoint(quadPath, NULL, x2, y2);
	CGPathAddLineToPoint(quadPath, NULL, x3, y3);
	CGPathAddLineToPoint(quadPath, NULL, x4, y4);
	CGPathAddLineToPoint(quadPath, NULL, x1, y1);
	CGPathAddPath([C4GlobalShapeAttributes sharedManager].currentShape, NULL, quadPath);
    CFRelease(quadPath);
}

#pragma mark Attributes
+(void)strokeWidth:(float)width {
	if ([C4GlobalShapeAttributes sharedManager].strokeWidth > 0.1) {
		[C4GlobalShapeAttributes sharedManager].strokeWidth = width;
	} else {
		[C4GlobalShapeAttributes sharedManager].strokeWidth = 0.1;
		NSLog(@"stroke width set to 0.1, it cannot be smaller than this");
	}
}

+(void)rectMode:(int)mode {
	if (mode == CENTER || mode == CORNER) {
		[C4GlobalShapeAttributes sharedManager].rectMode = mode;
	} else {
		NSLog(@"rect mode must be CENTER or CORNER");
	}
}

+(void)ellipseMode:(int)mode {
	if (mode == CENTER || mode == CORNER) {
		[C4GlobalShapeAttributes sharedManager].ellipseMode = mode;
	} else {
		NSLog(@"ellipse mode must be CENTER or CORNER");
	}
}

+(void)strokeCapMode:(int)mode {
	if(mode >= NSButtLineCapStyle && mode <= NSSquareLineCapStyle)
		[NSBezierPath setDefaultLineCapStyle:mode];
	else
		C4Log(@"Stroke Cap Mode must be one of: CAPBUTT, CAPROUND, CAPSQUARE");		
}

+(void)strokeJoinMode:(int)mode {
	if (mode >= NSMiterLineJoinStyle && mode <= NSBevelLineJoinStyle)
		[NSBezierPath setDefaultLineJoinStyle:mode];
	else
		C4Log(@"Stroke Join Mode must be one of: JOINMITRE, JOINROUND, JOINBEVEL");
}

+(void)strokeDetail:(float)level {
	[NSBezierPath setDefaultFlatness:fabsf(level)];
}

#pragma mark Colors
+(void)fillColor:(C4Color *)color {
    [C4GlobalShapeAttributes sharedManager].fillColor = color;
}

+(void)fillColor:(C4Color *)color alpha:(CGFloat)alpha{
    [C4GlobalShapeAttributes sharedManager].fillColor = [C4Color colorWithRed:[color redComponent] green:[color greenComponent] blue:[color blueComponent] alpha:alpha];
}

+(void)fill:(float)grey {
	[C4GlobalShapeAttributes sharedManager].fillColor = [C4Color colorWithGrey:grey];
}

+(void)fill:(float)grey alpha:(float)alpha{
	[C4GlobalShapeAttributes sharedManager].fillColor = [C4Color colorWithGrey:grey alpha:alpha];
}

+(void)fillRed:(float)red green:(float)green blue:(float)blue {
	[C4GlobalShapeAttributes sharedManager].fillColor = [C4Color colorWithRed:red green:green blue:blue];
}

+(void)fillRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha{
	[C4GlobalShapeAttributes sharedManager].fillColor = [C4Color colorWithRed:red green:green blue:blue alpha:alpha];
}

+(void)noFill {
	[C4GlobalShapeAttributes sharedManager].useFill = NO;
}

+(void)fill {
	[C4GlobalShapeAttributes sharedManager].useFill = YES;
}

+(void)stroke {
	[C4GlobalShapeAttributes sharedManager].useStroke = YES;
}

+(void)strokeColor:(C4Color *)color {
	[C4GlobalShapeAttributes sharedManager].strokeColor = color;
}

+(void)stroke:(float)grey {
	[C4GlobalShapeAttributes sharedManager].strokeColor = [C4Color colorWithRed:grey green:grey blue:grey alpha:1.0f];
}

+(void)stroke:(float)grey alpha:(float)alpha {
	[C4GlobalShapeAttributes sharedManager].strokeColor = [C4Color colorWithRed:grey green:grey blue:grey alpha:alpha];
}

+(void)strokeRed:(float)red green:(float)green blue:(float)blue {
	[C4GlobalShapeAttributes sharedManager].strokeColor = [C4Color colorWithRed:red green:green blue:blue alpha:255];
}

+(void)strokeRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha{
	[C4GlobalShapeAttributes sharedManager].strokeColor = [C4Color colorWithRed:red green:green blue:blue alpha:alpha];
}

+(void)noStroke {
	[C4GlobalShapeAttributes sharedManager].useStroke = NO;
}

+(void)fillColorSet {
	if ([C4GlobalShapeAttributes sharedManager].useFill == YES){
        [[C4GlobalShapeAttributes sharedManager].fillColor set];
    }
	else [[NSColor colorWithCalibratedWhite:1.0f alpha:0.0f] set];
}

+(void)strokeColorSet {
	if ([C4GlobalShapeAttributes sharedManager].useStroke == YES) [[C4GlobalShapeAttributes sharedManager].strokeColor set];
	else [[NSColor colorWithCalibratedWhite:1.0f alpha:0.0f] set];
}

+(void)cgFillColorSet {
	CGColorRef c = [[C4GlobalShapeAttributes sharedManager].fillColor cgColor];	
	const CGFloat *colorComponents = CGColorGetComponents(c);
	if([C4GlobalShapeAttributes sharedManager].useFill == YES) CGContextSetRGBFillColor([C4GlobalShapeAttributes sharedManager].pdfContext,colorComponents[0],colorComponents[1],colorComponents[2],colorComponents[3]);
	else CGContextSetRGBFillColor([C4GlobalShapeAttributes sharedManager].pdfContext, 0, 0, 0, 0);
}

+(void)cgStrokeColorSet {
	CGContextSetLineWidth([C4GlobalShapeAttributes sharedManager].pdfContext, [C4GlobalShapeAttributes sharedManager].strokeWidth);
	CGColorRef c = [[C4GlobalShapeAttributes sharedManager].strokeColor cgColor];	
	const CGFloat *colorComponents = CGColorGetComponents(c);
	if([C4GlobalShapeAttributes sharedManager].useStroke == YES) CGContextSetRGBStrokeColor([C4GlobalShapeAttributes sharedManager].pdfContext,colorComponents[0],colorComponents[1],colorComponents[2],colorComponents[3]);
	else CGContextSetRGBStrokeColor([C4GlobalShapeAttributes sharedManager].pdfContext, 0, 0, 0, 0);
}

#pragma mark Coordinates
-(void)flipCoordinates {
}

-(void)nativeCoordinates {
}

#pragma mark Output
+(BOOL)isClean {
	return [C4GlobalShapeAttributes sharedManager].isClean;
}

+(void)beginDrawShapesToPDFContext:(CGContextRef)context {
	C4Log(@"beginDrawShapesToPDFContext");
	[C4GlobalShapeAttributes sharedManager].pdfContext = context;
	[C4GlobalShapeAttributes sharedManager].drawShapesToPDF = YES;
	[C4GlobalShapeAttributes sharedManager].isClean = NO;
}

+(void)endDrawShapesToPDFContext {
	[C4GlobalShapeAttributes sharedManager].drawShapesToPDF = NO;
    [C4GlobalShapeAttributes sharedManager].pdfContext = nil;
	[C4GlobalShapeAttributes sharedManager].isClean = YES;
	C4Log(@"endDrawShapesToPDFContext");
}

#pragma mark Singleton

-(id) init
{
    if((self = [super init]))
    {
        strokeWidth = 1.0f;
        fillColor =     [[C4Color colorWithGrey:1] retain];	//white
        strokeColor =   [[C4Color colorWithGrey:0] retain];	//black
        ellipseMode =   CENTER;
        rectMode =      CORNER;
        
        useFill = YES;
        useStroke = YES;
        checkShape = NO;
        firstPoint	= YES;
        drawShapesToPDF = NO;
        
        rectMode = CORNER;
        ellipseMode = CENTER;
        
        strokeWidth = 0.1f;
    }
    
    return self;
}

+ (C4Shape *)sharedManager
{
    if (sharedC4Shape == nil) {
        static dispatch_once_t once;
        dispatch_once(&once, ^ { sharedC4Shape = [[super allocWithZone:NULL] init]; 
        });
        return sharedC4Shape;
    }
    return sharedC4Shape;
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
