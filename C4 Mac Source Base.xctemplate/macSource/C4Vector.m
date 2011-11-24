//
//  C4Vector.m
//  Build
//
//  Created by Travis Kirton on 11-02-12.
//  Copyright 2011 Travis Kirton. All rights reserved.
//

#import "C4Vector.h"

/*
 uses a combination of cblas, veclib and straight calcluations
 confirmed values calculated to those produced by Processing
 */

@implementation C4Vector

@synthesize vec;

+(id)vectorWithX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z {
    C4Vector *v = [[[C4Vector alloc] init] vectorWithX:x Y:y Z:z];
	return v;
}

-(id)vectorWithX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z {
	if(!(self = [super init])) {
		return nil;
	}
	
	vec3[0] = x;
	vec3[1] = y;
	vec3[2] = z;
	
	pVec3[0] = 0;
	pVec3[1] = 0;
	pVec3[2] = 0;
    
    pDisplacedHeading = 0;
	return self;
}

-(void)setX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z {
    [self update];
	vec3[0] = x;
	vec3[1] = y;
	vec3[2] = z;
}

-(void)add:(C4Vector *)aVec {
    [self update];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) { 
        vDSP_vadd(vec3, 1, aVec.vec, 1, vec3, 1, 3);
    });
}

-(void)addScalar:(float)scalar {
    [self update];
    float *s = &scalar;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) { 
        vDSP_vsadd(vec3, 1, s, vec3, 1, 3);
    });
}

-(void)divide:(C4Vector *)aVec {
    [self update];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) { 
        vDSP_vdiv(aVec.vec, 1, vec3, 1, vec3, 1, 3);
    });
}

-(void)divideScalar:(float)scalar {
    [self update];
    float *s = &scalar;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) { 
        vDSP_vsdiv(vec3, 1, s, vec3, 1, 3);
    });
}

-(void)multiply:(C4Vector *)aVec {
    [self update];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) { 
        vDSP_vmul(vec3, 1, aVec.vec, 1, vec3, 1, 3);
    });
}

-(void)multiplyScalar:(float)scalar {
    [self update];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) { 
        vDSP_vsmul(vec3, 1, &scalar, vec3, 1, 3);
    });
}

-(void)subtract:(C4Vector *)aVec {
    [self update];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) { 
        vDSP_vsub(vec3, 1, aVec.vec, 1, vec3, 1, 3);
    });
}

-(void)subtractScalar:(float)scalar {
    [self update];
	[self addScalar:-1*scalar];
}

-(CGFloat)distance:(C4Vector *)aVec {
    __block CGFloat value;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) { 
        value = sqrt(pow(vec3[0]-(aVec.vec)[0], 2)+pow(vec3[1]-(aVec.vec)[1], 2)+pow(vec3[2]-(aVec.vec)[2], 2));
    });
    return value;
}

-(CGFloat)dot:(C4Vector *)aVec {
    __block CGFloat value;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) { 
        value = (CGFloat)cblas_sdot(3, vec3, 1, aVec.vec, 1);
    });
    return value;
}

-(CGFloat)magnitude {
    __block CGFloat value;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) { 
        value = sqrt(pow(vec3[0], 2)+pow(vec3[1], 2)+pow(vec3[2], 2));
    });
    return value;
}

-(CGFloat)angleBetween:(C4Vector *)aVec {
    __block CGFloat value;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) { 
        float dotProduct = [self dot:aVec];
        float cosTheta = dotProduct/([self magnitude]*[aVec magnitude]);
        value = acosf(cosTheta);
    });
    return value;
}

-(void)cross:(C4Vector *)aVec {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) { 
        float newVec[3];
        newVec[0] = vec3[1]*(aVec.vec)[2] - vec3[2]*(aVec.vec)[1];
        newVec[1] = vec3[2]*(aVec.vec)[0] - vec3[0]*(aVec.vec)[2];
        newVec[2] = vec3[0]*(aVec.vec)[1] - vec3[1]*(aVec.vec)[0];
        vec3[0] = newVec[0];
        vec3[1] = newVec[1];
        vec3[2] = newVec[2];
    });
}

-(void)normalize {
	[self limit:1.0f];
}

-(void)limit:(CGFloat)max {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) { 
        cblas_sscal(3, max/cblas_snrm2(3, vec3, 1), vec3, 1);
    });
}

-(float*)vec {
	return vec3;
}

-(NSPoint)point2D {
	return NSMakePoint(vec3[0], vec3[1]);
}

-(NSString *)description {
	return [NSString stringWithFormat:@"vec(%4.2f,%4.2f,%4.2f)",vec3[0],vec3[1],vec3[2]];
}

+(CGFloat)distanceBetweenA:(NSPoint)pointA andB:(NSPoint)pointB {
    __block CGFloat value;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) { 
        C4Vector *a = [C4Vector vectorWithX:pointA.x Y:pointA.y Z:0];
        C4Vector *b = [C4Vector vectorWithX:pointB.x Y:pointB.y Z:0];
        value = [a distance:b];
    });
    return value;
}

+(CGFloat)angleBetweenA:(NSPoint)pointA andB:(NSPoint)pointB {
    __block CGFloat value;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) { 
        C4Vector *a = [C4Vector vectorWithX:pointA.x Y:pointA.y Z:0];
        C4Vector *b = [C4Vector vectorWithX:pointB.x Y:pointB.y Z:0];
        value =  [a angleBetween:b];
    });
    return value;
}

-(CGFloat)x {
	return vec3[0];
}

-(CGFloat)y {
	return vec3[1];
}

-(CGFloat)z {
	return vec3[2];
}

-(CGFloat)heading {
    __block CGFloat value;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) {
        CGFloat angle = [C4Math atan2Y:vec3[1] X:vec3[0]]; //always against 0
        value = angle;
    });
    return value;
}

-(CGFloat)displacedHeading {
    if([self distance:[C4Vector vectorWithX:pVec3[0] Y:pVec3[1] Z:pVec3[2]]] > .5) {
    __block CGFloat value;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) {
        CGFloat angle = [C4Math atan2Y:vec3[1]-pVec3[1] X:vec3[0]-pVec3[0]]; //always against 0
        value = angle;
    });
        pDisplacedHeading = value;
    }
    return pDisplacedHeading;
}

-(CGFloat)headingBasedOn:(NSPoint)p {
    __block CGFloat value;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) {
        CGFloat angle = [C4Math atan2Y:(vec3[1]-p.y) X:(vec3[0]-p.x)]; //always against 0
        value = angle;
    });
    return value;
}

-(void)update {
    if(pVec3[0] != vec3[0]) pVec3[0] = vec3[0];
    if(pVec3[1] != vec3[1]) pVec3[1] = vec3[1];
    if(pVec3[2] != vec3[2]) pVec3[2] = vec3[2];
}

-(void)setX:(CGFloat)newX {
    [self update];
    vec3[0] = newX;
}

-(void)setY:(CGFloat)newY {
    [self update];
    vec3[1] = newY;
}

-(void)setZ:(CGFloat)newZ {
    [self update];
    vec3[2] = newZ;
}

@end
