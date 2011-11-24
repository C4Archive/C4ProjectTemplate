//
//  C4Gradient.h
//  Created by Travis Kirton
//

#import <Cocoa/Cocoa.h>

@interface C4Gradient : C4Object {
}

+(void)linearGradientFromPointA:(NSPoint)pointA 
                       toPointB:(NSPoint)pointB 
                    usingColorA:(C4Color *)colorA
                      andColorB:(C4Color *)colorB 
                        inShape:(CGMutablePathRef)shape;

+(void)linearGradientFromPointA:(NSPoint)pointA
                       toPointB:(NSPoint)pointB
                       toPointC:(NSPoint)pointC
                    usingColorA:(C4Color *)colorA
                      andColorB:(C4Color *)colorB 
                      andColorC:(C4Color*)colorC
                        inShape:(CGMutablePathRef)shape;

+(void)radialGradientFromCenter:(NSPoint)center 
                      toRadiusA:(CGFloat)radiusA 
                     andRadiusB:(CGFloat)radiusB 
                    usingColorA:(C4Color *)colorA 
                      andColorB:(C4Color *)colorB 
                        inShape:(CGMutablePathRef)shape;

+(void)radialGradientFromCenter:(NSPoint)center 
                      toRadiusA:(CGFloat)radiusA
                     andRadiusB:(CGFloat)radiusB 
                     andRadiusC:(CGFloat)radiusC 
                    usingColorA:(C4Color *)colorA 
                      andColorB:(C4Color *)colorB 
                      andColorC:(C4Color *)colorC 
                        inShape:(CGMutablePathRef)shape;

@end