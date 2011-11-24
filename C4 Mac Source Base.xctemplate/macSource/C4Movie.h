//
//  C4Movie.h
//  VideoCALayer
//
//  Created by moi on 11-04-10.
//  Copyright 2011 mediart. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <QTKit/QTKit.h>
#import <OpenGL/OpenGL.h>

/*
 Decent implementation, but controlling layer order is a problem
 Also, having gone through this, it might be an idea to revamp everything into layers (CALayers, etc)
 */

@interface C4Movie : CAOpenGLLayer {
    @private
    QTMovie                 *movie;
    QTVisualContextRef      qtVisualContext;
    CVImageBufferRef		currentFrame;
    
    GLfloat                 lowerLeft[2];
    GLfloat                 lowerRight[2];
    GLfloat                 upperRight[2];
    GLfloat                 upperLeft[2];
}

@property(retain)QTMovie *movie;

+(C4Movie *)movieName:(id)aName;
+(C4Movie *)movieName:(id)aName andType:(id)aType;
-(id)initWithMovieName:(id)aName;
-(id)initWithMovieName:(id)aName andType:(id)aType;

-(void)play;
-(void)stop;
-(void)goToBeginning;
-(CGFloat)rate;
-(void)setRate:(CGFloat)newRate;
-(CGFloat)volume;
-(void)setVolume:(CGFloat)newVolume;
-(CGFloat)movieLength;
-(BOOL)muted;
-(void)setMuted:(BOOL)mute;
-(void)goToTime:(CGFloat)aTime;
-(void)eject;
-(void)setLoops:(BOOL)loops;
-(void)moveLayerDown;
-(void)moveLayerUp;
-(void)moveBelow:(CALayer *)anotherLayer;
-(void)moveAbove:(CALayer *)anotherLayer;
-(void)setX:(CGFloat)x;
-(void)setY:(CGFloat)y;
-(void)setX:(CGFloat)x andY:(CGFloat)y;
-(void)setLocation:(NSPoint)point;

-(void)setWidth:(CGFloat)width;
-(void)setHeight:(CGFloat)height;
-(void)setWidth:(CGFloat)width andHeight:(CGFloat)height;
-(void)setSize:(NSSize)newSize;

-(void)rectMode:(NSInteger)mode;

-(void)setX:(CGFloat)x andY:(CGFloat)y withWidth:(CGFloat)width andHeight:(CGFloat)height;
@end
