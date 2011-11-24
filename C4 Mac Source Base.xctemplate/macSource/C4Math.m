//
//  C4Math.m
//  Created by Travis Kirton
//

#import "C4Math.h"

static C4Math *sharedC4Math = nil;

@implementation C4Math

#pragma mark Initialization

+(void)load {
	if(VERBOSELOAD) printf("C4Math\n");
}

#pragma mark Calculation
+(NSInteger)abs:(NSInteger)value {
	return abs(value);
}

+(CGFloat)absf:(CGFloat)value {
	return fabsf(value);
}

+(NSInteger)ceil:(CGFloat)value {
	return ceilf(value);
}

+(NSInteger)constrain:(NSInteger)value min:(NSInteger)min max:(NSInteger)max {
	return [self constrainf:value min:min max:max];
}

+(CGFloat)constrainf:(CGFloat)value min:(CGFloat)min max:(CGFloat)max {
	if (min < value && value < max) return value;
	else if (value <= min) return min;
	else return max;
}

+(CGFloat)exp:(CGFloat)value {
	return [self pow:eCONSTANT raiseTo:value];
}

+(NSInteger)floor:(CGFloat)value {
	return floor((double)value);
}

+(CGFloat)lerpBetweenA:(CGFloat)a andB:(CGFloat)b byAmount:(CGFloat)amount {
	return 0;
}

+(CGFloat)log:(CGFloat)value {
	return logf(value);
}

+(CGFloat)map:(CGFloat)value fromMin:(CGFloat)min1 max:(CGFloat)max1 toMin:(CGFloat)min2 max:(CGFloat)max2 {
	float rangeLength1 = max1-min1;
	float rangeLength2 = max2-min2;
	float multiplier = (value-min1)/rangeLength1;
	return multiplier*rangeLength2+min2;
}

+(CGFloat)maxOfA:(CGFloat)a andB:(CGFloat)b {
	float max = a > b ? a : b;
	return max;
}

+(CGFloat)maxOfA:(CGFloat)a B:(CGFloat)b andC:(CGFloat)c {
	return [self maxOfA:[self maxOfA:a andB:b] andB:c];
}


+(CGFloat)minOfA:(CGFloat)a andB:(CGFloat)b {
	float min = a < b ? a : b;
	return min;
}

+(CGFloat)minOfA:(CGFloat)a B:(CGFloat)b andC:(CGFloat)c {
	return [self minOfA:[self minOfA:a andB:b] andB:c];
}

+(CGFloat)norm:(CGFloat)value fromMin:(CGFloat)min toMax:(CGFloat)max {
	return 0;
}

+(CGFloat)pow:(CGFloat)value raiseTo:(CGFloat)degree {
	return powf(value,degree);
}

+(CGFloat)round:(CGFloat)value {
	return roundf(value);
}

+(CGFloat)square:(CGFloat)value {
	return powf(value, 2);
}

+(CGFloat)sqrt:(CGFloat)value {
	return sqrtf(value);
}

#pragma mark Trigonometry
+(CGFloat)acos:(CGFloat)value {
	return acosf(value);
}

+(CGFloat)asin:(CGFloat)value {
	return asinf(value);
}

+(CGFloat)atan:(CGFloat)value {
	return atanf(value);
}

+(CGFloat)atan2Y:(CGFloat)y X:(CGFloat)x {
	return atan2f(y,x);
}

+(CGFloat)cos:(CGFloat)value {
	return cosf(value);
}

+(CGFloat)degrees:(CGFloat)value {
	return RADIANS_TO_DEGREES(value);
}

+(CGFloat)radians:(CGFloat)value {
	return DEGREES_TO_RADIANS(value);
}

+(CGFloat)sin:(CGFloat)value {
	return sinf(value);
}

+(CGFloat)tan:(CGFloat)value {
	return tanf(value);
}
#pragma mark Random
+(NSInteger)randomInt:(NSInteger)value {
	srandomdev();
	return ((NSInteger)random())%value;
}

#pragma mark arithmetic
+(NSInteger)randomIntBetweenA:(NSInteger)a andB:(NSInteger)b{
    NSInteger returnVal;
	if (a == b) {
        returnVal = a;
    }
    else {
        int max = a > b ? a : b;
        int min = a < b ? a : b;
        assert(max-min > 0);
        srandomdev();
        returnVal = (((NSInteger)random())%(max-min) + min);
    }
    return returnVal;
}

#pragma mark Singleton

-(id) init
{
    if((self = [super init]))
    {
    }
    
    return self;
}

+ (C4Math*)sharedManager
{
    if (sharedC4Math == nil) {
        static dispatch_once_t once;
        dispatch_once(&once, ^ { sharedC4Math = [[super allocWithZone:NULL] init]; 
        });
        return sharedC4Math;
        
        
    }
    return sharedC4Math;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self sharedManager] retain];
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark Unused

/*
 
 NOTE
 Took out methods that calculate distances between points.
 Leaving this for the C4Vector class...
 Is this a good idea (consistent), or should these still be included in C4Math?
 */

// +(CGFloat)distFromX:(CGFloat)x1 Y:(CGFloat)y1 toX:(CGFloat)x2 Y:(CGFloat)y2 {
// return (sqrt(pow(x2-x1,2)+pow(y2-y1,2)));
// }
 
// +(CGFloat)magPoint:(NSPoint)p {
// return [self magX:p.x Y:p.y];
// }
 
// +(CGFloat)magX:(CGFloat)x Y:(CGFloat)y {
// return [self distFromX:0 Y:0 toX:x Y:y];
// }
 
// +(CGFloat)maxOfArray:(NSArray *)array {
// return 0;
// } 
 
// +(CGFloat)minOfArray:(NSArray *)array {
// return 0;
// }

// +(CGFloat)distanceFromPoint:(NSPoint)p1 toPoint:(NSPoint)p2 {
// return [self distanceFromX:p2.x Y:p2.y toX:p1.x Y:p1.y];
// }
 
// +(CGFloat)distanceFromX:(CGFloat)x1 Y:(CGFloat)y1 toX:(CGFloat)x2 Y:(CGFloat)y2 {
// return (sqrt(pow(x2-x1,2)+pow(y2-y1,2)));
// }

@end