//
//  C4Transform.h
//  Created by Travis Kirton
//

#import <Cocoa/Cocoa.h>
#import "C4Canvas.h"

@interface C4Transform : C4Object {
	@private
	NSMutableArray *transformArray;
}

+(C4Transform *)sharedManager;

+(void)begin;
+(void)concat;
+(void)end;

+(void)translateBy:(NSPoint)point;
+(void)translateByX:(CGFloat)x andY:(CGFloat)y;
+(void)rotateByAngle:(CGFloat)angle;

-(void)begin;
-(void)concat;
-(void)end;
-(void)translateBy:(NSPoint)p;
-(void)translateByX:(CGFloat)x andY:(CGFloat)y;
-(void)rotateByAngle:(CGFloat)angle;

@property(readwrite,retain) NSMutableArray *transformArray;
@end
