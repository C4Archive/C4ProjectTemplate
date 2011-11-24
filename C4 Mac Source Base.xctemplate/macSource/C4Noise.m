//
//  C4Noise.m
//  Perlin
//
//  Created by moi on 11-04-08.
//  Copyright 2011 mediart. All rights reserved.
//

#import "C4Noise.h"

@interface C4Noise () {}
CGFloat noise(CGFloat x, CGFloat y, CGFloat z);
CGFloat fade(CGFloat t);
CGFloat lerp(CGFloat t, CGFloat a, CGFloat b);
CGFloat grad(NSInteger hash, CGFloat x, CGFloat y, CGFloat z);
@end

static C4Noise *sharedC4Noise = nil;

@implementation C4Noise 

#pragma mark Initialization
BOOL ready = NO;
int p[512];
int permutation[512] = { 151,160,137,91,90,15,
    131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
    190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
    88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
    77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
    102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
    135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
    5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
    223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
    129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
    251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
    49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
    138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180
};

+(CGFloat)noiseX:(CGFloat)x {
    return [C4Noise noiseX:x Y:0 Z:0];
}
+(CGFloat)noiseX:(CGFloat)x Y:(CGFloat)y{
    return [C4Noise noiseX:x Y:y Z:0];
}
+(CGFloat)noiseX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z{
    __block CGFloat value;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) { value = noise(x, y, z);});
    return value;
}

CGFloat noise(CGFloat x, CGFloat y, CGFloat z) {
    if(!ready) {
        for (int i=0; i < 256 ; i++) p[256+i] = p[i] = permutation[i];
        ready = YES;
    }
    NSInteger X = (NSInteger)floorf(x) & 255,                  // FIND UNIT CUBE THAT
    Y = (NSInteger)floorf(y) & 255,                  // CONTAINS POINT.
    Z = (NSInteger)floorf(z) & 255;
    x -= floorf(x);                                // FIND RELATIVE X,Y,Z
    y -= floorf(y);                                // OF POINT IN CUBE.
    z -= floorf(z);
    CGFloat u = fade(x),                                // COMPUTE FADE CURVES
    v = fade(y),                                // FOR EACH OF X,Y,Z.
    w = fade(z);
    NSInteger A = p[X  ]+Y, AA = p[A]+Z, AB = p[A+1]+Z,      // HASH COORDINATES OF
    B = p[X+1]+Y, BA = p[B]+Z, BB = p[B+1]+Z;      // THE 8 CUBE CORNERS,
   
    __block CGFloat noiseValue;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) { noiseValue = lerp(w, lerp(v, lerp(u, grad(p[AA  ], x  , y  , z   ),  // AND ADD
                                                                     grad(p[BA  ], x-1, y  , z   )), // BLENDED
                                                             lerp(u, grad(p[AB  ], x  , y-1, z   ),  // RESULTS
                                                                  grad(p[BB  ], x-1, y-1, z   ))),// FROM  8
                                                     lerp(v, lerp(u, grad(p[AA+1], x  , y  , z-1 ),  // CORNERS
                                                                  grad(p[BA+1], x-1, y  , z-1 )), // OF CUBE
                                                          lerp(u, grad(p[AB+1], x  , y-1, z-1 ),
                                                               grad(p[BB+1], x-1, y-1, z-1 ))));});

    return noiseValue;
}

CGFloat fade(CGFloat t) { 
    __block CGFloat fadeValue;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) { fadeValue = t * t * t * (t * (t * 6 - 15) + 10);});
    return fadeValue;
}

CGFloat lerp(CGFloat t, CGFloat a, CGFloat b) { 
    __block CGFloat lerpValue;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void) { lerpValue = a + t * (b - a);});
    return lerpValue;
}

CGFloat grad(NSInteger hash, CGFloat x, CGFloat y, CGFloat z) {
    __block CGFloat gradValue;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^(void){
    NSInteger h = hash & 15;                 // CONVERT LO 4 BITS OF HASH CODE
    CGFloat u = h<8 ? x : y,                 // INTO 12 GRADIENT DIRECTIONS.
    v = h<4 ? y : h==12||h==14 ? x : z;
        gradValue = ((h&1) == 0 ? u : -u) + ((h&2) == 0 ? v : -v);});
    return gradValue;
}

#pragma mark Singleton

-(id) init
{
    if((self = [super init]))
    {
    }
    
    return self;
}

+ (C4Noise *)sharedManager
{
    if (sharedC4Noise == nil) {
        static dispatch_once_t once;
        dispatch_once(&once, ^ { sharedC4Noise = [[super allocWithZone:NULL] init]; 
        });
        return sharedC4Noise;
    }
    return sharedC4Noise;
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
