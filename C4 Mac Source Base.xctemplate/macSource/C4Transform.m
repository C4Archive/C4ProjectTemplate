//
//  C4Transform.m
//  Created by Travis Kirton
//

#import "C4Transform.h"

static C4Transform *sharedC4Transform = nil;

@implementation C4Transform

@synthesize transformArray;

+(void)load {
	if(VERBOSELOAD) printf("C4Transform\n");
}

+(void)begin{
	[[C4Transform sharedManager] begin];
}

+(void)concat{
	[[C4Transform sharedManager] concat];
}

+(void)end {
	[[C4Transform sharedManager] end];
}

+(void)translateBy:(NSPoint)point {
	[[C4Transform sharedManager] translateBy:point];
}

+(void)translateByX:(CGFloat)x andY:(CGFloat)y {
	[[C4Transform sharedManager] translateByX:x andY:y];
}

+(void)rotateByAngle:(CGFloat)angle {
	[[C4Transform sharedManager] rotateByAngle:angle];
}

-(void)begin{
	[[NSGraphicsContext currentContext] saveGraphicsState];
	[transformArray addObject:[NSAffineTransform transform]];
}

-(void)concat{
	[[transformArray lastObject] concat];
}

-(void)end {
	NSInteger count = [transformArray count];
	if(count > 1) [[transformArray objectAtIndex:count-2] prependTransform:[transformArray lastObject]];
	[transformArray removeLastObject];
	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

-(void)translateBy:(NSPoint)point {
	[[C4Transform sharedManager] translateByX:point.x andY:point.y];
}

-(void)translateByX:(CGFloat)x andY:(CGFloat)y {
	[[transformArray lastObject] translateXBy:x yBy:y];
}

-(void)rotateByAngle:(CGFloat)angle {
	[[transformArray lastObject] rotateByRadians:angle];
}

#pragma mark Singleton

-(id) init
{
    if((self = [super init]))
    {
        transformArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    return self;
}

+ (C4Transform *)sharedManager
{
    if (sharedC4Transform == nil) {
        static dispatch_once_t once;
        dispatch_once(&once, ^ { sharedC4Transform = [[super allocWithZone:NULL] init]; 
        });
        return sharedC4Transform;
    }
    return sharedC4Transform;
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
